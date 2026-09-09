import Foundation

struct MarkerRegion { let x: Int; let y: Int; let width: Int; let height: Int }
struct RemoteMarker: Codable {
    let x: Int; let y: Int; let width: Int; let height: Int
    let red: Int; let green: Int; let blue: Int
    let corner: String; let shapeAgreement: Double
}

/// Offline candidate measurement only. Color is NOT an asserted encoder/parameter identity.
/// Accepts a caller-verified device region; returns marker bounds, not underlying knob bounds.
enum RemoteMarkerDetector {
    static func candidates(bytes: [UInt8], width: Int, height: Int, stride: Int,
                           region: MarkerRegion) -> [RemoteMarker] {
        guard width > 0, height > 0, width <= 8192, height <= 4320,
              stride >= width * 4, stride <= 8192 * 8, bytes.count >= stride * height,
              region.x >= 0, region.y >= 0, region.width > 0, region.height > 0,
              region.width <= width, region.height <= height,
              region.x <= width - region.width, region.y <= height - region.height else { return [] }
        var visited = [Bool](repeating: false, count: region.width * region.height)
        func rgb(_ index: Int) -> (Int, Int, Int) {
            let x = region.x + index % region.width, y = region.y + index / region.width
            let offset = y * stride + x * 4
            return (Int(bytes[offset]), Int(bytes[offset+1]), Int(bytes[offset+2]))
        }
        func saturated(_ index: Int) -> Bool {
            let (r,g,b) = rgb(index)
            return max(r,g,b) >= 160 && max(r,g,b) - min(r,g,b) >= 85
        }
        var result: [RemoteMarker] = []
        var component: [Int] = []
        for seed in visited.indices where !visited[seed] {
            visited[seed] = true
            guard saturated(seed) else { continue }
            component.removeAll(keepingCapacity: true)
            component.append(seed)
            var next = 0, left = seed % region.width, right = left
            var top = seed / region.width, bottom = top
            while next < component.count {
                let p = component[next]; next += 1
                let x = p % region.width, y = p / region.width
                left = min(left,x); right = max(right,x); top = min(top,y); bottom = max(bottom,y)
                for (dx,dy) in [(-1,0),(1,0),(0,-1),(0,1)] {
                    let nx = x+dx, ny = y+dy
                    if nx < 0 || nx >= region.width || ny < 0 || ny >= region.height { continue }
                    let n = ny * region.width + nx
                    if visited[n] { continue }
                    visited[n] = true
                    if saturated(n) { component.append(n) }
                }
            }
            let w = right-left+1, h = bottom-top+1
            guard w >= 4, h >= 4, w <= 64, h <= 64, Double(w)/Double(h) >= 0.65,
                  Double(w)/Double(h) <= 1.55, component.count >= 8 else { continue }
            let fill = Double(component.count) / Double(w*h)
            guard fill >= 0.30, fill <= 0.75 else { continue }
            let points = Set(component)
            var best = 0.0, corner = ""
            for (name, flipX, flipY) in [("top-left",false,false),("top-right",true,false),
                                        ("bottom-left",false,true),("bottom-right",true,true)] {
                var intersection = 0, union = 0
                for y in top...bottom { for x in left...right {
                    var u = Double(x-left)/Double(max(1,w-1)), v = Double(y-top)/Double(max(1,h-1))
                    if flipX { u = 1-u }; if flipY { v = 1-v }
                    let expected = u+v <= 1.001, observed = points.contains(y*region.width+x)
                    if expected || observed { union += 1 }
                    if expected && observed { intersection += 1 }
                }}
                let score = Double(intersection)/Double(max(1,union))
                if score > best { best = score; corner = name }
            }
            guard best >= 0.78 else { continue }
            let colors = component.map(rgb)
            result.append(RemoteMarker(x: region.x+left, y: region.y+top, width: w, height: h,
                red: colors.map { $0.0 }.sorted()[colors.count/2],
                green: colors.map { $0.1 }.sorted()[colors.count/2],
                blue: colors.map { $0.2 }.sorted()[colors.count/2], corner: corner, shapeAgreement: best))
        }
        return result.sorted { $0.y == $1.y ? $0.x < $1.x : $0.y < $1.y }
    }
}
