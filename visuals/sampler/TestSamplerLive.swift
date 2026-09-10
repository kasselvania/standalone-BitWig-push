import AppKit
import Darwin
import Foundation

@main struct TestSamplerLive {
    static var checks = 0
    static func check(_ condition: Bool, _ message: String) throws {
        checks += 1; try samplerRequire(condition, message)
    }
    static func refuses(_ body: () throws -> Void) throws {
        do { try body() } catch { checks += 1; return }
        throw SamplerFailure(description: "Expected refusal")
    }
    static func main() throws {
        if CommandLine.arguments.count == 3 && CommandLine.arguments[1] == "--interop" {
            try interop(); return
        }
        try fit(); try authority(); try stream(); try socketDeadline()
        print("SamplerLive generated checks: PASS (\(checks)); no capture, Bitwig, Push or permission changes")
    }
    static func interop() throws {
        guard let port = Int(CommandLine.arguments[2]), port == 45293 else { throw SamplerFailure(description: "Generated interoperability test port only") }
        let authority = SamplerAuthority(generation:String(repeating:"a",count:32),session:"11111111111111112222222222222222",port:port,pid:123,started:456,capabilityFile:"unused")
        let client = try SamplerConnection(authority,capabilityReader:{ [UInt8](repeating:0xa5,count:32) },authorityReader:{ authority })
        defer { client.close() }
        let frame = [UInt8](repeating:255,count:484*114*4)
        try frame.withUnsafeBytes { try client.frame($0) }
        print("FRAME"); fflush(stdout)
        try samplerRequire(readLine() == "CLEAR", "Interop CLEAR command")
        try client.clear(); print("CLEAR"); fflush(stdout)
        try samplerRequire(readLine() == "EXIT", "Interop EXIT command")
    }
    static func fit() throws {
        guard let fit = sampler_fit_create() else { throw SamplerFailure(description: "Allocation") }
        defer { sampler_fit_destroy(fit) }
        let width = 968, height = 228, stride = width*4+64
        var source = [UInt8](repeating: 123, count: stride*height)
        for y in 0..<height { for x in 0..<width {
            let offset = y*stride+x*4
            source[offset] = y >= height/2 ? 255 : 0
            source[offset+1] = x >= width/2 ? 255 : 0
            source[offset+2] = x < width/2 && y < height/2 ? 255 : 0
            source[offset+3] = 0
        } }
        try source.withUnsafeBytes { raw in
            let input = raw.baseAddress!.assumingMemoryBound(to: UInt8.self)
            guard let a = sampler_fit_frame(fit, input, raw.count, Int32(width), Int32(height), Int32(stride), 0,0,484,114) else { throw SamplerFailure(description: "A crop") }
            var mismatches = 0
            for pixel in 0..<(484*114) { if !(a[pixel*4] == 0 && a[pixel*4+1] == 0 && a[pixel*4+2] == 255 && a[pixel*4+3] == 255) { mismatches += 1 } }
            try check(mismatches == 0, "Top-left crop/color/alpha/stride")
            let aHash = Data(bytes: a, count: 484*114*4).hashValue
            guard let b = sampler_fit_frame(fit, input, raw.count, Int32(width), Int32(height), Int32(stride), 484,114,484,114) else { throw SamplerFailure(description: "B crop") }
            try check(a == b, "Output allocation must be reused")
            try check(aHash != Data(bytes: b, count: 484*114*4).hashValue, "Nonoverlapping crops differ")
            mismatches = 0
            for pixel in 0..<(484*114) { if !(b[pixel*4] == 255 && b[pixel*4+1] == 255 && b[pixel*4+2] == 0 && b[pixel*4+3] == 255) { mismatches += 1 } }
            try check(mismatches == 0, "Bottom-right crop/color/alpha; no whole-frame leakage")
            try check(sampler_fit_frame(fit,input,raw.count,Int32(width),Int32(height),Int32(stride),-1,0,484,114) == nil, "Negative crop refused")
            try check(sampler_fit_frame(fit,input,raw.count,Int32(width),Int32(height),Int32(stride),800,0,484,114) == nil, "Outside crop refused")
            try check(sampler_fit_frame(fit,input,10,Int32(width),Int32(height),Int32(stride),0,0,484,114) == nil, "Short storage refused")
            let observed = try ObservationPixels(bgr0: raw, width: width, height: height, stride: stride)
            try check(observed.gray(0,0) == -1 && observed.gray(width-1,height-1) == -1, "Borrowed padded pixel access")
            guard let square = sampler_fit_frame(fit,input,raw.count,Int32(width),Int32(height),Int32(stride),0,0,114,114) else { throw SamplerFailure(description: "Fit") }
            try check(square[0] == 0 && square[1] == 0 && square[2] == 0 && square[3] == 255, "Uniform fit leaves opaque black padding")
            let middle = (57*484+242)*4
            try check(square[middle+2] == 255, "Uniform fit preserves selected center")
        }
    }
    static func authority() throws {
        let gen = "0123456789abcdef0123456789abcdef"
        let manifest: [String: Any] = ["schema_version":1,"protocol_version":1,"transport":"ipv4-loopback","port":45291,
            "capability_file":"capability-\(gen).hex","session_generation":gen,"owner_pid":123,"owner_start_epoch_millis":456]
        let notice: [String: Any] = ["schema_version":1,"ingress_generation":gen,"native_device":"bitwig-sampler",
            "context_session":"11111111111111112222222222222222","destination":[238,25,484,114]]
        func decode(_ m: [String: Any], _ n: [String: Any]) throws -> SamplerAuthority {
            try SamplerAuthority.parse(JSONSerialization.data(withJSONObject:m), notice:JSONSerialization.data(withJSONObject:n))
        }
        let result = try decode(manifest,notice)
        try check(result.port == 45291 && result.session == notice["context_session"] as? String, "Current context decode")
        for (key,value) in [("schema_version",2 as Any),("protocol_version",2),("transport","tcp"),("port",0),
            ("port",true),("port",45291.5),("capability_file","../token"),("session_generation","bad") ] {
            var changed = manifest; changed[key] = value
            try refuses { _ = try decode(changed,notice) }
        }
        for (key,value) in [("schema_version",2 as Any),("ingress_generation",String(repeating:"0",count:32)),
            ("context_session",String(repeating:"0",count:32)),("native_device","name:Sampler"),("destination",[0,0,484,114]) ] {
            var changed = notice; changed[key] = value
            try refuses { _ = try decode(manifest,changed) }
        }
        var absent = notice; absent["context_session"] = NSNull()
        try check(try decode(manifest,absent).session == nil, "Semantic-only context")
        let encoded = try JSONSerialization.data(withJSONObject:manifest)
        let duplicated = Data(("{\"port\":45291," + String(decoding:encoded,as:UTF8.self).dropFirst()).utf8)
        try refuses { _ = try SamplerAuthority.parse(duplicated,notice:JSONSerialization.data(withJSONObject:notice)) }
        try check(sampler_process_start_millis(getpid()) > 0, "Actual process-start readback")
    }
    static func stream() throws {
        let reader = try FFmpegSamplerStream(input:["-re","-f","lavfi","-i","testsrc=size=640x160:rate=30"],filter:"null")
        defer { reader.close() }
        var count = 0, last = -1.0, pointer: UnsafeRawPointer?
        var differences = 0, previous = Data()
        let deadline = samplerClock()+8
        while count < 40 && samplerClock() < deadline {
            guard let frame = try reader.nextFrame() else { continue }
            try check(frame.index == count && frame.width == 640 && frame.height == 160 && frame.captured > last, "Actual FFmpeg pixel/timestamp correspondence")
            if let pointer { try check(pointer == frame.bytes.baseAddress, "Full input buffer reused") }
            pointer = frame.bytes.baseAddress; last = frame.captured
            let image = Data(frame.bytes)
            if !previous.isEmpty && previous != image { differences += 1 }
            previous = image; count += 1
            if count == 3 { usleep(250_000) } // Deliberate consumer stall; bounded metadata must survive.
        }
        try check(count == 40 && differences > 10, "Current generated frames change through actual FFmpeg pipe")
    }
    static func socketDeadline() throws {
        let listener = socket(AF_INET,SOCK_STREAM,0); try check(listener >= 0,"Listener")
        defer { Darwin.close(listener) }
        var address = sockaddr_in(); address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET); address.sin_addr.s_addr = inet_addr("127.0.0.1")
        let bound = withUnsafePointer(to:&address) { $0.withMemoryRebound(to:sockaddr.self,capacity:1) { Darwin.bind(listener,$0,socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        try check(bound == 0 && listen(listener,1) == 0,"Loopback bind")
        var size = socklen_t(MemoryLayout<sockaddr_in>.size)
        _ = withUnsafeMutablePointer(to:&address) { $0.withMemoryRebound(to:sockaddr.self,capacity:1) { getsockname(listener,$0,&size) } }
        let gate = DispatchSemaphore(value:0), done = DispatchSemaphore(value:0)
        // Test-only stalled server; production has no second capture/output thread.
        DispatchQueue.global().async {
            let peer = accept(listener,nil,nil)
            defer { if peer >= 0 { Darwin.close(peer) }; done.signal() }
            var hello = [UInt8](repeating:0,count:112), readCount = 0
            while peer >= 0 && readCount < 112 {
                let n = hello.withUnsafeMutableBytes { Darwin.read(peer,$0.baseAddress!.advanced(by:readCount),112-readCount) }
                if n <= 0 { break }; readCount += n
            }
            gate.signal(); usleep(600_000)
        }
        let authority = SamplerAuthority(generation:String(repeating:"a",count:32),session:"11111111111111112222222222222222",port:Int(UInt16(bigEndian:address.sin_port)),pid:123,started:456,capabilityFile:"unused")
        let client = try SamplerConnection(authority,capabilityReader:{ [UInt8](repeating:42,count:32) },authorityReader:{ authority })
        defer { client.close() }
        try check(gate.wait(timeout:.now()+1) == .success,"HELLO received before stalled-read test")
        let frame = [UInt8](repeating:255,count:484*114*4)
        var failed = false, failureMs = 0.0
        for _ in 0..<100 {
            let start = samplerClock()
            do { try frame.withUnsafeBytes { try client.frame($0) } }
            catch { failed = true; failureMs = (samplerClock()-start)*1000; break }
        }
        try check(failed && failureMs < 400,"Stalled socket must close within 250 ms deadline plus scheduler tolerance")
        try check(done.wait(timeout:.now()+2) == .success,"Bounded server cleanup")
        print("Generated stalled-reader failure: \(failureMs) ms (one sample, not performance acceptance)")
    }
}
