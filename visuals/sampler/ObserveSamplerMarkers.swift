import Foundation
import ImageIO

@main struct ObserveSamplerMarkers {
    static func main() throws {
        guard CommandLine.arguments.count == 2,
              let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            fputs("usage: ObserveSamplerMarkers local-Bitwig-image.png\n", stderr); exit(2)
        }
        let pixels = try ObservationPixels(image)
        guard let body = SamplerLocator.locate(pixels, landmarks: try SamplerLocator.landmarks(in: image)) else {
            fputs("No unique verified Sampler region; no marker claims.\n", stderr); exit(1)
        }
        let start = DispatchTime.now().uptimeNanoseconds
        let markers = RemoteMarkerDetector.candidates(bytes: pixels.bytes, width: pixels.width, height: pixels.height,
            stride: pixels.width*4, region: MarkerRegion(x: body.x,y: body.y,width: body.width,height: body.height))
        struct Result: Encodable {
            let imageWidth: Int; let imageHeight: Int; let device: SamplerBounds
            let candidates: [RemoteMarker]; let markerScanMs: Double
            let status = "candidates-only; encoder correspondence requires current Push/API observation"
        }
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
        FileHandle.standardOutput.write(try encoder.encode(Result(imageWidth: pixels.width,imageHeight: pixels.height,
            device: body,candidates: markers,markerScanMs: Double(DispatchTime.now().uptimeNanoseconds-start)/1e6)))
        print()
    }
}
