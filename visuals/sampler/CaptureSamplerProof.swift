import AppKit
import Darwin
import Foundation
import ImageIO

/// Bounded local proof, not a background service or Push producer. FFmpeg owns acquisition
/// and final crop/fit. Window metadata limits recognition work; it does not locate the device.
@main struct CaptureSamplerProof {
    struct Failure: Error, CustomStringConvertible { let description: String }
    struct WindowState: Equatable {
        let id: CGWindowID
        let pid: pid_t
        let bounds: CGRect
        let occluders: [CGRect]
    }

    static func state(_ id: CGWindowID) throws -> WindowState {
        let pids = Set(NSRunningApplication.runningApplications(withBundleIdentifier: "com.bitwig.studio")
            .map(\.processIdentifier))
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
            as? [[String: Any]] ?? []
        var occluders: [CGRect] = []
        for window in windows {
            guard let number = window[kCGWindowNumber as String] as? UInt32,
                  let dictionary = window[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: dictionary as CFDictionary) else { continue }
            if number == id {
                guard let pid = window[kCGWindowOwnerPID as String] as? pid_t, pids.contains(pid),
                      window[kCGWindowLayer as String] as? Int == 0 else {
                    throw Failure(description: "Selected window is not an ordinary current Bitwig window")
                }
                return WindowState(id: id, pid: pid, bounds: bounds, occluders: occluders)
            }
            // FFmpeg capture_cursor=0 omits the system pointer. Other software overlays remain
            // real possible occluders; do not waive them just because they belong to a tool.
            if (window[kCGWindowAlpha as String] as? Double ?? 1) > 0,
               window[kCGWindowLayer as String] as? Int != Int(CGWindowLevelForKey(.cursorWindow)) {
                occluders.append(bounds)
            }
        }
        throw Failure(description: "Selected Bitwig window is not on screen")
    }

    static func ffmpeg(_ arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
        process.arguments = ["-hide_banner", "-loglevel", "error", "-nostdin", "-n"] + arguments
        process.standardInput = FileHandle.nullDevice
        try process.run()
        let deadline = ProcessInfo.processInfo.systemUptime + 15
        while process.isRunning && ProcessInfo.processInfo.systemUptime < deadline {
            Thread.sleep(forTimeInterval: 0.02)
        }
        if process.isRunning {
            process.terminate() // Only this proof's FFmpeg child, never Bitwig.
            let stopDeadline = ProcessInfo.processInfo.systemUptime + 1
            while process.isRunning && ProcessInfo.processInfo.systemUptime < stopDeadline {
                Thread.sleep(forTimeInterval: 0.02)
            }
            if process.isRunning { kill(process.processIdentifier, SIGKILL) }
            process.waitUntilExit()
            throw Failure(description: "FFmpeg one-frame operation exceeded 15 seconds")
        }
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw Failure(description: "FFmpeg operation failed") }
    }

    static func run() throws {
        guard CommandLine.arguments.count == 3, let id = UInt32(CommandLine.arguments[1]) else {
            throw Failure(description: "usage: CaptureSamplerProof explicit-bitwig-window-id existing-private-output-directory")
        }
        let directory = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
        var attributes = stat()
        guard lstat(directory.path, &attributes) == 0,
              attributes.st_mode & S_IFMT == S_IFDIR, attributes.st_mode & 0o777 == 0o700,
              attributes.st_uid == getuid() else {
            throw Failure(description: "Output directory must be a real current-user-owned 0700 directory")
        }
        let raw = directory.appendingPathComponent("ffmpeg-source.png")
        let output = directory.appendingPathComponent("sampler-fit.png")
        // The proof deliberately supports one attached display, not an unverified device-index map.
        var displayCount: UInt32 = 0
        guard CGGetActiveDisplayList(0, nil, &displayCount) == .success, displayCount == 1 else {
            throw Failure(description: "Local FFmpeg proof requires exactly one active display")
        }
        let display = CGDisplayBounds(CGMainDisplayID())
        let before = try state(id)
        guard display.contains(before.bounds) else { throw Failure(description: "Bitwig window is partly off display") }
        try ffmpeg(["-f", "avfoundation", "-capture_cursor", "0", "-capture_mouse_clicks", "0",
                    "-pixel_format", "bgr0", "-framerate", "30", "-i", "Capture screen 0:none",
                    "-frames:v", "1", "-update", "1", raw.path])
        let after = try state(id)
        guard before == after else { throw Failure(description: "Window/occlusion geometry changed during acquisition; retry after it settles") }
        guard let source = CGImageSourceCreateWithURL(raw as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw Failure(description: "FFmpeg image decode failed")
        }
        let scaleX = Double(image.width) / display.width, scaleY = Double(image.height) / display.height
        guard scaleX.isFinite, scaleY.isFinite, abs(scaleX-scaleY) < 0.0001 else {
            throw Failure(description: "Display point/image pixel scale is not uniform")
        }
        let search = CGRect(x: (before.bounds.minX-display.minX)*scaleX,
                            y: (before.bounds.minY-display.minY)*scaleY,
                            width: before.bounds.width*scaleX, height: before.bounds.height*scaleY).integral
        guard let windowImage = image.cropping(to: search) else { throw Failure(description: "Window search bounds invalid") }
        let start = DispatchTime.now().uptimeNanoseconds
        let landmarks = try SamplerLocator.landmarks(in: windowImage)
        let recognized = DispatchTime.now().uptimeNanoseconds
        let pixels = try ObservationPixels(windowImage)
        let decoded = DispatchTime.now().uptimeNanoseconds
        guard let body = SamplerLocator.locate(pixels, landmarks: landmarks) else {
            throw Failure(description: "No unique complete Sampler control-body match")
        }
        let located = DispatchTime.now().uptimeNanoseconds
        let x = Int(search.minX)+body.x, y = Int(search.minY)+body.y
        let screenBody = CGRect(x: Double(x)/scaleX+display.minX, y: Double(y)/scaleY+display.minY,
                                width: Double(body.width)/scaleX, height: Double(body.height)/scaleY)
        guard !after.occluders.contains(where: { $0.intersects(screenBody) }) else {
            throw Failure(description: "Another on-screen window overlaps the measured Sampler; no output")
        }
        let graph = "crop=w=\(body.width):h=\(body.height):x=\(x):y=\(y):exact=1,"
            + "scale=w=960:h=160:force_original_aspect_ratio=decrease:flags=lanczos,"
            + "pad=960:160:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1,format=rgba"
        try ffmpeg(["-i", raw.path, "-vf", graph, "-frames:v", "1", "-update", "1", output.path])
        let result: [String: Any] = [
            "windowID": id, "sourceWidth": image.width, "sourceHeight": image.height,
            "pointToPixelScale": scaleX,
            "windowSearch": ["x": search.minX, "y": search.minY, "width": search.width, "height": search.height],
            "device": ["centerX": Double(x)+Double(body.width)/2, "centerY": Double(y)+Double(body.height)/2,
                       "width": Double(body.width), "height": Double(body.height)],
            "recognitionMs": Double(recognized-start)/1e6, "pixelDecodeMs": Double(decoded-recognized)/1e6,
            "boundsMs": Double(located-decoded)/1e6,
            "filter": graph, "outputWidth": 960, "outputHeight": 160,
            "scope": "one local acquired frame; not live tracking or contextual Push acceptance"
        ]
        FileHandle.standardOutput.write(try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]))
        print()
    }

    static func main() {
        do { try run() }
        catch { fputs("Sampler proof refused: \(error)\n", stderr); exit(1) }
    }
}
