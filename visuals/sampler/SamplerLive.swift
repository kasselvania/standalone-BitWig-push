import AppKit
import Darwin
import Foundation

struct SamplerDisplay: Equatable {
    let id: CGDirectDisplayID, index: Int, bounds: CGRect, pixelWidth: Int, pixelHeight: Int
    static func select(_ window: CGRect, from displays: [SamplerDisplay]) throws -> SamplerDisplay {
        try samplerRequire(window.width > 0 && window.height > 0, "Empty Bitwig window")
        let matches = displays.filter { $0.bounds.contains(window) }
        try samplerRequire(matches.count == 1, "Bitwig must be wholly within one unambiguous display")
        let chosen = matches[0]
        _ = try FFmpegSamplerStream.byteCount(width:chosen.pixelWidth,height:chosen.pixelHeight)
        return chosen
    }
    static func read(containing window: CGRect) throws -> SamplerDisplay {
        var count: UInt32 = 0
        try samplerRequire(CGGetActiveDisplayList(0,nil,&count) == .success && count > 0 && count <= 16,
                           "Active display enumeration unavailable or exceeds 16 displays")
        var ids = [CGDirectDisplayID](repeating:0,count:Int(count))
        let capacity = count
        try samplerRequire(CGGetActiveDisplayList(capacity,&ids,&count) == .success && count == capacity,
                           "Display topology changed during enumeration")
        var displays: [SamplerDisplay] = []
        // FFmpeg 9 avfoundation.m maps "Capture screen N" to this same ordered public list.
        for (index,id) in ids.enumerated() {
            guard let mode = CGDisplayCopyDisplayMode(id) else { throw SamplerFailure(description:"Display mode unavailable") }
            displays.append(SamplerDisplay(id:id,index:index,bounds:CGDisplayBounds(id),pixelWidth:mode.pixelWidth,pixelHeight:mode.pixelHeight))
        }
        return try select(window,from:displays)
    }
}

struct SamplerWindow: Equatable {
    let id: CGWindowID, pid: pid_t
    let bounds: CGRect
    let occluders: [CGRect]
    let display: SamplerDisplay
    static func read(_ id: CGWindowID) throws -> SamplerWindow {
        let pids = Set(NSRunningApplication.runningApplications(withBundleIdentifier: "com.bitwig.studio").map(\.processIdentifier))
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        var occluders: [CGRect] = []
        for w in list {
            guard let number = w[kCGWindowNumber as String] as? UInt32,
                  let dictionary = w[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: dictionary as CFDictionary) else { continue }
            if number == id {
                guard let pid = w[kCGWindowOwnerPID as String] as? pid_t, pids.contains(pid),
                      w[kCGWindowLayer as String] as? Int == 0 else { throw SamplerFailure(description: "Selected source is not a current ordinary Bitwig window") }
                return SamplerWindow(id: id, pid: pid, bounds: bounds, occluders: occluders, display:try SamplerDisplay.read(containing:bounds))
            }
            if (w[kCGWindowAlpha as String] as? Double ?? 1) > 0,
               w[kCGWindowLayer as String] as? Int != Int(CGWindowLevelForKey(.cursorWindow)) { occluders.append(bounds) }
        }
        throw SamplerFailure(description: "Selected Bitwig window is unavailable; explicit reselection required after recreation")
    }
    func covers(_ body: SamplerBounds, width: Int, height: Int) -> Bool {
        let rectangle = CGRect(x: bounds.minX + Double(body.x)*bounds.width/Double(width),
            y: bounds.minY + Double(body.y)*bounds.height/Double(height),
            width: Double(body.width)*bounds.width/Double(width), height: Double(body.height)*bounds.height/Double(height)).insetBy(dx: -2, dy: -2)
        return occluders.contains { $0.intersects(rectangle) }
    }
    func stream() throws -> FFmpegSamplerStream {
        let screen = display.bounds
        // Only the recognition search follows the current window. Device bounds come from the
        // Sampler constellation/border, never these desktop fractions. FFmpeg uses actual iw/ih.
        let graph = "crop=w=floor(iw*\(bounds.width/screen.width)):h=floor(ih*\(bounds.height/screen.height)):"
            + "x=floor(iw*\((bounds.minX-screen.minX)/screen.width)):y=floor(ih*\((bounds.minY-screen.minY)/screen.height)):exact=1"
        return try FFmpegSamplerStream(input: ["-thread_queue_size", "1", "-f", "avfoundation", "-capture_cursor", "0", "-capture_mouse_clicks", "0",
            "-pixel_format", "bgr0", "-drop_late_frames", "1", "-framerate", "30", "-i", "Capture screen \(display.index):none"], filter: graph)
    }
}

/// Static control labels are checked on every frame; OCR reacquires only when that lock fails.
/// This is conservative feature continuity, not arbitrary-device/hidden-window identification.
final class SamplerImageLock {
    private var landmarks: [Landmark] = [], signatures: [[Int]] = []
    private var dimensions = [0,0]
    private var lastRecognition = -Double.infinity
    private func signature(_ pixels: ObservationPixels, _ mark: Landmark) -> [Int] {
        var result: [Int] = []; result.reserveCapacity(64)
        for y in 0..<4 { for x in 0..<16 {
            let px = Int(mark.x + (Double(x)+0.5)*mark.width/16)
            let py = Int(mark.y + (Double(y)+0.5)*mark.height/4)
            result.append(pixels.gray(px,py))
        } }
        return result
    }
    func locate(_ frame: FFmpegSamplerStream.Frame) throws -> SamplerBounds? {
        let pixels = try ObservationPixels(bgr0: frame.bytes, width: frame.width, height: frame.height, stride: frame.width*4)
        if dimensions == [frame.width,frame.height] && !landmarks.isEmpty {
            var differences = 0, total = 0
            for (index, mark) in landmarks.enumerated() {
                let current = signature(pixels, mark)
                for i in 0..<current.count {
                    total += 1
                    if abs(current[i]-signatures[index][i]) > 12 { differences += 1 }
                }
            }
            if differences == 0, total > 0, let body = SamplerLocator.locate(pixels, landmarks: landmarks) { return body }
        }
        landmarks = []; signatures = []
        guard samplerClock()-lastRecognition >= 0.5 else { return nil }
        lastRecognition = samplerClock()
        guard let provider = CGDataProvider(dataInfo: nil, data: frame.bytes.baseAddress!, size: frame.bytes.count, releaseData: { _,_,_ in }),
              let image = CGImage(width: frame.width, height: frame.height, bitsPerComponent: 8, bitsPerPixel: 32,
                bytesPerRow: frame.width*4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil }
        let found = try SamplerLocator.landmarks(in: image)
        guard let body = SamplerLocator.locate(pixels, landmarks: found) else { return nil }
        // Do not retain CGImage/provider/borrowed frame beyond this synchronous method.
        landmarks = found; signatures = found.map { signature(pixels, $0) }; dimensions = [frame.width,frame.height]
        return body
    }
}

#if !SAMPLER_TEST
@main struct SamplerLive {
    static var stopping: Int32 = 0
    static func main() {
        do { try run() }
        catch { fputs("Sampler live test stopped: \(error)\n", stderr); exit(1) }
    }
    static func run() throws {
        guard CommandLine.arguments.count == 3, let windowID = UInt32(CommandLine.arguments[1]),
              let seconds = Double(CommandLine.arguments[2]), seconds.isFinite, seconds > 0, seconds <= 1800 else {
            throw SamplerFailure(description: "usage: SamplerLive explicit-current-Bitwig-window-ID duration-seconds (1..1800)")
        }
        signal(SIGINT) { _ in SamplerLive.stopping = 1 }; signal(SIGTERM) { _ in SamplerLive.stopping = 1 }
        guard let fit = sampler_fit_create() else { throw SamplerFailure(description: "Cannot allocate fixed center output") }
        defer { sampler_fit_destroy(fit) }
        var connection: SamplerConnection?, stream: FFmpegSamplerStream?, source: SamplerWindow?, identity: SamplerAuthority?
        var imageLock = SamplerImageLock(), consumed: String?, contextSince = samplerClock()
        var nextCheck = 0.0, refused = "", accepted = 0, discarded = 0
        var processing: [Double] = [], sourceToSend: [Double] = [], intervals: [Double] = [], lastPTS: Double?
        var readTimes: [Double] = [], arrivalAges: [Double] = []
        var reasons: [String:Int] = [:]
        func count(_ reason: String) { reasons[reason,default:0] += 1 }
        var lastDelivery = samplerClock()
        let deadline = samplerClock() + seconds
        defer { try? connection?.clear(); connection?.close(); stream?.close() }
        print("Sampler live development test: actual FFmpeg visible-screen acquisition; no app install or permission changes.")
        func report(_ message: String) { if message != refused { print(message); fflush(stdout); refused = message } }
        while stopping == 0 && samplerClock() < deadline {
            if samplerClock() >= nextCheck {
                nextCheck = samplerClock() + 0.1
                do {
                    let current = try SamplerAuthority.read()
                    let window = try SamplerWindow.read(windowID)
                    try samplerRequire(window.pid == current.pid, "Selected window belongs to a different Bitwig process")
                    if current != identity {
                        count("contextChange")
                        try? connection?.clear(); connection?.close(); connection = nil
                        stream?.close(); stream = nil; source = nil; imageLock = SamplerImageLock()
                        identity = current; contextSince = samplerClock(); lastPTS = nil
                    }
                    if let session = current.session {
                        if connection == nil && consumed != session {
                            consumed = session // Never reuse one v1 session across different connections.
                            connection = try SamplerConnection(current)
                            report("Controller permits the native Sampler page; acquiring current device image.")
                        }
                        if connection != nil && (source?.bounds != window.bounds || source?.pid != window.pid || source?.display != window.display || stream == nil) {
                            count("acquisitionStart")
                            try? connection?.clear(); stream?.close(); stream = nil
                            source = window; imageLock = SamplerImageLock(); lastPTS = nil
                            stream = try window.stream(); contextSince = samplerClock(); lastDelivery = samplerClock()
                        }
                    } else { report("Current context is semantic-only (not the supported Sampler parameter page).") }
                } catch {
                    count("authorityOrSourceFailure")
                    try? connection?.clear(); connection?.close(); connection = nil
                    stream?.close(); stream = nil; source = nil; identity = nil
                    nextCheck = samplerClock() + 1
                    report("Semantic fallback: \(error)")
                }
            }
            guard let activeStream = stream, let activeSource = source, let activeConnection = connection, let activeIdentity = identity else { usleep(20_000); continue }
            do {
                let readStart = samplerClock()
                guard let frame = try activeStream.nextFrame() else {
                    if samplerClock()-lastDelivery > 0.25 { count("deliveryTimeout"); try activeConnection.clear() }
                    continue
                }
                lastDelivery = samplerClock()
                if let lastPTS { try samplerRequire(frame.captured > lastPTS, "Capture timestamp did not advance"); intervals.append((frame.captured-lastPTS)*1000) }
                lastPTS = frame.captured
                // Required source/host clock agreement is checked on actual acquisition, not assumed
                // from pipe read time. Retaining -copyts is essential; no setpts=PTS-STARTPTS.
                let age = samplerClock()-frame.captured
                if readTimes.count < 10000 { readTimes.append((samplerClock()-readStart)*1000); arrivalAges.append(age*1000) }
                try samplerRequire(age >= -0.02 && age < 10, "FFmpeg capture clock is not the verified host-clock domain")
                if frame.captured <= contextSince || age > 0.25 { count(frame.captured <= contextSince ? "beforeContext" : "oldAtRead"); discarded += 1; try activeConnection.clear(); continue }
                let start = samplerClock()
                let before = try SamplerWindow.read(windowID)
                guard before.bounds == activeSource.bounds, before.pid == activeSource.pid, before.display == activeSource.display else { count("geometryChange"); discarded += 1; try activeConnection.clear(); continue }
                let body = try autoreleasepool { try imageLock.locate(frame) }
                guard let body else { count("locatorMissing"); discarded += 1; try activeConnection.clear(); report("Semantic fallback: waiting for a unique complete Sampler body."); continue }
                let after = try SamplerWindow.read(windowID)
                guard before == after else { count("sourceChangedDuringFrame"); discarded += 1; try activeConnection.clear(); continue }
                guard !after.covers(body, width: frame.width, height: frame.height) else { count("occluded"); discarded += 1; try activeConnection.clear(); continue }
                guard try SamplerAuthority.read() == activeIdentity else { count("contextChangedDuringFrame"); discarded += 1; try activeConnection.clear(); continue }
                guard let output = sampler_fit_frame(fit, frame.bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), frame.bytes.count,
                    Int32(frame.width), Int32(frame.height), Int32(frame.width*4), Int32(body.x), Int32(body.y), Int32(body.width), Int32(body.height)) else {
                    throw SamplerFailure(description: "FFmpeg crop/fit refused source bounds")
                }
                guard samplerClock()-frame.captured <= 0.25 else { count("oldAfterProcessing"); discarded += 1; try activeConnection.clear(); continue }
                try activeConnection.frame(UnsafeRawBufferPointer(start: output, count: 484*114*4))
                accepted += 1
                if accepted > 30 && processing.count < 10000 {
                    processing.append((samplerClock()-start)*1000); sourceToSend.append((samplerClock()-frame.captured)*1000)
                }
                if intervals.count > 10000 { intervals.removeAll(keepingCapacity: true) }
                report("Live center: measured Sampler \(body.width)×\(body.height), within \(frame.width)×\(frame.height) search; all readouts remain controller-owned.")
            } catch {
                count("frameFailure")
                try? activeConnection.clear(); activeConnection.close(); connection = nil
                stream?.close(); stream = nil; source = nil; identity = nil
                nextCheck = samplerClock() + 1
                // Next discovery waits for the controller to issue a fresh connection ticket.
                report("Semantic fallback: \(error)")
            }
        }
        func distribution(_ values: [Double]) -> [String: Any] {
            let sorted = values.sorted()
            guard !sorted.isEmpty else { return ["samples": 0] }
            return ["samples": sorted.count, "p50Ms": sorted[(sorted.count-1)/2], "p95Ms": sorted[Int(Double(sorted.count-1)*0.95)], "maxMs": sorted.last!]
        }
        let result: [String: Any] = ["accepted": accepted, "discarded": discarded,
            "processing": distribution(processing), "captureToSend": distribution(sourceToSend), "sourceIntervals": distribution(intervals),
            "pipeRead":distribution(readTimes),"ageAtRead":distribution(arrivalAges),"reasons":reasons,
            "scope": "development run; direct Push observations and CPU/RSS are separate"]
        print(String(data: try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys]), encoding: .utf8)!)
    }
}
#endif
