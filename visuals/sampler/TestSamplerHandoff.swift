import Darwin
import Foundation

/// Repeatable exact-size transport measurement. Generated pixels only; no screen/device access.
/// The timestamp is inserted at the FFmpeg filter exit, NOT at a camera/screen acquisition.
@main struct TestSamplerHandoff {
    static func main() throws {
        let count = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1]) ?? 0 : 360
        let workMS = CommandLine.arguments.count > 2 ? Double(CommandLine.arguments[2]) ?? -1 : 17
        try samplerRequire((90...1800).contains(count) && workMS.isFinite && (0...100).contains(workMS),
                           "usage: TestSamplerHandoff [90..1800 frames] [0..100 processing-ms]")
        // RTCTIME is Unix microseconds. Convert it into this process's host-clock domain;
        // refuse a clock jump rather than calling wall time an acquisition timestamp.
        let epochOffset = Date().timeIntervalSince1970 - samplerClock()
        let clock = String(format:"%.0f",epochOffset*1_000_000)
        let reader = try FFmpegSamplerStream(
            input:["-re","-f","lavfi","-i","color=c=red:size=5488x2316:rate=30,format=bgr0"],
            filter:"drawbox=x=0:y=0:w=64:h=64:c=blue:t=fill:enable='mod(n,2)',settb=1/1000000,setpts=RTCTIME-\(clock)")
        defer { reader.close() }
        var readTimes:[Double] = [], ages:[Double] = [], completions:[Double] = [], intervals:[Double] = []
        var frames = 0, last = 0.0, lastStamp = -Double.infinity, pointer:UnsafeRawPointer?
        var mismatches = 0, lastColor:UInt8?, changes = 0
        let deadline = samplerClock()+max(20,Double(count)/15)
        while frames < count && samplerClock() < deadline {
            let start = samplerClock()
            guard let frame = try reader.nextFrame(timeout:0.5) else { continue }
            let received = samplerClock(), age = (received-frame.captured)*1000
            try samplerRequire(abs(Date().timeIntervalSince1970-samplerClock()-epochOffset) < 0.02,"Wall/host clock changed during generated benchmark")
            try samplerRequire(frame.width == 5488 && frame.height == 2316 && frame.bytes.count == 50840832 &&
                               frame.captured > lastStamp && age >= -2,"Actual transport geometry/timestamp contract")
            if let pointer { try samplerRequire(pointer == frame.bytes.baseAddress,"Input buffer must be reused") }
            pointer = frame.bytes.baseAddress; lastStamp = frame.captured
            // Alternating blue/red marker plus unchanged far red corner distinguish complete
            // sequential frames without allocating/copying another full image for the test.
            let blue = frame.index % 2 == 1
            let bytes = frame.bytes
            if !(bytes[0] == (blue ? 255 : 0) && bytes[1] == 0 && bytes[2] == (blue ? 0 : 255)) { mismatches += 1 }
            let far = ((2316-1)*5488+5488-1)*4
            if !(bytes[far] == 0 && bytes[far+1] == 0 && bytes[far+2] == 255) { mismatches += 1 }
            if let lastColor, lastColor != bytes[0] { changes += 1 }
            lastColor = bytes[0]
            // Model synchronous computation, not usleep's timer-coalescing delay. This bounded
            // test-only busy interval never exists in the producer and is identical for A/B.
            let workEnd = samplerClock()+workMS/1000
            while samplerClock() < workEnd {}
            if frames >= 60 {
                readTimes.append((received-start)*1000); ages.append(age)
                completions.append((samplerClock()-frame.captured)*1000)
                intervals.append((received-last)*1000)
            }
            last = received; frames += 1
        }
        try samplerRequire(frames == count && mismatches == 0 && changes == frames-1,"Complete changing generated frames must match")
        func distribution(_ values:[Double]) -> [String:Any] {
            let sorted = values.sorted()
            return ["samples":sorted.count,"p50Ms":sorted[(sorted.count-1)/2],
                    "p95Ms":sorted[Int(Double(sorted.count-1)*0.95)],"maxMs":sorted.last!]
        }
        let result:[String:Any] = ["frames":frames,"warmup":60,"imposedWorkMs":workMS,
            "deliveredFPS":Double(intervals.count)*1000/intervals.reduce(0,+),
            "read":distribution(readTimes),"filterToRead":distribution(ages),
            "filterToWorkComplete":distribution(completions),"interval":distribution(intervals),
            "pixelMismatches":mismatches,"markerChanges":changes,
            "over250ms":completions.filter { $0 > 250 }.count,
            "scope":"generated 5488x2316 handoff only; excludes native acquisition, locator, ingress and Push"]
        print(String(data:try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys]),encoding:.utf8)!)
    }
}
