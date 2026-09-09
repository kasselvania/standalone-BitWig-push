import CoreGraphics
import Foundation
import Vision

struct Landmark: Codable {
    let label: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    var centerX: Double { x + width / 2 }
}

struct SamplerBounds: Codable, Equatable {
    let centerX: Double
    let centerY: Double
    let width: Int
    let height: Int
    let borderGray: Int
    var x: Int { Int(centerX - Double(width) / 2) }
    var y: Int { Int(centerY - Double(height) / 2) }
}

/// Top-down RGBA observation storage. This tool is not yet the live FFmpeg path.
struct ObservationPixels {
    let width: Int
    let height: Int
    let bytes: [UInt8]
    init(_ image: CGImage) throws {
        guard image.width > 0, image.height > 0, image.width <= 8192, image.height <= 4320 else {
            throw NSError(domain: "SamplerLocator", code: 1)
        }
        width = image.width; height = image.height
        var storage = [UInt8](repeating: 0, count: width * height * 4)
        let ok = storage.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: image.width, height: image.height,
                bitsPerComponent: 8, bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            return true
        }
        guard ok else { throw NSError(domain: "SamplerLocator", code: 2) }
        bytes = storage
    }
    func gray(_ x: Int, _ y: Int) -> Int {
        let offset = (y * width + x) * 4
        let a = Int(bytes[offset]), b = Int(bytes[offset+1]), c = Int(bytes[offset+2])
        return max(a, b, c) - min(a, b, c) <= 2 ? (a+b+c)/3 : -1
    }
}

enum SamplerLocator {
    static let words: Set<String> = ["repitch", "spectral", "cycles", "textures", "fragments",
        "out", "note", "release", "single", "expressions"]
    static func landmarks(in image: CGImage) throws -> [Landmark] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.003
        try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
        return (request.results ?? []).compactMap { observation in
            guard let text = observation.topCandidates(1).first else { return nil }
            let label = text.string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard words.contains(label) else { return nil }
            let box = observation.boundingBox
            return Landmark(label: label, x: box.minX * Double(image.width),
                y: (1-box.maxY) * Double(image.height), width: box.width * Double(image.width),
                height: box.height * Double(image.height))
        }
    }

    /// Recognize a constellation, then measure its enclosing control-body border.
    /// No window origin, normalized window crop, fixed screen position, or stored device size.
    static func locate(_ pixels: ObservationPixels, landmarks: [Landmark]) -> SamplerBounds? {
        let required = ["repitch", "spectral", "cycles", "textures", "fragments", "expressions", "note", "release", "out"]
        var selected: [String: Landmark] = [:]
        for key in required {
            let matches = landmarks.filter { $0.label == key }
            guard matches.count == 1 else { return nil }
            let match = matches[0]
            guard [match.x, match.y, match.width, match.height].allSatisfy(\.isFinite),
                  match.x >= 0, match.y >= 0, match.width > 0, match.height > 0,
                  match.x + match.width <= Double(pixels.width),
                  match.y + match.height <= Double(pixels.height) else { return nil }
            selected[key] = match
        }
        let modes = ["repitch", "spectral", "cycles", "textures", "fragments"].map { selected[$0]! }
        let textHeight = modes.map(\.height).sorted()[2]
        guard textHeight >= 7, textHeight <= 80 else { return nil }
        let spacing = (modes[4].y - modes[0].y) / 4
        guard spacing > textHeight * 1.3, spacing < textHeight * 4 else { return nil }
        for index in 0..<5 {
            guard abs(modes[index].centerX - modes[0].centerX) < textHeight,
                  abs(modes[index].y - modes[0].y - Double(index) * spacing) < textHeight * 0.6 else { return nil }
        }
        let expressions = selected["expressions"]!, note = selected["note"]!, release = selected["release"]!, out = selected["out"]!
        guard expressions.centerX < modes[0].centerX, note.x > modes[0].x,
              release.x > note.x, abs(note.y-release.y) < textHeight,
              out.x > modes[0].x, abs(out.y-modes[4].y) < textHeight, note.y < modes[0].y else { return nil }
        let minX = Int(expressions.x + textHeight), maxX = Int(release.x + release.width - textHeight)
        let minY = Int(min(note.y, release.y)), maxY = Int(max(out.y+out.height, modes[4].y+modes[4].height))
        let reach = Int(textHeight * 4)
        guard minX >= 0, maxX < pixels.width, minX < maxX, minY >= reach, maxY + reach < pixels.height else { return nil }
        func horizontal(_ range: Range<Int>) -> [(y: Int, color: Int, left: Int, right: Int)] {
            var result: [(Int,Int,Int,Int)] = []
            for y in range {
                var histogram = [Int](repeating: 0, count: 256)
                for x in stride(from: minX, through: maxX, by: 2) {
                    let gray = pixels.gray(x,y)
                    if gray >= 50 && gray <= 140 { histogram[gray] += 1 }
                }
                guard let color = (50...140).max(by: { histogram[$0] < histogram[$1] }),
                      Double(histogram[color]) / Double((maxX-minX)/2+1) > 0.84 else { continue }
                let middle = (minX + maxX) / 2
                guard abs(pixels.gray(middle,y)-color) <= 2 else { continue }
                var left = middle, right = middle
                while left > 0 && abs(pixels.gray(left-1,y)-color) <= 2 { left -= 1 }
                while right+1 < pixels.width && abs(pixels.gray(right+1,y)-color) <= 2 { right += 1 }
                guard left <= minX, right >= maxX, right-left < maxX-minX+reach*3 else { continue }
                result.append((y,color,left,right))
            }
            return result
        }
        let tops = horizontal((minY-reach)..<minY), bottoms = horizontal(maxY..<(maxY+reach))
        guard let nearestTop = tops.last, let nearestBottom = bottoms.first,
              nearestTop.color == nearestBottom.color,
              abs(nearestTop.left-nearestBottom.left) <= Int(textHeight),
              abs(nearestTop.right-nearestBottom.right) <= Int(textHeight) else { return nil }
        let color = nearestTop.color
        let topGroup = tops.filter { $0.color == color && nearestTop.y-$0.y < Int(textHeight) }
        let bottomGroup = bottoms.filter { $0.color == color && $0.y-nearestBottom.y < Int(textHeight) }
        guard let top = topGroup.first?.y, let bottom = bottomGroup.last?.y else { return nil }
        let trim = Int(textHeight)
        func vertical(_ x: Int) -> Bool {
            guard x >= 0 && x < pixels.width else { return false }
            var count = 0, total = 0
            for y in stride(from: top+trim, through: bottom-trim, by: 2) {
                total += 1
                if abs(pixels.gray(x,y)-color) <= 2 { count += 1 }
            }
            return total > 0 && Double(count)/Double(total) > 0.93
        }
        let lefts = ((nearestTop.left-trim)...(nearestTop.left+trim)).filter(vertical)
        let rights = ((nearestTop.right-trim)...(nearestTop.right+trim)).filter(vertical)
        guard let left = lefts.first, let right = rights.last,
              left <= Int(expressions.x), right >= Int(release.x+release.width),
              right-left > 2*(bottom-top), right-left < 6*(bottom-top) else { return nil }
        let width = right-left+1, height = bottom-top+1
        return SamplerBounds(centerX: Double(left)+Double(width)/2,
            centerY: Double(top)+Double(height)/2, width: width, height: height, borderGray: color)
    }
}
