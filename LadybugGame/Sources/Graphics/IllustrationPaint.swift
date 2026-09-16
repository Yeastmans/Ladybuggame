import UIKit
import SpriteKit

/// Shared lighting for generated artwork; the original sprite bounds stay intact.
enum IllustrationPaint {
    static func tint(_ color: UIColor, toward other: UIColor, amount: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0, aa: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        other.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
        return UIColor(red: r + (rr-r)*amount, green: g + (gg-g)*amount,
                       blue: b + (bb-b)*amount, alpha: a)
    }

    static func oval(_ rect: CGRect, color: UIColor, in c: CGContext, outline: CGFloat = 0) {
        c.saveGState()
        c.addEllipse(in: rect); c.clip()
        let light = tint(color, toward: UIColor(red: 1, green: 0.94, blue: 0.78, alpha: 1), amount: 0.26)
        let shade = tint(color, toward: UIColor(red: 0.12, green: 0.09, blue: 0.18, alpha: 1), amount: 0.32)
        let colors = [light.cgColor, color.cgColor, shade.cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.48, 1]) {
            c.drawLinearGradient(gradient, start: CGPoint(x: rect.minX, y: rect.minY),
                                 end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
        }
        c.restoreGState()
        if outline > 0 {
            c.saveGState()
            c.setStrokeColor(tint(color, toward: .black, amount: 0.48).cgColor)
            c.setLineWidth(outline); c.strokeEllipse(in: rect)
            c.restoreGState()
        }
    }

    static func cloud(size: CGSize) -> SKTexture {
        let format = UIGraphicsImageRendererFormat(); format.scale = 2
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let c = context.cgContext
            let w = size.width, h = size.height
            let path = CGMutablePath()
            path.addRoundedRect(in: CGRect(x: w*0.08, y: h*0.43, width: w*0.84, height: h*0.40), cornerWidth: h*0.18, cornerHeight: h*0.18)
            for (x,y,ww,hh) in [(0.15,0.31,0.30,0.46),(0.32,0.12,0.39,0.65),(0.61,0.29,0.27,0.49)] as [(CGFloat,CGFloat,CGFloat,CGFloat)] {
                path.addEllipse(in: CGRect(x:x*w,y:y*h,width:ww*w,height:hh*h))
            }
            c.addPath(path); c.clip()
            let colors = [UIColor.white.cgColor, UIColor(red: 0.77, green: 0.88, blue: 0.94, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0,1]) {
                c.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: h), options: [])
            }
        }
        return SKTexture(image: image)
    }
}
