import CoreGraphics
import CoreText
import Foundation

#if !SAMPLER_TEST
@main
#endif
struct TestSamplerLocator {
    static var checks = 0
    static func check(_ value: Bool, _ label: String) {
        guard value else { fputs("FAIL: \(label)\n", stderr); exit(1) }
        checks += 1
    }

    static func fixture(x: Int, y: Int, scale: Double, extraWidth: Int = 0, obstructTop: Bool = false) throws -> (CGImage, [Landmark], SamplerBounds) {
        let width = Int(Double(1659+extraWidth)*scale), height = Int(438*scale)
        let imageWidth = x+width+150, imageHeight = y+height+150
        let context = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 8,
            bytesPerRow: imageWidth*4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        func rectangle(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ gray: CGFloat) {
            context.setFillColor(red: gray, green: gray, blue: gray, alpha: 1)
            context.fill(CGRect(x: x, y: imageHeight-y-h, width: w, height: h))
        }
        rectangle(0,0,imageWidth,imageHeight,0.06)
        rectangle(x,y,width,height,73/255)
        let line = max(2,Int(6*scale))
        rectangle(x+line,y+line,width-2*line,height-2*line,28/255)
        let definitions: [(String,Double,Double,Double,Double)] = [
            ("expressions",20,162,112,20), ("repitch",179,178,71,20),
            ("spectral",175,232,76,20), ("cycles",183,287,61,20),
            ("textures",171,343,84,15), ("fragments",164,398,100,19),
            ("note",Double(1503+extraWidth),32,45,15),
            ("release",Double(1579+extraWidth),31,69,16),
            ("out",Double(1551+extraWidth),401,37,15)]
        var landmarks: [Landmark] = []
        for (label,lx,ly,w,h) in definitions {
            let px = Double(x)+lx*scale, py = Double(y)+ly*scale
            let landmark = Landmark(label: label, x: px, y: py, width: w*scale, height: h*scale)
            landmarks.append(landmark)
            let font = CTFontCreateWithName("Helvetica" as CFString, 20*scale, nil)
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key(kCTFontAttributeName as String):font,
                NSAttributedString.Key(kCTForegroundColorAttributeName as String):CGColor(gray:0.75,alpha:1)]
            let line = CTLineCreateWithAttributedString(NSAttributedString(string: label, attributes: attributes))
            context.textPosition = CGPoint(x:px, y:Double(imageHeight)-py-20*scale)
            CTLineDraw(line,context)
        }
        let expected = SamplerBounds(centerX:Double(x)+Double(width)/2,centerY:Double(y)+Double(height)/2,
            width:width,height:height,borderGray:73)
        if obstructTop { rectangle(x,y,width,line+1,0.9) }
        return (context.makeImage()!,landmarks,expected)
    }

    static func main() throws {
        for scale in [0.5,0.56,0.6,0.75,1.0,1.25,1.5] {
            for (x,y,extra) in [(90,100,0),(450,380,0),(180,230,180),(280,180,-160)] {
                let (image,landmarks,expected) = try fixture(x:x,y:y,scale:scale,extraWidth:extra)
                let pixels = try ObservationPixels(image)
                let actual = SamplerLocator.locate(pixels,landmarks:landmarks)
                check(actual == expected,"measured translation/scale/width \(scale) \(x) \(extra); actual=\(String(describing:actual)) expected=\(expected); border=\(pixels.gray(x,y))")
                check(SamplerLocator.locate(pixels,landmarks:Array(landmarks.dropLast())) == nil,"missing landmark refused")
                check(SamplerLocator.locate(pixels,landmarks:landmarks+[landmarks[0]]) == nil,"ambiguous duplicate refused")
                check(SamplerLocator.locate(pixels,landmarks:[]) == nil,"rectangle alone not Sampler authority")
            }
        }
        let (image,_,_) = try fixture(x:100,y:100,scale:1)
        let recognized = try SamplerLocator.landmarks(in:image)
        check(recognized.contains { $0.label == "repitch" },"real Vision request recognizes generated landmark")
        let (broken, landmarks, _) = try fixture(x:100,y:100,scale:1,obstructTop:true)
        check(SamplerLocator.locate(try ObservationPixels(broken),landmarks:landmarks) == nil,
              "old landmarks cannot authorize an obstructed device border")
        let pixels = try ObservationPixels(image)
        for invalid in [Landmark(label:"expressions",x:.nan,y:100,width:100,height:20),
                        Landmark(label:"expressions",x:100,y:100,width:0,height:20),
                        Landmark(label:"expressions",x:Double(pixels.width),y:100,width:100,height:20)] {
            check(SamplerLocator.locate(pixels,landmarks:[invalid]+Array(landmarks.dropFirst())) == nil,
                  "nonfinite/empty/out-of-bounds landmark refused before integer conversion")
        }
        print("SamplerLocator: \(checks) checks PASS; generated pixel geometry, not live tracking acceptance")
    }
}
