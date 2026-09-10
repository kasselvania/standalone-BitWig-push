import CoreGraphics
import Darwin
import Foundation

/// Generated, bounded peer for the real production protocol client. Never opens port 45291.
private final class SamplerTestPeer {
    struct Message { let type: Int, session: Data, payload: Data }
    private let listener: Int32, lock = NSLock(), done = DispatchSemaphore(value:0)
    private var stopped = false, messages: [Message] = [], sockets: [Int32] = []
    let port: Int
    init() throws {
        listener = socket(AF_INET,SOCK_STREAM,0)
        try samplerRequire(listener >= 0,"Test socket")
        let socket = listener
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET); address.sin_addr.s_addr = inet_addr("127.0.0.1")
        let result = withUnsafePointer(to:&address) { $0.withMemoryRebound(to:sockaddr.self,capacity:1) { Darwin.bind(socket,$0,socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        guard result == 0 && listen(listener,4) == 0 else { Darwin.close(listener); throw SamplerFailure(description:"Test bind") }
        var size = socklen_t(MemoryLayout<sockaddr_in>.size)
        _ = withUnsafeMutablePointer(to:&address) { $0.withMemoryRebound(to:sockaddr.self,capacity:1) { getsockname(socket,$0,&size) } }
        port = Int(UInt16(bigEndian:address.sin_port))
        DispatchQueue.global().async { self.serve() }
    }
    private func read(_ fd: Int32, _ count: Int) -> Data? {
        var bytes = Data(count:count), offset = 0
        while offset < count {
            let n = bytes.withUnsafeMutableBytes { Darwin.read(fd,$0.baseAddress!.advanced(by:offset),count-offset) }
            if n < 0 && errno == EINTR { continue }
            if n <= 0 { return nil }; offset += n
        }
        return bytes
    }
    private func serve() {
        defer { done.signal() }
        while true {
            lock.lock(); let stop = stopped; lock.unlock(); if stop { return }
            var ready = pollfd(fd:listener,events:Int16(POLLIN),revents:0)
            guard poll(&ready,1,50) > 0 else { continue }
            let fd = accept(listener,nil,nil); if fd < 0 { continue }
            lock.lock(); sockets.append(fd); lock.unlock()
            while let header = read(fd,80) {
                func number(_ offset: Int) -> Int { header[offset..<offset+4].reduce(0) { ($0 << 8) | Int($1) } }
                let count = number(68)
                if count > 614400 { break }
                guard let payload = read(fd,count) else { break }
                let message = Message(type:number(8),session:header.subdata(in:24..<40),payload:payload)
                lock.lock(); messages.append(message); lock.unlock()
            }
            lock.lock(); sockets.removeAll { $0 == fd }; Darwin.close(fd); lock.unlock()
        }
    }
    var received: [Message] { lock.lock(); defer { lock.unlock() }; return messages }
    func close() throws {
        lock.lock(); stopped = true
        for fd in sockets { shutdown(fd,SHUT_RDWR) }
        lock.unlock()
        try samplerRequire(done.wait(timeout:.now()+2) == .success,"Generated peer closes boundedly")
        Darwin.close(listener)
    }
}

extension TestSamplerLive {
    static func dailyOptionsAndSelection() throws {
        let automatic = try SamplerOptions([])
        try check(automatic.windowID == nil && automatic.duration == nil,"Ordinary invocation needs no transient window ID or time limit")
        let diagnostic = try SamplerOptions(["42","30"])
        try check(diagnostic.windowID == 42 && diagnostic.duration == 30,"Legacy bounded diagnostic retained")
        for args in [["--duration","nan"],["--duration","inf"],["--duration","0"],["--duration","1801"],
                     ["--window-id","0"],["--window-id","1","--window-id","2"],["--duration","1","--duration","2"],["--unknown","1"],["--duration"]] {
            try refuses { _ = try SamplerOptions(args) }
        }
        let a = SamplerWindow.Candidate(id:42,pid:123,layer:0,bounds:CGRect(x:30,y:40,width:1000,height:800))
        let b = SamplerWindow.Candidate(id:43,pid:123,layer:0,bounds:a.bounds.offsetBy(dx:80,dy:10))
        let foreign = SamplerWindow.Candidate(id:44,pid:124,layer:0,bounds:a.bounds)
        let panel = SamplerWindow.Candidate(id:45,pid:123,layer:3,bounds:a.bounds)
        try check(try SamplerWindow.select([foreign,panel,a],ownerPID:123) == a,"Unique actual owner window; not first item")
        try refuses { _ = try SamplerWindow.select([a,b],ownerPID:123) }
        try refuses { _ = try SamplerWindow.select([foreign,panel],ownerPID:123) }
        try check(try SamplerWindow.select([a,b],ownerPID:123,explicitID:43) == b,"Explicit diagnostic disambiguation")
        try refuses { _ = try SamplerWindow.select([foreign],ownerPID:123,explicitID:44) }
        for rectangle in [CGRect.zero,CGRect.null,CGRect.infinite,CGRect(x:0,y:0,width:Double.nan,height:10)] {
            try refuses { _ = try SamplerWindow.select([.init(id:42,pid:123,layer:0,bounds:rectangle)],ownerPID:123) }
        }
        var timing = SamplerTiming()
        for i in 0..<25000 { timing.add(Double(i)) }
        let summary = timing.summary
        try check(summary["samples"] as? Int == 10000 && summary["totalSamples"] as? Int == 25000,"Untimed metrics retain fixed last-10000 storage")
        try check(summary["maxMs"] as? Double == 24999 && summary["p50Ms"] as? Double == 19999,"Bounded metrics preserve declared quantiles/lifetime maximum")
    }
    static func processAndCustody() throws {
        let current = try SamplerProcess.read(getpid())
        try check(current.started == sampler_process_start_millis(getpid()) && current.executable.hasSuffix("TestSamplerLive"),"Actual kernel executable and birth readback")
        try refuses { _ = try SamplerProcess.read(Int32.max) }
        try refuses { try current.requireBitwig(started:current.started) }
        try refuses { try current.requireBitwig(started:current.started+1) }
        try check(SamplerProcess.bundleIdentifier(for:"/usr/bin/true") == nil,"Unbundled tool is not Bitwig")
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("sampler-custody-"+UUID().uuidString)
        try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:false,attributes:[.posixPermissions:0o700])
        defer { try? FileManager.default.removeItem(at:folder) }
        let fd = try SamplerAuthority.privateDirectory(folder); defer { Darwin.close(fd) }
        let owner = try SamplerService(directory:fd)
        defer { owner.close() }
        try refuses { _ = try SamplerService(directory:fd) }
        try owner.publish(["state":"generated","accepted":3])
        let first = try SamplerAuthority.readFile(fd,"status.json",cap:16384)
        let parsed = try JSONSerialization.jsonObject(with:first) as! [String:Any]
        try check(parsed["state"] as? String == "generated" && parsed["producerPID"] as? Int32 == getpid(),"Private status identifies current producer without secrets")
        for i in 0..<100 { try owner.publish(["accepted":i]) }
        try check(Set(try FileManager.default.contentsOfDirectory(atPath:folder.path)) == ["owner.lock","status.json"],"Repeated status replacement does not accumulate files")
        try refuses { try owner.publish(["oversized":String(repeating:"x",count:17000)]) }
        owner.close(); owner.close()
        try refuses { try owner.publish([:]) }
        let restarted = try SamplerService(directory:fd); restarted.close()
        try check(true,"Closed singleton lock can be reacquired")
        try FileManager.default.removeItem(at:folder.appendingPathComponent("owner.lock"))
        try FileManager.default.createSymbolicLink(atPath:folder.appendingPathComponent("owner.lock").path,withDestinationPath:"status.json")
        try refuses { _ = try SamplerService(directory:fd) }
    }
    static func runtimeLifecycle() throws {
        let peer = try SamplerTestPeer(); defer { try? peer.close() }
        func authority(_ ticket: Int?, generation: String = String(repeating:"a",count:32)) -> SamplerAuthority {
            SamplerAuthority(generation:generation,session:ticket.map { String(format:"%032x",$0) },port:peer.port,pid:123,started:456,capabilityFile:"generated")
        }
        var current = authority(nil), available = true, ambiguous = false, connections = 0, acquisitions = 0
        var preHelloFailure = true, retainedLock: ObjectIdentifier?, returnedLock: ObjectIdentifier?
        let display = SamplerDisplay(id:5,index:0,bounds:CGRect(x:0,y:0,width:1600,height:1000),pixelWidth:1600,pixelHeight:1000)
        var source = SamplerWindow(id:42,pid:123,bounds:CGRect(x:50,y:50,width:320,height:160),occluders:[],display:display)
        var switchDuringLocate = false, oldCapture = false
        var inputs = SamplerRuntime.Inputs()
        inputs.authority = { try samplerRequire(available,"Generated absent controller"); return current }
        inputs.window = { pid,_ in
            try samplerRequire(pid == 123 && !ambiguous,"Generated ambiguity")
            return source
        }
        inputs.connect = { value in
            if preHelloFailure {
                preHelloFailure = false
                return try SamplerConnection(value,capabilityReader:{ throw SamplerFailure(description:"Generated pre-HELLO refusal") },authorityReader:{ current })
            }
            connections += 1
            return try SamplerConnection(value,capabilityReader:{ [UInt8](repeating:42,count:32) },authorityReader:{ current })
        }
        inputs.acquire = { _ in
            acquisitions += 1
            // Generated lavfi PTS may run ahead during -re catch-up. Stamp actual filter time,
            // converting Unix microseconds to the same host clock as the production reader.
            let offset = Int64((Date().timeIntervalSince1970-samplerClock()+(oldCapture ? 1 : 0))*1_000_000)
            return try FFmpegSamplerStream(input:["-re","-f","lavfi","-i","color=c=red:size=320x160:rate=30"],filter:"settb=expr=1/1000000,setpts=RTCTIME-\(offset)")
        }
        inputs.locate = { imageLock,_ in
            if connections == 1 { retainedLock = ObjectIdentifier(imageLock) }
            if connections == 2 && acquisitions == 2 { returnedLock = ObjectIdentifier(imageLock) }
            if switchDuringLocate { current = authority(nil); switchDuringLocate = false }
            return SamplerBounds(centerX:160,centerY:80,width:320,height:160,borderGray:70)
        }
        let runtime = try SamplerRuntime(inputs:inputs); defer { runtime.close() }
        func run(until condition: () -> Bool, timeout: Double = 4) throws {
            let end = samplerClock()+timeout
            var states: [String] = []
            while !condition() && samplerClock() < end {
                let delay = autoreleasepool { runtime.step() }
                if states.last != runtime.state && states.count < 20 { states.append(runtime.state) }
                if delay > 0 { usleep(useconds_t(delay*1_000_000)) }
            }
            try check(condition(),"Production runtime lifecycle failed (accepted=\(runtime.accepted), starts=\(acquisitions)): \(states)")
        }
        for _ in 0..<3 { _ = runtime.step() }
        try check(connections == 0 && acquisitions == 0 && !runtime.isCapturing,"Pre-context construction/polling produces neither socket nor capture")
        current = authority(1)
        try run(until:{ runtime.accepted >= 3 })
        try check(connections == 1 && acquisitions == 1,"Current context starts exactly one real socket and FFmpeg child")
        try check(runtime.reasons["authorityOrSourceFailure",default:0] == 1,"Actual pre-HELLO failure retries same unused ticket without deadlock")
        current = authority(nil)
        try run(until:{ !runtime.isCapturing })
        usleep(30_000)
        let messages = peer.received, accepted = runtime.accepted
        try check(messages.filter { $0.type == 1 }.count == 1 && messages.filter { $0.type == 2 }.count == accepted,"Actual peer received HELLO and every accepted complete frame")
        try check(messages.filter { $0.type == 3 }.count == 1,"Authority loss sends exactly one CLEAR before disconnect")
        let output = messages.first { $0.type == 2 }!.payload, offset = (57*484+242)*4
        try check(output.count == 484*114*4 && output[offset] < 5 && output[offset+1] < 5 && output[offset+2] > 245 && output[offset+3] == 255,"Real generated FFmpeg -> uniform fit -> opaque BGRA -> protocol path")
        for _ in 0..<3 { _ = runtime.step() }
        try check(runtime.accepted == accepted && acquisitions == 1,"No background capture or frame replay after context loss")
        current = authority(2)
        try run(until:{ runtime.accepted > accepted })
        try check(connections == 2 && acquisitions == 2,"Context return uses new session and new current acquisition")
        try check(retainedLock != nil && returnedLock == retainedLock,"Context return reuses only the same-source landmark validator, never an image")
        let previous = runtime.accepted
        source = SamplerWindow(id:42,pid:123,bounds:CGRect(x:90,y:70,width:400,height:200),occluders:[],display:display)
        try run(until:{ acquisitions == 3 && runtime.accepted > previous })
        try check(connections == 2,"Move/resize restarts source without inventing a protocol session")
        ambiguous = true
        try run(until:{ !runtime.isCapturing })
        let stoppedAt = runtime.accepted
        try check(runtime.state.contains("fallback"),"Ambiguous source abstains instead of choosing another window")
        ambiguous = false; current = authority(3); source = SamplerWindow(id:43,pid:123,bounds:source.bounds,occluders:[],display:display)
        try run(until:{ runtime.accepted > stoppedAt })
        try check(connections == 3 && acquisitions == 4,"Recreated source/current ticket reacquires")
        switchDuringLocate = true
        try run(until:{ !runtime.isCapturing })
        try check(runtime.reasons["contextChangedDuringFrame",default:0] > 0,"Context loss during actual frame processing refuses publication")
        let beforeOld = runtime.accepted
        let previousOld = runtime.reasons["beforeContext",default:0]
        oldCapture = true; current = authority(4)
        try run(until:{ runtime.reasons["beforeContext",default:0] > previousOld+3 })
        try check(runtime.accepted == beforeOld,"Stale generated acquisition cannot become a newly stamped frame")
        available = false
        try run(until:{ !runtime.isCapturing })
        oldCapture = false; available = true; current = authority(5,generation:String(repeating:"b",count:32))
        try run(until:{ runtime.accepted > beforeOld })
        try check(connections == 5,"Controller restart uses new ingress generation/connection")
        runtime.close(); runtime.close()
        let final = runtime.accepted; _ = runtime.step()
        try check(runtime.closed && !runtime.isCapturing && runtime.accepted == final,"Shutdown is idempotent and prevents future activation")
        usleep(30_000)
        try check(peer.received.filter { $0.type == 1 }.count == 5,"Wire saw exactly the five current-ticket authentications")
    }
    static func daily() throws {
        try dailyOptionsAndSelection(); try processAndCustody(); try runtimeLifecycle()
    }
}
