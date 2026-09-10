import AppKit
import Darwin
import Foundation

/// Producer-side reader only. The accepted V5A controller remains rendezvous/capability owner.
struct SamplerAuthority: Equatable {
    let generation: String, session: String?
    let port: Int, pid: Int32, started: Int64, capabilityFile: String
    static let root = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".pushwig/runtime")
    static func isHex(_ text: String, count: Int) -> Bool {
        text.utf8.count == count && text.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }
    static func privateDirectory(_ path: URL, modeRequired: Bool = true) throws -> Int32 {
        let fd = open(path.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        try samplerRequire(fd >= 0, "Private runtime directory unavailable")
        var attributes = stat()
        guard fstat(fd, &attributes) == 0, attributes.st_mode & S_IFMT == S_IFDIR,
              attributes.st_uid == getuid(), !modeRequired || attributes.st_mode & 0o777 == 0o700 else {
            Darwin.close(fd); throw SamplerFailure(description: "Unsafe runtime directory")
        }
        return fd
    }
    static func openChild(_ parent: Int32, _ name: String) throws -> Int32 {
        let fd = openat(parent, name, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        try samplerRequire(fd >= 0, "Private runtime directory missing")
        var attributes = stat()
        guard fstat(fd, &attributes) == 0, attributes.st_mode & S_IFMT == S_IFDIR,
              attributes.st_uid == getuid(), attributes.st_mode & 0o777 == 0o700 else {
            Darwin.close(fd); throw SamplerFailure(description: "Unsafe runtime ancestor")
        }
        return fd
    }
    static func runtime() throws -> Int32 {
        let home = try privateDirectory(FileManager.default.homeDirectoryForCurrentUser, modeRequired: false)
        defer { Darwin.close(home) }
        let pushwig = try openChild(home, ".pushwig"); defer { Darwin.close(pushwig) }
        return try openChild(pushwig, "runtime")
    }
    static func readFile(_ parent: Int32, _ name: String, cap: Int) throws -> Data {
        try samplerRequire(!name.contains("/") && !name.contains(".."), "Unsafe runtime basename")
        let fd = openat(parent, name, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK)
        try samplerRequire(fd >= 0, "Runtime file unavailable"); defer { Darwin.close(fd) }
        var before = stat()
        try samplerRequire(fstat(fd, &before) == 0 && before.st_mode & S_IFMT == S_IFREG &&
                           before.st_mode & 0o777 == 0o600 && before.st_uid == getuid() &&
                           before.st_size > 0 && before.st_size <= cap, "Unsafe or oversized runtime file")
        var bytes = Data(count: cap + 1)
        let count = bytes.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, cap + 1) }
        var after = stat()
        try samplerRequire(count == before.st_size && fstat(fd, &after) == 0 &&
                           after.st_size == before.st_size && after.st_mtimespec.tv_sec == before.st_mtimespec.tv_sec &&
                           after.st_mtimespec.tv_nsec == before.st_mtimespec.tv_nsec, "Runtime file changed or was incomplete")
        bytes.count = count
        return bytes
    }
    static func object(_ data: Data, keys: Set<String>) throws -> [String: Any] {
        guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SamplerFailure(description: "Invalid runtime object")
        }
        let text = String(decoding: data, as: UTF8.self)
        // These private schemas have flat ASCII keys; refuse escaped/duplicate/missing/unknown keys.
        let regex = try NSRegularExpression(pattern: #""([^"\\]*)"\s*:"#)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        let names = matches.map { String(text[Range($0.range(at: 1), in: text)!]) }
        try samplerRequire(Set(value.keys) == keys && names.count == keys.count && Set(names) == keys, "Runtime schema keys differ")
        return value
    }
    static func integer(_ object: [String: Any], _ key: String, _ range: ClosedRange<Int64>) throws -> Int64 {
        guard let value = object[key] as? NSNumber, CFGetTypeID(value) != CFBooleanGetTypeID(),
              value.doubleValue.isFinite, value.doubleValue == Double(value.int64Value), range.contains(value.int64Value) else {
            throw SamplerFailure(description: "Invalid runtime integer")
        }
        return value.int64Value
    }
    static func parse(_ manifest: Data, notice: Data) throws -> SamplerAuthority {
        let m = try object(manifest, keys: ["schema_version", "protocol_version", "transport", "port", "capability_file", "session_generation", "owner_pid", "owner_start_epoch_millis"])
        _ = try integer(m, "schema_version", 1...1); _ = try integer(m, "protocol_version", 1...1)
        guard m["transport"] as? String == "ipv4-loopback", let generation = m["session_generation"] as? String,
              isHex(generation, count: 32), let capability = m["capability_file"] as? String,
              capability == "capability-" + generation + ".hex" else { throw SamplerFailure(description: "Invalid ingress identity") }
        let n = try object(notice, keys: ["schema_version", "ingress_generation", "native_device", "context_session", "destination"])
        _ = try integer(n, "schema_version", 1...1)
        try samplerRequire(n["ingress_generation"] as? String == generation && n["native_device"] as? String == "bitwig-sampler" &&
                           n["destination"] as? [Int] == [238,25,484,114], "Context does not match current ingress/layout")
        let session = n["context_session"] as? String
        try samplerRequire(n["context_session"] is NSNull || session.map { isHex($0, count: 32) && $0 != String(repeating: "0", count: 32) } == true, "Invalid context session")
        return SamplerAuthority(generation: generation, session: session,
            port: Int(try integer(m, "port", 1024...65535)), pid: Int32(try integer(m, "owner_pid", 1...Int64(Int32.max))),
            started: try integer(m, "owner_start_epoch_millis", 1...Int64.max), capabilityFile: capability)
    }
    static func read() throws -> SamplerAuthority {
        let runtime = try runtime(); defer { Darwin.close(runtime) }
        let ingress = try openChild(runtime, "external-raster-v1"); defer { Darwin.close(ingress) }
        let manifest = try readFile(ingress, "current.json", cap: 4096)
        let m = try object(manifest, keys: ["schema_version", "protocol_version", "transport", "port", "capability_file", "session_generation", "owner_pid", "owner_start_epoch_millis"])
        guard let generation = m["session_generation"] as? String, isHex(generation, count: 32) else { throw SamplerFailure(description: "Invalid ingress generation") }
        let notices = try openChild(runtime, "sampler-lens-v1"); defer { Darwin.close(notices) }
        let authority = try parse(manifest, notice: readFile(notices, generation + ".json", cap: 1024))
        try samplerRequire(NSRunningApplication(processIdentifier: authority.pid)?.bundleIdentifier == "com.bitwig.studio" &&
                           sampler_process_start_millis(authority.pid) == authority.started, "Ingress owner no longer matches Bitwig process/start")
        try samplerRequire(try readFile(ingress, "current.json", cap: 4096) == manifest, "Ingress changed during discovery")
        return authority
    }
    func capability() throws -> [UInt8] {
        let runtime = try Self.runtime(); defer { Darwin.close(runtime) }
        let ingress = try Self.openChild(runtime, "external-raster-v1"); defer { Darwin.close(ingress) }
        var file = try Self.readFile(ingress, capabilityFile, cap: 128)
        defer { file.resetBytes(in: file.startIndex..<file.endIndex) }
        try samplerRequire(file.count >= 64 && file.dropFirst(64).allSatisfy { [9,10,11,12,13,32].contains($0) }, "Invalid capability file")
        var result = [UInt8](); result.reserveCapacity(32)
        for i in stride(from: 0, to: 64, by: 2) {
            guard let byte = UInt8(String(decoding: file[i..<i+2], as: UTF8.self), radix: 16) else { throw SamplerFailure(description: "Invalid capability encoding") }
            result.append(byte)
        }
        return result
    }
}

/// Existing v1 framing; one connection per context ticket, complete-message deadline 250 ms.
final class SamplerConnection {
    let authority: SamplerAuthority
    private var fd: Int32 = -1, sequence: UInt64 = 0
    private var header = [UInt8](repeating: 0, count: 80)
    private var hasImage = false
    // Dependencies separate filesystem/process validation tests from the real socket/framing tests.
    // The command-line producer supplies neither override.
    init(_ authority: SamplerAuthority, capabilityReader: (() throws -> [UInt8])? = nil,
         authorityReader: () throws -> SamplerAuthority = SamplerAuthority.read) throws {
        self.authority = authority
        guard let session = authority.session else { throw SamplerFailure(description: "No Sampler context") }
        fd = socket(AF_INET, SOCK_STREAM, 0)
        do {
            try samplerRequire(fd >= 0 && fcntl(fd, F_SETFL, O_NONBLOCK) == 0, "Cannot create bounded producer socket")
            var one: Int32 = 1
            try samplerRequire(setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout.size(ofValue: one))) == 0, "Cannot configure producer socket")
            var address = sockaddr_in(); address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET); address.sin_port = UInt16(authority.port).bigEndian
            address.sin_addr.s_addr = inet_addr("127.0.0.1")
            let status = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { Darwin.connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
            if status != 0 {
                try samplerRequire(errno == EINPROGRESS, "Ingress connection refused")
                try writable(until: samplerClock() + 0.25)
                var error: Int32 = 0, size = socklen_t(MemoryLayout<Int32>.size)
                try samplerRequire(getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &size) == 0 && error == 0, "Ingress connection failed")
            }
            put(0, 4, 0x50575852); put(4, 2, 1); put(6, 2, 80)
            put(24, 8, UInt64(session.prefix(16), radix: 16)!); put(32, 8, UInt64(session.suffix(16), radix: 16)!)
            var capability = try capabilityReader?() ?? authority.capability()
            defer { _ = capability.withUnsafeMutableBytes { $0.initializeMemory(as: UInt8.self, repeating: 0) } }
            try samplerRequire(capability.count == 32 && (try authorityReader()) == authority, "Authority changed before authentication")
            try capability.withUnsafeBytes { try message(type: 1, sequence: 0, payload: $0) }
        } catch { close(); throw error }
    }
    deinit { close() }
    func close() {
        if fd >= 0 { Darwin.close(fd); fd = -1 }
        _ = header.withUnsafeMutableBytes { $0.initializeMemory(as: UInt8.self, repeating: 0) }
        hasImage = false
    }
    private func put(_ offset: Int, _ length: Int, _ value: UInt64) {
        for i in 0..<length { header[offset+i] = UInt8(truncatingIfNeeded: value >> (8*(length-1-i))) }
    }
    private func writable(until deadline: Double) throws {
        while samplerClock() < deadline {
            var item = pollfd(fd: fd, events: Int16(POLLOUT), revents: 0)
            let result = poll(&item, 1, max(1, Int32((deadline-samplerClock())*1000)))
            if result < 0 && errno == EINTR { continue }
            try samplerRequire(result >= 0 && item.revents & Int16(POLLERR | POLLHUP | POLLNVAL) == 0, "Ingress write failed")
            if item.revents & Int16(POLLOUT) != 0 { return }
        }
        throw SamplerFailure(description: "Ingress 250 ms message deadline expired")
    }
    private func send(_ bytes: UnsafeRawBufferPointer, until deadline: Double) throws {
        var offset = 0
        while offset < bytes.count {
            try samplerRequire(samplerClock() < deadline, "Ingress message deadline expired")
            let count = Darwin.send(fd, bytes.baseAddress!.advanced(by: offset), bytes.count-offset, 0)
            if count > 0 { offset += count }
            else if count < 0 && errno == EINTR { continue }
            else if count < 0 && (errno == EAGAIN || errno == EWOULDBLOCK) { try writable(until: deadline) }
            else { throw SamplerFailure(description: "Ingress socket closed") }
        }
    }
    private func message(type: UInt64, sequence: UInt64, payload: UnsafeRawBufferPointer) throws {
        put(8,4,type); put(16,4,type == 2 ? 1 : 0); put(40,8,sequence)
        for offset in stride(from: 48, through: 64, by: 4) { put(offset,4,0) }
        if type == 2 { for (offset,value) in [(48,238),(52,25),(56,484),(60,114),(64,1936)] { put(offset,4,UInt64(value)) } }
        put(68,4,UInt64(payload.count))
        let deadline = samplerClock() + 0.25
        do {
            try header.withUnsafeBytes { try send($0, until: deadline) }
            try send(payload, until: deadline)
        } catch { close(); throw error }
    }
    func frame(_ bytes: UnsafeRawBufferPointer) throws {
        try samplerRequire(bytes.count == 484*114*4 && sequence < UInt64(Int64.max), "Invalid center output")
        sequence += 1; try message(type: 2, sequence: sequence, payload: bytes); hasImage = true
    }
    func clear() throws {
        if !hasImage { return }
        try samplerRequire(sequence < UInt64(Int64.max), "Ingress sequence exhausted")
        sequence += 1; try message(type: 3, sequence: sequence, payload: UnsafeRawBufferPointer(start: nil, count: 0)); hasImage = false
    }
}
