import Foundation
import ImageIO

@main struct ObserveSampler {
    static func main() throws {
        guard CommandLine.arguments.count == 2,
              let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            fputs("usage: ObserveSampler image.png\n", stderr); exit(2)
        }
        let start = DispatchTime.now().uptimeNanoseconds
        let landmarks = try SamplerLocator.landmarks(in: image)
        let afterRecognition = DispatchTime.now().uptimeNanoseconds
        let pixels = try ObservationPixels(image)
        let afterDecode = DispatchTime.now().uptimeNanoseconds
        let bounds = SamplerLocator.locate(pixels, landmarks: landmarks)
        let end = DispatchTime.now().uptimeNanoseconds
        struct Result: Encodable {
            let imageWidth: Int; let imageHeight: Int; let landmarks: [Landmark]; let bounds: SamplerBounds?
            let recognitionMs: Double; let pixelDecodeMs: Double; let boundsMs: Double
        }
        let result = Result(imageWidth: image.width, imageHeight: image.height, landmarks: landmarks, bounds: bounds,
            recognitionMs: Double(afterRecognition-start)/1e6, pixelDecodeMs: Double(afterDecode-afterRecognition)/1e6,
            boundsMs: Double(end-afterDecode)/1e6)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        FileHandle.standardOutput.write(try encoder.encode(result)); print()
        if bounds == nil { exit(1) }
    }
}
