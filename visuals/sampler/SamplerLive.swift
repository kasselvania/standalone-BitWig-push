import CoreGraphics
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
    /// Unrelated windows are not the selected source's identity. Coverage is checked against
    /// the measured device at both observations, not by equality of the entire desktop list.
    func sameCapture(as other: SamplerWindow) -> Bool {
        id == other.id && pid == other.pid && bounds == other.bounds && display == other.display
    }
    func permits(_ body: SamplerBounds, width: Int, height: Int, after: SamplerWindow) -> Bool {
        sameCapture(as: after) && !covers(body, width: width, height: height)
            && !after.covers(body, width: width, height: height)
    }
    struct Candidate: Equatable {
        let id: CGWindowID, pid: pid_t, layer: Int, bounds: CGRect
    }
    static func select(_ candidates: [Candidate], ownerPID: pid_t, explicitID: CGWindowID? = nil) throws -> Candidate {
        let matches = candidates.filter { $0.pid == ownerPID && $0.layer == 0 &&
            !$0.bounds.isEmpty && !$0.bounds.isInfinite && !$0.bounds.isNull &&
            [$0.bounds.minX,$0.bounds.minY,$0.bounds.width,$0.bounds.height].allSatisfy(\.isFinite) &&
            (explicitID == nil || $0.id == explicitID) }
        try samplerRequire(matches.count == 1, matches.isEmpty ? "Waiting for a visible Bitwig window" :
                           "Multiple Bitwig windows: automatic selection abstains")
        return matches[0]
    }
    static func read(ownerPID: pid_t, explicitID: CGWindowID? = nil) throws -> SamplerWindow {
        guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]],
              list.count <= 4096 else { throw SamplerFailure(description: "Window enumeration unavailable or oversized") }
        let candidates = list.compactMap { w -> Candidate? in
            guard let id = w[kCGWindowNumber as String] as? UInt32,
                  let pid = w[kCGWindowOwnerPID as String] as? pid_t,
                  let layer = w[kCGWindowLayer as String] as? Int,
                  let dictionary = w[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: dictionary as CFDictionary),
                  (w[kCGWindowAlpha as String] as? Double ?? 1) > 0 else { return nil }
            return Candidate(id:id,pid:pid,layer:layer,bounds:bounds)
        }
        let selected = try select(candidates, ownerPID: ownerPID, explicitID: explicitID)
        var occluders: [CGRect] = []
        for w in list {
            guard let number = w[kCGWindowNumber as String] as? UInt32,
                  let dictionary = w[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: dictionary as CFDictionary) else { continue }
            if number == selected.id {
                return SamplerWindow(id: selected.id, pid: ownerPID, bounds: bounds, occluders: occluders, display:try SamplerDisplay.read(containing:bounds))
            }
            if (w[kCGWindowAlpha as String] as? Double ?? 1) > 0,
               w[kCGWindowLayer as String] as? Int != Int(CGWindowLevelForKey(.cursorWindow)) { occluders.append(bounds) }
        }
        throw SamplerFailure(description: "Selected Bitwig window disappeared during enumeration")
    }
    func covers(_ body: SamplerBounds, width: Int, height: Int) -> Bool {
        let rectangle = CGRect(x: bounds.minX + Double(body.x)*bounds.width/Double(width),
            y: bounds.minY + Double(body.y)*bounds.height/Double(height),
            width: Double(body.width)*bounds.width/Double(width), height: Double(body.height)*bounds.height/Double(height)).insetBy(dx: -2, dy: -2)
        return occluders.contains { $0.intersects(rectangle) }
    }
    func stream(executable: URL) throws -> FFmpegSamplerStream {
        let screen = display.bounds
        // Only the recognition search follows the current window. Device bounds come from the
        // Sampler constellation/border, never these desktop fractions. FFmpeg uses actual iw/ih.
        let graph = "crop=w=floor(iw*\(bounds.width/screen.width)):h=floor(ih*\(bounds.height/screen.height)):"
            + "x=floor(iw*\((bounds.minX-screen.minX)/screen.width)):y=floor(ih*\((bounds.minY-screen.minY)/screen.height)):exact=1"
        return try FFmpegSamplerStream(input: ["-thread_queue_size", "1", "-f", "avfoundation", "-capture_cursor", "0", "-capture_mouse_clicks", "0",
            "-pixel_format", "bgr0", "-drop_late_frames", "1", "-framerate", "30", "-i", "Capture screen \(display.index):none"], filter: graph, executable:executable)
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

/// Timing metadata only: bounded rolling samples, never a queue of images.
struct SamplerTiming {
    static let capacity = 10000
    private var values: [Double] = []
    private(set) var total = 0, maximum = 0.0
    mutating func add(_ value: Double) {
        if values.count < Self.capacity { values.append(value) }
        else { values[total % Self.capacity] = value }
        total += 1; maximum = max(maximum,value)
    }
    var summary: [String: Any] {
        let sorted = values.sorted()
        guard !sorted.isEmpty else { return ["samples":0,"totalSamples":0] }
        return ["samples":sorted.count,"totalSamples":total,"p50Ms":sorted[(sorted.count-1)/2],
                "p95Ms":sorted[Int(Double(sorted.count-1)*0.95)],"maxMs":maximum]
    }
}

/// The real synchronous production loop, also exercised with generated FFmpeg/socket endpoints.
/// Dependencies replace acquisition inputs in tests, not its lifecycle or publication decisions.
final class SamplerRuntime {
    struct Inputs {
        var authority: () throws -> SamplerAuthority = SamplerAuthority.read
        var window: (Int32, CGWindowID?) throws -> SamplerWindow = { try SamplerWindow.read(ownerPID:$0,explicitID:$1) }
        var connect: (SamplerAuthority) throws -> SamplerConnection = { try SamplerConnection($0) }
        var acquire: (SamplerWindow, URL) throws -> FFmpegSamplerStream = { try $0.stream(executable:$1) }
        var locate: (SamplerImageLock, FFmpegSamplerStream.Frame) throws -> SamplerBounds? = { try $0.locate($1) }
    }
    private let inputs: Inputs, explicitID: CGWindowID?, fit: OpaquePointer, ffmpeg: URL
    var onState: ((String) -> Void)?
    private var connection: SamplerConnection?, stream: FFmpegSamplerStream?, source: SamplerWindow?, identity: SamplerAuthority?
    private var imageLock = SamplerImageLock(), consumed: String?, contextSince = samplerClock()
    private var nextCheck = 0.0, lastDelivery = samplerClock(), lastPTS: Double?, acceptedInAcquisition = 0
    private var receivedFirstFrame = false
    private var processing = SamplerTiming(), sourceToSend = SamplerTiming(), intervals = SamplerTiming()
    private var reads = SamplerTiming(), arrivalAges = SamplerTiming(), fitTimes = SamplerTiming(), locateTimes = SamplerTiming(), sendTimes = SamplerTiming()
    private(set) var accepted = 0, discarded = 0, reasons: [String:Int] = [:]
    private(set) var state = "Waiting for Bitwig/V5A; external ingress disabled or unavailable" {
        didSet { if state != oldValue { count("stateTransitions"); onState?(state) } }
    }
    private(set) var failure: String?
    private(set) var closed = false
    var isCapturing: Bool { stream != nil }
    init(explicitID: CGWindowID? = nil, ffmpeg: URL? = nil, inputs: Inputs = Inputs()) throws {
        self.ffmpeg = try ffmpeg ?? SamplerFFmpeg.resolve()
        guard let fit = sampler_fit_create() else { throw SamplerFailure(description:"Cannot allocate fixed center output") }
        self.fit = fit; self.explicitID = explicitID; self.inputs = inputs
    }
    deinit { close(); sampler_fit_destroy(fit) }
    private func count(_ reason: String) { reasons[reason,default:0] += 1 }
    private func releaseCapture() {
        try? connection?.clear(); connection?.close(); connection = nil
        stream?.close(); stream = nil; lastPTS = nil
        // Retain only geometry/label signatures. There is no retained frame to replay.
    }
    func close() {
        guard !closed else { return }; closed = true
        releaseCapture(); state = "Stopped; ordinary DrivenByMoss semantics"
    }
    private func fallback(_ error: Error, authorityUnavailable: Bool = false) {
        releaseCapture(); identity = nil; nextCheck = samplerClock()+0.5
        state = authorityUnavailable ? "Waiting for Bitwig/V5A; external ingress disabled or unavailable. Semantic fallback: \(error)" : "Semantic fallback: \(error)"
    }
    private func reject(_ reason: String, message: String) throws {
        discarded += 1; count(reason); try connection?.clear(); state = message
    }
    /// Returns only an idle delay. Frame receipt itself already waits boundedly for capture.
    func step() -> Double {
        guard !closed else { return 0.25 }
        if samplerClock() >= nextCheck {
            nextCheck = samplerClock()+0.1
            var readingAuthority = true
            do {
                let current = try inputs.authority()
                readingAuthority = false
                if current != identity {
                    count("contextChange"); releaseCapture()
                    identity = current; contextSince = samplerClock()
                }
                guard let session = current.session else {
                    state = "Waiting for supported Sampler Device Parameters context; ordinary semantics"
                    return 0.1
                }
                let window = try inputs.window(current.pid,explicitID)
                try samplerRequire(window.pid == current.pid,"Window owner differs from current Bitwig session")
                if connection == nil {
                    let ticket = current.generation+session
                    guard consumed != ticket else {
                        state = "Waiting for a fresh controller connection ticket"
                        return 0.1
                    }
                    do {
                        connection = try inputs.connect(current); consumed = ticket
                    } catch {
                        // A failure known to precede HELLO did not spend a controller ticket.
                        // An attempted/partial HELLO is never retried under the old identity.
                        if (error as? SamplerConnection.StartupFailure)?.authenticationAttempted != false { consumed = ticket }
                        throw error
                    }
                }
                if source.map({ !$0.sameCapture(as:window) }) ?? true {
                    if source != nil { count("geometryReacquisition"); state = "Source geometry changed; semantic fallback and fresh acquisition" }
                    imageLock = SamplerImageLock()
                    try connection?.clear(); stream?.close(); stream = nil
                }
                if stream == nil {
                    source = window; lastPTS = nil; acceptedInAcquisition = 0; receivedFirstFrame = false
                    count("acquisitionStart"); state = "Starting FFmpeg acquisition"
                    stream = try inputs.acquire(window,ffmpeg)
                    contextSince = samplerClock(); lastDelivery = samplerClock()
                    state = "Waiting for the first complete frame (5-second startup bound)"
                }
            } catch { count("authorityOrSourceFailure"); fallback(error,authorityUnavailable:readingAuthority) }
        }
        guard let stream, let source, let connection, let identity else { return 0.1 }
        do {
            let readStart = samplerClock()
            guard let frame = try stream.nextFrame() else {
                if lastPTS != nil && samplerClock()-lastDelivery > 0.25 {
                    count("deliveryTimeout"); try connection.clear(); state = "Semantic fallback: capture delivery timeout"
                }
                return 0
            }
            lastDelivery = samplerClock()
            if !receivedFirstFrame {
                receivedFirstFrame = true; count("firstCompleteFrame")
                state = "Locating Sampler in the current complete frame"
            }
            if let lastPTS {
                try samplerRequire(frame.captured > lastPTS,"Capture timestamp did not advance")
                intervals.add((frame.captured-lastPTS)*1000)
            }
            lastPTS = frame.captured
            let age = samplerClock()-frame.captured
            reads.add((samplerClock()-readStart)*1000); arrivalAges.add(age*1000)
            try samplerRequire(age >= -0.02 && age < 10,"FFmpeg capture clock is not the verified host-clock domain")
            if frame.captured <= contextSince || age > 0.25 {
                try reject(frame.captured <= contextSince ? "beforeContext" : "oldAtRead",message:"Semantic fallback: waiting for a current frame")
                return 0
            }
            let start = samplerClock()
            let before = try inputs.window(identity.pid,explicitID)
            guard before.sameCapture(as:source) else {
                try reject("geometryChange",message:"Semantic fallback: source geometry changed"); return 0
            }
            let locateStart = samplerClock()
            let body = try inputs.locate(imageLock,frame)
            let locateMs = (samplerClock()-locateStart)*1000
            guard let body else {
                try reject("locatorMissing",message:"Semantic fallback: locator temporarily unavailable in complete source frames"); return 0
            }
            let after = try inputs.window(identity.pid,explicitID)
            guard before.sameCapture(as:after) else {
                try reject("sourceChangedDuringFrame",message:"Semantic fallback: source changed during processing"); return 0
            }
            guard before.permits(body,width:frame.width,height:frame.height,after:after) else {
                try reject("occluded",message:"Semantic fallback: source occluded; another window covers Sampler"); return 0
            }
            guard try inputs.authority() == identity else {
                try reject("contextChangedDuringFrame",message:"Semantic fallback: controller context changed"); return 0
            }
            let fitStart = samplerClock()
            guard let output = sampler_fit_frame(fit,frame.bytes.baseAddress?.assumingMemoryBound(to:UInt8.self),frame.bytes.count,
                Int32(frame.width),Int32(frame.height),Int32(frame.width*4),Int32(body.x),Int32(body.y),Int32(body.width),Int32(body.height)) else {
                throw SamplerFailure(description:"Crop/fit refused source bounds")
            }
            let fitMs = (samplerClock()-fitStart)*1000
            guard samplerClock()-frame.captured <= 0.25 else {
                try reject("oldAfterProcessing",message:"Semantic fallback: processing exceeded current-frame deadline"); return 0
            }
            let sendStart = samplerClock()
            try connection.frame(UnsafeRawBufferPointer(start:output,count:484*114*4))
            accepted += 1; acceptedInAcquisition += 1
            if acceptedInAcquisition > 30 {
                processing.add((samplerClock()-start)*1000); sourceToSend.add((samplerClock()-frame.captured)*1000)
                locateTimes.add(locateMs); fitTimes.add(fitMs); sendTimes.add((samplerClock()-sendStart)*1000)
            }
            state = "Active Sampler image; controller readouts unchanged"
        } catch let error as FFmpegSamplerStream.StartupFailure {
            count("firstFrameFailure"); failure = error.description
            state = error.description; close()
        } catch { count("frameFailure"); fallback(error) }
        return 0
    }
    var summary: [String:Any] {
        ["state":state,"accepted":accepted,"discarded":discarded,"processing":processing.summary,
         "captureToSend":sourceToSend.summary,"sourceIntervals":intervals.summary,"frameRead":reads.summary,
         "ageAtRead":arrivalAges.summary,"locate":locateTimes.summary,"fit":fitTimes.summary,"send":sendTimes.summary,
         "reasons":reasons,"capturing":isCapturing,"failure":failure ?? "none",
         "timingScope":"p50/p95: last 10000 measured samples; max: lifetime; accepted stages exclude first 30 sends per acquisition"]
    }
}

struct SamplerOptions {
    var windowID: CGWindowID?, duration: Double?
    var ffmpeg: String?
    init(_ args: [String]) throws {
        var remaining = args
        // Retain the former bounded diagnostic invocation; ordinary foreground use needs no arguments.
        if args.count == 2 && !args[0].hasPrefix("--") { remaining = ["--window-id",args[0],"--duration",args[1]] }
        while !remaining.isEmpty {
            let option = remaining.removeFirst()
            try samplerRequire(!remaining.isEmpty,"Missing option value")
            let value = remaining.removeFirst()
            if option == "--window-id", windowID == nil, let id = UInt32(value), id > 0 { windowID = id }
            else if option == "--duration", duration == nil, let seconds = Double(value), seconds.isFinite, seconds > 0, seconds <= 1800 { duration = seconds }
            else if option == "--ffmpeg", ffmpeg == nil, !value.isEmpty { ffmpeg = value }
            else { throw SamplerFailure(description:"Invalid or repeated option: \(option)") }
        }
    }
}

/// Transition-only terminal output. Rapid frame-driven alternation is summarized at most once
/// per second; no per-frame logs or status files. Final counters retain every transition/reason.
final class SamplerConsole {
    private var last = "", pending = "", next = 0.0
    let write: (String) -> Void
    init(write: @escaping (String) -> Void = { print($0); fflush(stdout) }) { self.write = write }
    func observe(_ state: String, now: Double = samplerClock(), force: Bool = false) {
        pending = state
        guard state != last, force || now >= next else { return }
        write(state); last = state; next = now+1
    }
    func flush(now: Double = samplerClock()) { observe(pending,now:now) }
}

#if !SAMPLER_TEST
@main struct SamplerLive {
    static var stopping: Int32 = 0
    static func main() {
        if CommandLine.arguments.dropFirst().elementsEqual(["--help"]) {
            print("SamplerLive [--ffmpeg executable-path] [--duration seconds] [--window-id diagnostic-ID]\nNo arguments: resolve FFmpeg through this Terminal's PATH, wait for current Bitwig/Sampler context, select one current window, run until Ctrl-C. No service or status file.")
            return
        }
        do { try run() }
        catch { fputs("Sampler producer stopped: \(error)\n",stderr); exit(1) }
    }
    static func run() throws {
        let options = try SamplerOptions(Array(CommandLine.arguments.dropFirst()))
        signal(SIGINT) { _ in SamplerLive.stopping = 1 }; signal(SIGTERM) { _ in SamplerLive.stopping = 1 }
        let ffmpeg = try SamplerFFmpeg.resolve(explicit:options.ffmpeg)
        print("FFmpeg executable: \(ffmpeg.path)")
        let runtime = try SamplerRuntime(explicitID:options.windowID,ffmpeg:ffmpeg)
        defer { runtime.close() }
        let console = SamplerConsole()
        runtime.onState = { state in
            // Non-frame lifecycle events must not disappear between consecutive loop steps.
            console.observe(state,force:state.hasPrefix("Starting FFmpeg") || state.hasPrefix("Waiting for the first") || state.hasPrefix("Locating Sampler") || state.hasPrefix("Source geometry changed") || state.hasPrefix("Stopped") || state.hasPrefix("FFmpeg/source failure"))
        }
        console.observe(runtime.state)
        let deadline = options.duration.map { samplerClock()+$0 } ?? .infinity
        while stopping == 0 && !runtime.closed && samplerClock() < deadline {
            let delay = autoreleasepool { runtime.step() }
            console.flush()
            if delay > 0 { usleep(useconds_t(delay*1_000_000)) }
        }
        runtime.close()
        print(String(decoding:try JSONSerialization.data(withJSONObject:runtime.summary,options:[.sortedKeys]),as:UTF8.self))
        if let failure = runtime.failure { throw SamplerFailure(description:failure) }
    }
}
#endif
