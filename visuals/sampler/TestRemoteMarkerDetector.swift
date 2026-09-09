import Foundation

@main struct TestRemoteMarkerDetector {
    static func main() {
        var checks = 0
        func check(_ ok: Bool, _ label: String) { precondition(ok,label); checks += 1 }
        let width = 240, height = 130, stride = width*4+32
        var bytes = [UInt8](repeating: 32,count: stride*height)
        func put(_ x: Int, _ y: Int, _ color: (UInt8,UInt8,UInt8)) {
            let i = y*stride+x*4; bytes[i] = color.0; bytes[i+1] = color.1; bytes[i+2] = color.2; bytes[i+3] = 255
        }
        func triangle(_ x: Int,_ y: Int,_ size: Int,_ color: (UInt8,UInt8,UInt8)) {
            for dy in 0..<size { for dx in 0..<(size-dy) { put(x+dx,y+dy,color) } }
        }
        triangle(25,30,12,(255,40,80)); triangle(90,60,18,(255,128,0))
        triangle(200,20,9,(255,255,0)) // Outside the explicitly supplied device region.
        for y in 90..<106 { for x in 40..<56 { put(x,y,(255,0,255)) } } // Not triangular.
        let region = MarkerRegion(x: 10,y: 10,width: 170,height: 110)
        let found = RemoteMarkerDetector.candidates(bytes: bytes,width: width,height: height,stride: stride,region: region)
        check(found.count == 2,"two in-region triangles; rectangle and outside marker excluded")
        check(found[0].x == 25 && found[0].y == 30 && found[0].width == 12,"top-left orientation, position and scale")
        check(found[0].red == 255 && found[0].blue == 80,"RGBA color and padded stride")
        check(found[1].width == 18 && found[1].green == 128,"second scale/color")
        check(found.allSatisfy { $0.shapeAgreement > 0.99 && $0.corner == "top-left" },"measured triangle shape")
        check(RemoteMarkerDetector.candidates(bytes: bytes,width: width,height: height,stride: width*4-1,region: region).isEmpty,"invalid stride")
        check(RemoteMarkerDetector.candidates(bytes: bytes,width: width,height: height,stride: stride,
            region: MarkerRegion(x: 0,y: 0,width: 999,height: 20)).isEmpty,"out-of-image region")
        check(RemoteMarkerDetector.candidates(bytes: [],width: width,height: height,stride: stride,region: region).isEmpty,"short storage")
        check(RemoteMarkerDetector.candidates(bytes: bytes,width: width,height: height,stride: stride,
            region: MarkerRegion(x: -1,y: 0,width: 20,height: 20)).isEmpty,"negative origin")
        // Moving the object changes marker coordinates, not color or relative position.
        bytes = [UInt8](repeating: 32,count: stride*height)
        triangle(65,50,12,(255,40,80))
        let moved = RemoteMarkerDetector.candidates(bytes: bytes,width: width,height: height,stride: stride,region: region)
        check(moved.count == 1 && moved[0].x-found[0].x == 40 && moved[0].y-found[0].y == 20,"translation")
        print("TestRemoteMarkerDetector: \(checks) checks PASS; generated shapes only, no encoder identity claim")
    }
}
