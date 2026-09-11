import CoreMedia
import Darwin
import Foundation

struct SamplerFailure: Error, CustomStringConvertible { let description: String }
func samplerRequire(_ condition: Bool, _ message: String) throws {
    if !condition { throw SamplerFailure(description: message) }
}
func samplerClock() -> Double { CMTimeGetSeconds(CMClockGetTime(CMClockGetHostTimeClock())) }

enum SamplerFFmpeg {
    static func resolve(explicit: String? = nil, path: String? = ProcessInfo.processInfo.environment["PATH"]) throws -> URL {
        func executable(_ name: String) -> URL? {
            guard !name.isEmpty else { return nil }
            let url = URL(fileURLWithPath:name).standardizedFileURL.resolvingSymlinksInPath()
            var info = stat()
            guard stat(url.path,&info) == 0, info.st_mode & S_IFMT == S_IFREG,
                  access(url.path,X_OK) == 0 else { return nil }
            return url
        }
        if let explicit {
            guard let url = executable(explicit) else { throw SamplerFailure(description:"--ffmpeg must name an executable regular file: \(explicit)") }
            return url
        }
        for directory in (path ?? "").split(separator:":",omittingEmptySubsequences:false) {
            if let url = executable(URL(fileURLWithPath:directory.isEmpty ? "." : String(directory)).appendingPathComponent("ffmpeg").path) { return url }
        }
        throw SamplerFailure(description:"ffmpeg is not executable on this Terminal's PATH; supply --ffmpeg /path/to/ffmpeg")
    }
}

/// One synchronous reader, one reusable frame, bounded timestamp metadata. No frame FIFO.
/// Anonymous AF_UNIX byte stream: no port, filesystem socket or extra worker. Fixed 256 KiB
/// kernel buffers avoid Darwin pipe's small-chunk handoff bottleneck for large raw frames.
/// FFmpeg -copyts/showinfo exposes source PTS, not pipe-read time disguised as acquisition time.
final class FFmpegSamplerStream {
    struct StartupFailure: Error, CustomStringConvertible { let description: String }
    static let firstFrameTimeout = 5.0
    static let diagnosticCapacity = 4096
    private var diagnosticTail = Data()
    private var firstFrameDeadline = Double.infinity
    private let startupTimeout: Double
    var processID: Int32 { child.processIdentifier }
    var diagnosticExcerpt: String {
        let bytes = (diagnosticTail + lines).suffix(Self.diagnosticCapacity)
        let text = String(decoding:bytes,as:UTF8.self).unicodeScalars.map { scalar -> String in
            scalar.value >= 32 && scalar.value != 127 || scalar == "\n" || scalar == "\t" ? String(scalar) : "?"
        }.joined()
        return text.isEmpty ? "(no stderr received)" : text
    }
    static let transportCapacity = 262144
    private(set) var transportBuffers = (receive: 0, send: 0)
    static func byteCount(width: Int, height: Int) throws -> Int {
        // The search is a subset of the already bounded physical-display acquisition. Do not
        // impose a smaller arbitrary width that rejects an ordinary large Bitwig window.
        try samplerRequire(width > 0 && height > 0 && width <= 8192 && height <= 4320,
                           "FFmpeg window search exceeds the 8192×4320 display bound")
        return width * height * 4
    }
    struct Frame {
        let index: Int, width: Int, height: Int
        let captured: Double
        let bytes: UnsafeRawBufferPointer // Borrowed until next nextFrame()/close; no async retention.
    }
    struct Stamp { let index: Int, pts: Int64, width: Int, height: Int }
    private let child = Process(), diagnostics = Pipe()
    private let videoRead: FileHandle, videoWrite: FileHandle
    private var storage: UnsafeMutableRawPointer?
    private var length = 0, used = 0, width = 0, height = 0, frameIndex = 0
    private var lines = Data(), stamps: [Stamp] = []
    private var timebase: Double?
    private let scratch = UnsafeMutableRawPointer.allocate(byteCount: 8192, alignment: 64)
    private var stopped = false, launched = false
    private static let stampPattern = try! NSRegularExpression(pattern: #"\bn:\s*(\d+)\s+pts:\s*(-?\d+).*\bs:(\d+)x(\d+)\b"#)
    private static let timePattern = try! NSRegularExpression(pattern: #"config in time_base: (\d+)/(\d+)"#)

    init(input: [String], filter: String, executable: URL? = nil, startupTimeout: Double = FFmpegSamplerStream.firstFrameTimeout) throws {
        self.startupTimeout = startupTimeout
        try samplerRequire(startupTimeout.isFinite && startupTimeout > 0 && startupTimeout <= Self.firstFrameTimeout,"Invalid first-frame deadline")
        var sockets: [Int32] = [-1, -1]
        try samplerRequire(socketpair(AF_UNIX, SOCK_STREAM, 0, &sockets) == 0, "Cannot create local FFmpeg byte transport")
        videoRead = FileHandle(fileDescriptor: sockets[0], closeOnDealloc: true)
        videoWrite = FileHandle(fileDescriptor: sockets[1], closeOnDealloc: true)
        var capacity = Int32(Self.transportCapacity)
        try samplerRequire(setsockopt(sockets[0], SOL_SOCKET, SO_RCVBUF, &capacity, socklen_t(MemoryLayout<Int32>.size)) == 0 &&
                           setsockopt(sockets[1], SOL_SOCKET, SO_SNDBUF, &capacity, socklen_t(MemoryLayout<Int32>.size)) == 0,
                           "Cannot bound local FFmpeg byte transport")
        for fd in sockets {
            try samplerRequire(fcntl(fd, F_SETFD, FD_CLOEXEC) == 0, "Cannot isolate FFmpeg transport descriptors")
        }
        var receive: Int32 = 0, send: Int32 = 0
        var size = socklen_t(MemoryLayout<Int32>.size)
        try samplerRequire(getsockopt(sockets[0], SOL_SOCKET, SO_RCVBUF, &receive, &size) == 0 &&
                           getsockopt(sockets[1], SOL_SOCKET, SO_SNDBUF, &send, &size) == 0 &&
                           receive > 0 && receive <= capacity && send > 0 && send <= capacity,
                           "Local FFmpeg buffer bound was not applied")
        transportBuffers = (Int(receive), Int(send))
        child.executableURL = try executable ?? SamplerFFmpeg.resolve()
        child.arguments = ["-hide_banner", "-nostdin", "-loglevel", "info", "-nostats", "-copyts", "-filter_threads", "1"]
            + input + ["-an", "-vf", filter + ",format=bgr0,showinfo=checksum=0", "-fps_mode", "passthrough",
                       "-threads", "1", "-c:v", "rawvideo", "-thread_queue_size", "1",
                       "-avioflags", "direct", "-f", "rawvideo", "pipe:1"]
        child.standardInput = FileHandle.nullDevice
        child.standardOutput = videoWrite; child.standardError = diagnostics
        try child.run()
        launched = true
        firstFrameDeadline = samplerClock()+startupTimeout
        videoWrite.closeFile(); diagnostics.fileHandleForWriting.closeFile()
        for fd in [videoRead.fileDescriptor, diagnostics.fileHandleForReading.fileDescriptor] {
            try samplerRequire(fcntl(fd, F_SETFL, O_NONBLOCK) == 0, "Cannot configure bounded FFmpeg reads")
        }
    }
    deinit { close(); scratch.deallocate(); storage?.deallocate() }
    func close() {
        if stopped { return }; stopped = true
        videoRead.closeFile(); diagnostics.fileHandleForReading.closeFile()
        if child.isRunning {
            child.terminate() // Only our FFmpeg child. Never Bitwig.
            let deadline = samplerClock() + 1
            while child.isRunning && samplerClock() < deadline { usleep(10_000) }
            if child.isRunning { kill(child.processIdentifier, SIGKILL) }
        }
        if launched { child.waitUntilExit() }
    }
    private func groups(_ regex: NSRegularExpression, _ line: String) -> [String]? {
        let range = NSRange(line.startIndex..., in: line)
        guard let result = regex.firstMatch(in: line, range: range) else { return nil }
        return (1..<result.numberOfRanges).map { String(line[Range(result.range(at: $0), in: line)!]) }
    }
    private func readDiagnostics() throws {
        let count = Darwin.read(diagnostics.fileHandleForReading.fileDescriptor, scratch, 8192)
        if count < 0 && (errno == EAGAIN || errno == EINTR) { return }
        try samplerRequire(count > 0, "FFmpeg closed its metadata pipe")
        lines.append(scratch.assumingMemoryBound(to: UInt8.self), count: count)
        try samplerRequire(lines.count <= 32768, "Unbounded FFmpeg diagnostic line")
        try parseDiagnostics()
    }
    private func parseDiagnostics() throws {
        // Bound metadata independently of pipe read chunking. Backpressure stderr when full;
        // several showinfo lines arriving in one read must not falsely fail a healthy stream.
        while stamps.count < 4, let end = lines.firstIndex(of: 10) {
            let line = String(decoding: lines[..<end], as: UTF8.self)
            lines.removeSubrange(...end)
            // Keep diagnostics, not an ever-growing per-frame showinfo log.
            if !line.contains("Parsed_showinfo_") {
                diagnosticTail.append(contentsOf:(line+"\n").utf8)
                if diagnosticTail.count > Self.diagnosticCapacity { diagnosticTail = Data(diagnosticTail.suffix(Self.diagnosticCapacity)) }
            }
            if let parts = groups(Self.timePattern, line), let n = Double(parts[0]), let d = Double(parts[1]) {
                try samplerRequire(n > 0 && d > 0, "Invalid source timebase")
                let value = n / d
                try samplerRequire(timebase == nil || timebase == value, "Source timebase changed")
                timebase = value
            }
            if let parts = groups(Self.stampPattern, line), let index = Int(parts[0]), let pts = Int64(parts[1]),
               let w = Int(parts[2]), let h = Int(parts[3]) {
                try samplerRequire(line.contains("fmt:bgr0"), "Unsupported FFmpeg window-search format")
                let byteCount = try Self.byteCount(width: w, height: h)
                if storage == nil {
                    width = w; height = h; length = byteCount
                    storage = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 64)
                }
                try samplerRequire(w == width && h == height && stamps.count < 4,
                                   "FFmpeg handoff refused: \(w)x\(h) versus \(width)x\(height); \(stamps.count) pending timestamps at frame \(index)")
                stamps.append(Stamp(index: index, pts: pts, width: w, height: h))
            }
        }
    }
    /// Short polls allow caller to revoke context/source without waiting behind capture.
    func nextFrame(timeout: Double = 0.1) throws -> Frame? {
        do { return try receiveFrame(timeout:timeout) }
        catch let error as StartupFailure { throw error }
        catch { throw SamplerFailure(description:"\(error)\nFFmpeg stderr (bounded):\n\(diagnosticExcerpt)") }
    }
    private func checkFirstFrameDeadline() throws {
        if frameIndex == 0 && samplerClock() >= firstFrameDeadline {
            let message = "FFmpeg/source failure: no complete first frame within \(startupTimeout) seconds; locator was not run.\nFFmpeg stderr (bounded):\n\(diagnosticExcerpt)"
            close()
            throw StartupFailure(description:message)
        }
    }
    private func receiveFrame(timeout: Double) throws -> Frame? {
        try samplerRequire(!stopped, "FFmpeg stream is closed")
        try checkFirstFrameDeadline()
        let deadline = samplerClock() + timeout
        var fds = [pollfd(fd: diagnostics.fileHandleForReading.fileDescriptor, events: 0, revents: 0),
                   pollfd(fd: videoRead.fileDescriptor, events: 0, revents: 0)]
        while samplerClock() < deadline {
            try checkFirstFrameDeadline()
            try parseDiagnostics()
            if length > 0 && used == length && !stamps.isEmpty, let timebase {
                let stamp = stamps.removeFirst()
                try samplerRequire(stamp.index == frameIndex, "FFmpeg frame/timestamp correspondence lost")
                frameIndex += 1; used = 0
                return Frame(index: stamp.index, width: width, height: height,
                             captured: Double(stamp.pts) * timebase,
                             bytes: UnsafeRawBufferPointer(start: storage, count: length))
            }
            // Drain immediately available video without polling/allocating a descriptor array
            // for every chunk. Poll only when the nonblocking read would wait.
            if let storage, used < length {
                let count = Darwin.read(fds[1].fd, storage.advanced(by: used), length-used)
                if count > 0 { used += count; continue }
                if count == 0 { throw SamplerFailure(description: "Incomplete FFmpeg frame") }
                if errno == EINTR { continue }
                try samplerRequire(errno == EAGAIN || errno == EWOULDBLOCK, "FFmpeg video read failed")
            }
            fds[0].events = stamps.count < 4 ? Int16(POLLIN) : 0
            fds[1].events = length > used ? Int16(POLLIN) : 0
            fds[0].revents = 0; fds[1].revents = 0
            let wait = max(1, min(50, Int((deadline - samplerClock()) * 1000)))
            let ready = poll(&fds, 2, Int32(wait))
            if ready < 0 && errno == EINTR { continue }
            try samplerRequire(ready >= 0, "FFmpeg pipe poll failed")
            if fds[0].revents & Int16(POLLIN) != 0 { try readDiagnostics() }
            if fds[1].revents & Int16(POLLIN) != 0, let storage, used < length {
                let readCount = Darwin.read(fds[1].fd, storage.advanced(by: used), length - used)
                if readCount > 0 { used += readCount }
                else if readCount < 0 && (errno == EAGAIN || errno == EINTR) { continue }
                else { throw SamplerFailure(description: "Incomplete FFmpeg frame") }
            }
            if fds.contains(where: { $0.revents & Int16(POLLERR | POLLNVAL) != 0 }) {
                throw SamplerFailure(description: "FFmpeg pipe failed")
            }
            if fds[1].revents & Int16(POLLHUP) != 0 && fds[1].revents & Int16(POLLIN) == 0 && used != length {
                throw SamplerFailure(description: "FFmpeg acquisition ended")
            }
        }
        try checkFirstFrameDeadline()
        return nil
    }
}
