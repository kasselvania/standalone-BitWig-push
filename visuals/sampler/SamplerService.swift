import Darwin
import Foundation

/// Local producer custody only. Never writes the Java-owned ingress/context directories.
final class SamplerService {
    private let directory: Int32, lock: Int32
    private(set) var closed = false
    static func root() throws -> Int32 {
        let home = try SamplerAuthority.privateDirectory(FileManager.default.homeDirectoryForCurrentUser,modeRequired:false)
        defer { Darwin.close(home) }
        func child(_ parent: Int32, _ name: String) throws -> Int32 {
            let result = mkdirat(parent,name,0o700)
            try samplerRequire(result == 0 || errno == EEXIST,"Cannot create private producer directory")
            return try SamplerAuthority.openChild(parent,name)
        }
        let pushwig = try child(home,".pushwig"); defer { Darwin.close(pushwig) }
        return try child(pushwig,"sampler-producer-v1")
    }
    init(directory supplied: Int32? = nil) throws {
        directory = try supplied.map { fd in
            let copy = fcntl(fd,F_DUPFD_CLOEXEC,0)
            try samplerRequire(copy >= 0,"Cannot duplicate producer directory")
            return copy
        } ?? Self.root()
        lock = openat(directory,"owner.lock",O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK,0o600)
        var attributes = stat()
        guard lock >= 0, fstat(lock,&attributes) == 0, attributes.st_mode & S_IFMT == S_IFREG,
              attributes.st_mode & 0o777 == 0o600, attributes.st_uid == getuid(), attributes.st_nlink == 1,
              flock(lock,LOCK_EX | LOCK_NB) == 0 else {
            if lock >= 0 { Darwin.close(lock) }; Darwin.close(directory)
            throw SamplerFailure(description:"Another Sampler producer is running, or producer lock is unsafe")
        }
    }
    deinit { close() }
    func close() {
        guard !closed else { return }; closed = true
        Darwin.close(lock); Darwin.close(directory)
    }
    func publish(_ summary: [String:Any]) throws {
        try samplerRequire(!closed,"Producer status is closed")
        var record = summary
        record["producerPID"] = getpid()
        record["producerStartMillis"] = sampler_process_start_millis(getpid())
        record["observedAt"] = ISO8601DateFormatter().string(from:Date())
        let bytes = try JSONSerialization.data(withJSONObject:record,options:[.prettyPrinted,.sortedKeys])
        try samplerRequire(bytes.count <= 16384,"Producer status exceeds its bound")
        // A fresh temporary basename avoids treating unknown crash leftovers as owned files.
        let name = ".status-"+UUID().uuidString+".tmp"
        let fd = openat(directory,name,O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,0o600)
        try samplerRequire(fd >= 0,"Cannot write private producer status")
        defer { Darwin.close(fd); unlinkat(directory,name,0) }
        try bytes.withUnsafeBytes { raw in
            var offset = 0
            while offset < raw.count {
                let n = Darwin.write(fd,raw.baseAddress!.advanced(by:offset),raw.count-offset)
                if n < 0 && errno == EINTR { continue }
                try samplerRequire(n > 0,"Producer status write failed"); offset += n
            }
        }
        try samplerRequire(renameat(directory,name,directory,"status.json") == 0,"Producer status publication failed")
    }
}
