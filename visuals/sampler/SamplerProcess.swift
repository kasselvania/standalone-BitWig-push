import Darwin
import Foundation

/// Current kernel PID/birth/executable evidence. This is application identity, not device identity.
struct SamplerProcess: Equatable {
    let pid: Int32, started: Int64, executable: String
    static func read(_ pid: Int32) throws -> SamplerProcess {
        let started = sampler_process_start_millis(pid)
        var path = [CChar](repeating: 0, count: 4096)
        try samplerRequire(started > 0 && sampler_process_executable(pid, &path, path.count) != 0 &&
                           sampler_process_start_millis(pid) == started, "Process exited or identity changed")
        return SamplerProcess(pid: pid, started: started, executable: String(cString: path))
    }
    static func bundleIdentifier(for executable: String) -> String? {
        let file = URL(fileURLWithPath: executable).standardizedFileURL
        let macOS = file.deletingLastPathComponent(), contents = macOS.deletingLastPathComponent()
        let app = contents.deletingLastPathComponent()
        guard macOS.lastPathComponent == "MacOS", contents.lastPathComponent == "Contents",
              app.pathExtension == "app", let bundle = Bundle(url: app),
              bundle.executableURL?.resolvingSymlinksInPath() == file.resolvingSymlinksInPath() else { return nil }
        return bundle.bundleIdentifier
    }
    func requireBitwig(started expected: Int64) throws {
        try samplerRequire(started == expected && Self.bundleIdentifier(for: executable) == "com.bitwig.studio",
                           "Ingress owner PID/start/executable is not current Bitwig")
    }
}
