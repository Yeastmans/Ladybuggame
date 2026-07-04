import SpriteKit
import UIKit

// Styled creature art for the later biomes. Replaces the old one-blob-fits-all
// generateSimpleCreature look with distinct silhouettes and a consistent
// friend-vs-foe language:
//   Food:    soft rounded shapes, big cute white eye with highlight, smile
//   Enemies: angular shapes, glowing eyes under angry slanted brows, fangs/spikes
// All creatures face RIGHT (same convention as generateSimpleCreature).
extension TextureGenerator {

    enum FoodStyle {
        case beetle, moth, snail, jelly, grub, mite, bee, shrimp, cricket, star, ant
    }

    enum EnemyStyle {
        case spider, serpent, golem, ant, wisp, swarm, spikeball, centipede, cat
    }

    // MARK: - Shared face parts

    private static func shade(_ c: UIColor, _ f: CGFloat) -> UIColor {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        c.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(1.0, r * f), green: min(1.0, g * f), blue: min(1.0, b * f), alpha: a)
    }

    private static func drawCuteEye(_ cg: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        cg.setFillColor(UIColor.white.cgColor)
        cg.fillEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        cg.setFillColor(UIColor.black.cgColor)
        cg.fillEllipse(in: CGRect(x: cx - r * 0.30, y: cy - r * 0.45, width: r * 0.9, height: r * 0.9))
        cg.setFillColor(UIColor.white.cgColor)
        cg.fillEllipse(in: CGRect(x: cx + r * 0.05, y: cy - r * 0.40, width: r * 0.35, height: r * 0.35))
    }

    private static func drawSmile(_ cg: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        cg.setStrokeColor(UIColor(white: 0.1, alpha: 0.75).cgColor)
        cg.setLineWidth(max(1.0, r * 0.35)); cg.setLineCap(.round)
        cg.move(to: CGPoint(x: cx - r, y: cy))
        cg.addQuadCurve(to: CGPoint(x: cx + r, y: cy), control: CGPoint(x: cx, y: cy + r))
        cg.strokePath()
    }

    private static func drawAngryEye(_ cg: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat, color: UIColor) {
        // Outer glow
        cg.setFillColor(color.withAlphaComponent(0.30).cgColor)
        cg.fillEllipse(in: CGRect(x: cx - r * 1.6, y: cy - r * 1.6, width: r * 3.2, height: r * 3.2))
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        cg.setFillColor(UIColor.black.cgColor)
        cg.fillEllipse(in: CGRect(x: cx - r * 0.35, y: cy - r * 0.35, width: r * 0.7, height: r * 0.7))
        // Angry brow: slants down toward the front (right)
        cg.setStrokeColor(UIColor.black.cgColor)
        cg.setLineWidth(max(1.2, r * 0.55)); cg.setLineCap(.round)
        cg.move(to: CGPoint(x: cx - r * 1.2, y: cy - r * 1.8))
        cg.addLine(to: CGPoint(x: cx + r * 1.2, y: cy - r * 0.7))
        cg.strokePath()
    }

    // MARK: - Food (friendly) creatures

    static func generateFoodCreature(size: CGSize, style: FoodStyle, body: UIColor, accent: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            switch style {

            case .beetle:
                cg.setStrokeColor(shade(body, 0.6).cgColor)
                cg.setLineWidth(max(1.0, w * 0.04)); cg.setLineCap(.round)
                let legXs: [CGFloat] = [0.22, 0.42, 0.60]
                for lx in legXs {
                    cg.move(to: CGPoint(x: w * lx, y: h * 0.72))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.05), y: h * 0.95))
                    cg.strokePath()
                }
                // Head
                cg.setFillColor(shade(body, 0.65).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.30, width: w * 0.34, height: h * 0.48))
                // Dome shell
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.02, y: h * 0.18, width: w * 0.72, height: h * 0.62))
                // Shell split line
                cg.setStrokeColor(shade(body, 0.65).cgColor)
                cg.setLineWidth(max(1.0, w * 0.03))
                cg.move(to: CGPoint(x: w * 0.38, y: h * 0.20))
                cg.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.78), control: CGPoint(x: w * 0.30, y: h * 0.50))
                cg.strokePath()
                // Accent spots
                cg.setFillColor(accent.cgColor)
                let spotXs: [CGFloat] = [0.16, 0.28, 0.52]
                let spotYs: [CGFloat] = [0.38, 0.62, 0.36]
                for i in 0..<3 {
                    let sr = w * 0.05
                    cg.fillEllipse(in: CGRect(x: w * spotXs[i] - sr, y: h * spotYs[i] - sr, width: sr * 2, height: sr * 2))
                }
                drawCuteEye(cg, cx: w * 0.81, cy: h * 0.46, r: w * 0.085)
                drawSmile(cg, cx: w * 0.85, cy: h * 0.63, r: w * 0.05)

            case .moth:
                // Two rounded wings above
                cg.setFillColor(body.withAlphaComponent(0.92).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.04, y: h * 0.08, width: w * 0.42, height: h * 0.52))
                cg.fillEllipse(in: CGRect(x: w * 0.36, y: h * 0.04, width: w * 0.44, height: h * 0.56))
                // Wing spots
                cg.setFillColor(accent.withAlphaComponent(0.9).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.17, y: h * 0.24, width: w * 0.12, height: h * 0.16))
                cg.fillEllipse(in: CGRect(x: w * 0.51, y: h * 0.22, width: w * 0.13, height: h * 0.17))
                // Fuzzy body
                cg.setFillColor(shade(body, 0.65).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.28, y: h * 0.52, width: w * 0.58, height: h * 0.34))
                // Antennae
                cg.setStrokeColor(shade(body, 0.55).cgColor)
                cg.setLineWidth(max(1.0, w * 0.03)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.80, y: h * 0.56))
                cg.addQuadCurve(to: CGPoint(x: w * 0.94, y: h * 0.30), control: CGPoint(x: w * 0.94, y: h * 0.48))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.75, y: h * 0.54))
                cg.addQuadCurve(to: CGPoint(x: w * 0.84, y: h * 0.24), control: CGPoint(x: w * 0.73, y: h * 0.34))
                cg.strokePath()
                drawCuteEye(cg, cx: w * 0.78, cy: h * 0.66, r: w * 0.085)

            case .snail:
                // Slug body along the bottom + head bump
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.60, width: w * 0.88, height: h * 0.34))
                cg.fillEllipse(in: CGRect(x: w * 0.66, y: h * 0.42, width: w * 0.28, height: h * 0.36))
                // Eye stalks with eyes on top
                cg.setStrokeColor(body.cgColor)
                cg.setLineWidth(max(1.2, w * 0.035)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.78, y: h * 0.46))
                cg.addLine(to: CGPoint(x: w * 0.74, y: h * 0.18))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.86, y: h * 0.46))
                cg.addLine(to: CGPoint(x: w * 0.91, y: h * 0.20))
                cg.strokePath()
                drawCuteEye(cg, cx: w * 0.74, cy: h * 0.14, r: w * 0.065)
                drawCuteEye(cg, cx: w * 0.91, cy: h * 0.16, r: w * 0.065)
                // Spiral shell
                cg.setFillColor(accent.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.08, y: h * 0.10, width: w * 0.52, height: h * 0.60))
                cg.setStrokeColor(shade(accent, 0.6).cgColor)
                cg.setLineWidth(max(1.0, w * 0.035))
                cg.strokeEllipse(in: CGRect(x: w * 0.16, y: h * 0.22, width: w * 0.36, height: h * 0.38))
                cg.strokeEllipse(in: CGRect(x: w * 0.24, y: h * 0.32, width: w * 0.20, height: h * 0.20))
                drawSmile(cg, cx: w * 0.84, cy: h * 0.58, r: w * 0.045)

            case .jelly:
                // Wavy tentacles
                cg.setStrokeColor(body.withAlphaComponent(0.8).cgColor)
                cg.setLineWidth(max(1.2, w * 0.045)); cg.setLineCap(.round)
                let tentXs: [CGFloat] = [0.25, 0.42, 0.58, 0.75]
                for i in 0..<4 {
                    let tx = tentXs[i]
                    let sway: CGFloat = (i % 2 == 0) ? 0.08 : -0.08
                    cg.move(to: CGPoint(x: w * tx, y: h * 0.56))
                    cg.addQuadCurve(to: CGPoint(x: w * (tx + sway), y: h * 0.95),
                                    control: CGPoint(x: w * (tx - sway), y: h * 0.76))
                    cg.strokePath()
                }
                // Bell dome
                cg.setFillColor(body.withAlphaComponent(0.92).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.08, y: h * 0.06, width: w * 0.84, height: h * 0.58))
                // Inner glow
                cg.setFillColor(accent.withAlphaComponent(0.5).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.14, width: w * 0.36, height: h * 0.24))
                drawCuteEye(cg, cx: w * 0.56, cy: h * 0.38, r: w * 0.095)
                drawSmile(cg, cx: w * 0.60, cy: h * 0.54, r: w * 0.055)

            case .grub:
                // Body segments, head at right
                cg.setFillColor(body.cgColor)
                let segXs: [CGFloat] = [0.14, 0.32, 0.50, 0.68]
                for i in 0..<4 {
                    let r = w * (0.11 + CGFloat(i) * 0.012)
                    cg.fillEllipse(in: CGRect(x: w * segXs[i] - r, y: h * 0.62 - r, width: r * 2, height: r * 2))
                }
                cg.setFillColor(shade(body, 1.2).cgColor)
                let headR = w * 0.16
                cg.fillEllipse(in: CGRect(x: w * 0.82 - headR, y: h * 0.56 - headR, width: headR * 2, height: headR * 2))
                // Segment highlights
                cg.setFillColor(accent.withAlphaComponent(0.75).cgColor)
                for sx in segXs {
                    let r = w * 0.04
                    cg.fillEllipse(in: CGRect(x: w * sx - r, y: h * 0.50 - r, width: r * 2, height: r * 2))
                }
                drawCuteEye(cg, cx: w * 0.85, cy: h * 0.52, r: w * 0.075)
                drawSmile(cg, cx: w * 0.89, cy: h * 0.68, r: w * 0.045)

            case .mite:
                let cx = w * 0.48; let cy = h * 0.54
                let rad = min(w, h) * 0.36
                // Fuzz
                cg.setStrokeColor(body.withAlphaComponent(0.7).cgColor)
                cg.setLineWidth(max(1.0, w * 0.03)); cg.setLineCap(.round)
                for i in 0..<10 {
                    let ang = CGFloat(i) * (CGFloat.pi * 2.0 / 10.0)
                    cg.move(to: CGPoint(x: cx + cos(ang) * rad * 0.8, y: cy + sin(ang) * rad * 0.8))
                    cg.addLine(to: CGPoint(x: cx + cos(ang) * rad * 1.28, y: cy + sin(ang) * rad * 1.28))
                    cg.strokePath()
                }
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: cx - rad, y: cy - rad, width: rad * 2, height: rad * 2))
                // Rosy cheek
                cg.setFillColor(accent.withAlphaComponent(0.6).cgColor)
                cg.fillEllipse(in: CGRect(x: cx + rad * 0.05, y: cy + rad * 0.25, width: rad * 0.45, height: rad * 0.30))
                drawCuteEye(cg, cx: cx + rad * 0.35, cy: cy - rad * 0.15, r: rad * 0.28)
                drawSmile(cg, cx: cx + rad * 0.50, cy: cy + rad * 0.38, r: rad * 0.15)

            case .bee:
                // Wings
                cg.setFillColor(UIColor(white: 1.0, alpha: 0.75).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.02, width: w * 0.24, height: h * 0.34))
                cg.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.00, width: w * 0.26, height: h * 0.36))
                // Body with stripes
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.30, width: w * 0.84, height: h * 0.56))
                cg.saveGState()
                cg.addEllipse(in: CGRect(x: w * 0.06, y: h * 0.30, width: w * 0.84, height: h * 0.56))
                cg.clip()
                cg.setFillColor(accent.cgColor)
                let stripeXs: [CGFloat] = [0.18, 0.36, 0.54]
                for sx in stripeXs {
                    cg.fill(CGRect(x: w * sx, y: h * 0.28, width: w * 0.10, height: h * 0.60))
                }
                cg.restoreGState()
                // Antenna
                cg.setStrokeColor(accent.cgColor)
                cg.setLineWidth(max(1.0, w * 0.03)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.80, y: h * 0.34))
                cg.addQuadCurve(to: CGPoint(x: w * 0.90, y: h * 0.12), control: CGPoint(x: w * 0.90, y: h * 0.26))
                cg.strokePath()
                drawCuteEye(cg, cx: w * 0.77, cy: h * 0.52, r: w * 0.09)
                drawSmile(cg, cx: w * 0.83, cy: h * 0.68, r: w * 0.05)

            case .shrimp:
                // Tail fan
                cg.setFillColor(accent.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.00, y: h * 0.44, width: w * 0.22, height: h * 0.30))
                // Curled segmented body, head at right
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.14, y: h * 0.34, width: w * 0.30, height: h * 0.42))
                cg.fillEllipse(in: CGRect(x: w * 0.34, y: h * 0.24, width: w * 0.36, height: h * 0.52))
                cg.fillEllipse(in: CGRect(x: w * 0.58, y: h * 0.22, width: w * 0.36, height: h * 0.54))
                // Segment lines
                cg.setStrokeColor(shade(body, 0.72).cgColor)
                cg.setLineWidth(max(1.0, w * 0.025)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.42, y: h * 0.30))
                cg.addLine(to: CGPoint(x: w * 0.38, y: h * 0.70))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.58, y: h * 0.26))
                cg.addLine(to: CGPoint(x: w * 0.54, y: h * 0.74))
                cg.strokePath()
                // Antennae + little legs
                cg.move(to: CGPoint(x: w * 0.86, y: h * 0.36))
                cg.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.10), control: CGPoint(x: w * 0.98, y: h * 0.28))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.66, y: h * 0.72))
                cg.addLine(to: CGPoint(x: w * 0.62, y: h * 0.92))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.76, y: h * 0.74))
                cg.addLine(to: CGPoint(x: w * 0.74, y: h * 0.94))
                cg.strokePath()
                drawCuteEye(cg, cx: w * 0.79, cy: h * 0.42, r: w * 0.08)

            case .cricket:
                // Big bent back leg
                cg.setStrokeColor(shade(body, 0.65).cgColor)
                cg.setLineWidth(max(1.4, w * 0.05)); cg.setLineCap(.round); cg.setLineJoin(.round)
                cg.move(to: CGPoint(x: w * 0.30, y: h * 0.60))
                cg.addLine(to: CGPoint(x: w * 0.12, y: h * 0.34))
                cg.addLine(to: CGPoint(x: w * 0.06, y: h * 0.92))
                cg.strokePath()
                // Body + head
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.14, y: h * 0.36, width: w * 0.68, height: h * 0.44))
                cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.32, width: w * 0.28, height: h * 0.42))
                // Front legs
                cg.setLineWidth(max(1.0, w * 0.03))
                cg.move(to: CGPoint(x: w * 0.58, y: h * 0.74))
                cg.addLine(to: CGPoint(x: w * 0.56, y: h * 0.94))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.72, y: h * 0.72))
                cg.addLine(to: CGPoint(x: w * 0.74, y: h * 0.94))
                cg.strokePath()
                // Swept-back antennae
                cg.setStrokeColor(accent.cgColor)
                cg.setLineWidth(max(1.0, w * 0.025))
                cg.move(to: CGPoint(x: w * 0.84, y: h * 0.36))
                cg.addQuadCurve(to: CGPoint(x: w * 0.40, y: h * 0.06), control: CGPoint(x: w * 0.66, y: h * 0.04))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.88, y: h * 0.40))
                cg.addQuadCurve(to: CGPoint(x: w * 0.56, y: h * 0.12), control: CGPoint(x: w * 0.78, y: h * 0.08))
                cg.strokePath()
                drawCuteEye(cg, cx: w * 0.82, cy: h * 0.48, r: w * 0.075)
                drawSmile(cg, cx: w * 0.88, cy: h * 0.62, r: w * 0.04)

            case .star:
                // Soft glow
                cg.setFillColor(accent.withAlphaComponent(0.35).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.05, y: h * 0.05, width: w * 0.90, height: h * 0.90))
                // Five-point star
                cg.setFillColor(body.cgColor)
                let scx = w * 0.50; let scy = h * 0.52
                let outerR = min(w, h) * 0.46
                let innerR = outerR * 0.5
                let sp = CGMutablePath()
                for i in 0..<10 {
                    let ang = CGFloat(i) * (CGFloat.pi / 5.0) - CGFloat.pi / 2.0
                    let r = (i % 2 == 0) ? outerR : innerR
                    let pt = CGPoint(x: scx + cos(ang) * r, y: scy + sin(ang) * r)
                    if i == 0 { sp.move(to: pt) } else { sp.addLine(to: pt) }
                }
                sp.closeSubpath()
                cg.addPath(sp); cg.fillPath()
                drawCuteEye(cg, cx: scx + outerR * 0.14, cy: scy - outerR * 0.05, r: outerR * 0.18)
                drawSmile(cg, cx: scx + outerR * 0.24, cy: scy + outerR * 0.26, r: outerR * 0.12)

            case .ant:
                // Legs
                cg.setStrokeColor(shade(body, 0.7).cgColor)
                cg.setLineWidth(max(1.0, w * 0.03)); cg.setLineCap(.round)
                let antLegXs: [CGFloat] = [0.28, 0.44, 0.60]
                for lx in antLegXs {
                    cg.move(to: CGPoint(x: w * lx, y: h * 0.68))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.05), y: h * 0.94))
                    cg.strokePath()
                }
                // Abdomen, thorax, head
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.02, y: h * 0.36, width: w * 0.40, height: h * 0.40))
                cg.fillEllipse(in: CGRect(x: w * 0.38, y: h * 0.42, width: w * 0.26, height: h * 0.30))
                cg.fillEllipse(in: CGRect(x: w * 0.60, y: h * 0.30, width: w * 0.36, height: h * 0.46))
                // Bent antennae
                cg.setStrokeColor(shade(body, 0.7).cgColor)
                cg.move(to: CGPoint(x: w * 0.84, y: h * 0.32))
                cg.addQuadCurve(to: CGPoint(x: w * 0.94, y: h * 0.10), control: CGPoint(x: w * 0.94, y: h * 0.24))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.76, y: h * 0.30))
                cg.addQuadCurve(to: CGPoint(x: w * 0.80, y: h * 0.06), control: CGPoint(x: w * 0.72, y: h * 0.14))
                cg.strokePath()
                // Abdomen highlight
                cg.setFillColor(accent.withAlphaComponent(0.5).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.42, width: w * 0.14, height: h * 0.12))
                drawCuteEye(cg, cx: w * 0.80, cy: h * 0.48, r: w * 0.085)
                drawSmile(cg, cx: w * 0.86, cy: h * 0.64, r: w * 0.045)
            }
        }
        return SKTexture(image: image)
    }

    // MARK: - Enemy creatures

    static func generateEnemyCreature(size: CGSize, style: EnemyStyle, body: UIColor, eye: UIColor, accent: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            let dark = shade(body, 0.55)
            switch style {

            case .spider:
                // Four angular legs per side
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(1.3, w * 0.032)); cg.setLineCap(.round); cg.setLineJoin(.round)
                let leftKneeXs: [CGFloat] = [0.04, 0.12, 0.20, 0.28]
                let leftKneeYs: [CGFloat] = [0.42, 0.30, 0.24, 0.20]
                for i in 0..<4 {
                    cg.move(to: CGPoint(x: w * 0.36, y: h * 0.56))
                    cg.addLine(to: CGPoint(x: w * leftKneeXs[i], y: h * leftKneeYs[i]))
                    cg.addLine(to: CGPoint(x: w * (leftKneeXs[i] - 0.03), y: h * 0.95))
                    cg.strokePath()
                }
                let rightKneeXs: [CGFloat] = [0.60, 0.68, 0.76, 0.84]
                let rightKneeYs: [CGFloat] = [0.20, 0.24, 0.30, 0.42]
                for i in 0..<4 {
                    cg.move(to: CGPoint(x: w * 0.52, y: h * 0.56))
                    cg.addLine(to: CGPoint(x: w * rightKneeXs[i], y: h * rightKneeYs[i]))
                    cg.addLine(to: CGPoint(x: w * (rightKneeXs[i] + 0.03), y: h * 0.95))
                    cg.strokePath()
                }
                // Abdomen + head
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.30, width: w * 0.50, height: h * 0.48))
                cg.fillEllipse(in: CGRect(x: w * 0.50, y: h * 0.38, width: w * 0.34, height: h * 0.38))
                // Abdomen marking
                cg.setFillColor(accent.withAlphaComponent(0.85).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.42, width: w * 0.16, height: h * 0.16))
                // Fangs
                cg.setFillColor(UIColor(white: 0.95, alpha: 1).cgColor)
                cg.move(to: CGPoint(x: w * 0.61, y: h * 0.72))
                cg.addLine(to: CGPoint(x: w * 0.64, y: h * 0.88))
                cg.addLine(to: CGPoint(x: w * 0.67, y: h * 0.72))
                cg.closePath(); cg.fillPath()
                cg.move(to: CGPoint(x: w * 0.71, y: h * 0.72))
                cg.addLine(to: CGPoint(x: w * 0.74, y: h * 0.88))
                cg.addLine(to: CGPoint(x: w * 0.77, y: h * 0.72))
                cg.closePath(); cg.fillPath()
                drawAngryEye(cg, cx: w * 0.61, cy: h * 0.50, r: w * 0.052, color: eye)
                drawAngryEye(cg, cx: w * 0.75, cy: h * 0.50, r: w * 0.052, color: eye)

            case .serpent:
                cg.setLineCap(.round)
                // Wavy body (tail at left)
                cg.setStrokeColor(body.cgColor)
                cg.setLineWidth(h * 0.28)
                cg.move(to: CGPoint(x: w * 0.06, y: h * 0.72))
                cg.addCurve(to: CGPoint(x: w * 0.62, y: h * 0.70),
                            control1: CGPoint(x: w * 0.22, y: h * 0.48),
                            control2: CGPoint(x: w * 0.44, y: h * 0.92))
                cg.strokePath()
                // Neck rising to head
                cg.move(to: CGPoint(x: w * 0.62, y: h * 0.70))
                cg.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.38), control: CGPoint(x: w * 0.76, y: h * 0.62))
                cg.strokePath()
                // Belly stripe
                cg.setStrokeColor(accent.withAlphaComponent(0.7).cgColor)
                cg.setLineWidth(max(1.0, h * 0.06))
                cg.move(to: CGPoint(x: w * 0.10, y: h * 0.78))
                cg.addCurve(to: CGPoint(x: w * 0.58, y: h * 0.76),
                            control1: CGPoint(x: w * 0.24, y: h * 0.56),
                            control2: CGPoint(x: w * 0.44, y: h * 0.96))
                cg.strokePath()
                // Head
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.64, y: h * 0.18, width: w * 0.32, height: h * 0.32))
                // Forked tongue
                cg.setStrokeColor(UIColor(red: 0.90, green: 0.20, blue: 0.25, alpha: 1).cgColor)
                cg.setLineWidth(max(1.0, w * 0.018))
                cg.move(to: CGPoint(x: w * 0.94, y: h * 0.36))
                cg.addLine(to: CGPoint(x: w * 0.99, y: h * 0.30))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.94, y: h * 0.36))
                cg.addLine(to: CGPoint(x: w * 0.99, y: h * 0.42))
                cg.strokePath()
                drawAngryEye(cg, cx: w * 0.83, cy: h * 0.30, r: w * 0.048, color: eye)

            case .golem:
                // Fists
                cg.setFillColor(dark.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.00, y: h * 0.55, width: w * 0.22, height: h * 0.30))
                cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.58, width: w * 0.22, height: h * 0.30))
                // Jagged boulder body
                cg.setFillColor(body.cgColor)
                let bp = CGMutablePath()
                bp.move(to: CGPoint(x: w * 0.14, y: h * 0.92))
                bp.addLine(to: CGPoint(x: w * 0.08, y: h * 0.48))
                bp.addLine(to: CGPoint(x: w * 0.26, y: h * 0.16))
                bp.addLine(to: CGPoint(x: w * 0.62, y: h * 0.10))
                bp.addLine(to: CGPoint(x: w * 0.84, y: h * 0.40))
                bp.addLine(to: CGPoint(x: w * 0.78, y: h * 0.92))
                bp.closeSubpath()
                cg.addPath(bp); cg.fillPath()
                // Cracks
                cg.setStrokeColor(shade(body, 0.45).cgColor)
                cg.setLineWidth(max(1.0, w * 0.02)); cg.setLineCap(.round); cg.setLineJoin(.round)
                cg.move(to: CGPoint(x: w * 0.30, y: h * 0.60))
                cg.addLine(to: CGPoint(x: w * 0.38, y: h * 0.74))
                cg.addLine(to: CGPoint(x: w * 0.34, y: h * 0.88))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.58, y: h * 0.18))
                cg.addLine(to: CGPoint(x: w * 0.54, y: h * 0.32))
                cg.strokePath()
                // Glowing seam
                cg.setStrokeColor(accent.withAlphaComponent(0.85).cgColor)
                cg.move(to: CGPoint(x: w * 0.46, y: h * 0.54))
                cg.addLine(to: CGPoint(x: w * 0.52, y: h * 0.68))
                cg.strokePath()
                // Brow ridge
                cg.setFillColor(dark.cgColor)
                cg.fill(CGRect(x: w * 0.28, y: h * 0.24, width: w * 0.46, height: h * 0.10))
                drawAngryEye(cg, cx: w * 0.42, cy: h * 0.44, r: w * 0.058, color: eye)
                drawAngryEye(cg, cx: w * 0.62, cy: h * 0.44, r: w * 0.058, color: eye)
                // Jagged mouth
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(1.2, w * 0.03))
                cg.move(to: CGPoint(x: w * 0.40, y: h * 0.68))
                cg.addLine(to: CGPoint(x: w * 0.48, y: h * 0.74))
                cg.addLine(to: CGPoint(x: w * 0.56, y: h * 0.68))
                cg.addLine(to: CGPoint(x: w * 0.64, y: h * 0.74))
                cg.strokePath()

            case .ant:
                // Angular legs
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(1.2, w * 0.035)); cg.setLineCap(.round); cg.setLineJoin(.round)
                let legXs: [CGFloat] = [0.26, 0.42, 0.58]
                for lx in legXs {
                    cg.move(to: CGPoint(x: w * lx, y: h * 0.64))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.08), y: h * 0.78))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.04), y: h * 0.95))
                    cg.strokePath()
                }
                // Pointed abdomen
                cg.setFillColor(body.cgColor)
                let ap = CGMutablePath()
                ap.move(to: CGPoint(x: w * 0.02, y: h * 0.52))
                ap.addQuadCurve(to: CGPoint(x: w * 0.42, y: h * 0.40), control: CGPoint(x: w * 0.16, y: h * 0.24))
                ap.addQuadCurve(to: CGPoint(x: w * 0.02, y: h * 0.52), control: CGPoint(x: w * 0.22, y: h * 0.80))
                ap.closeSubpath()
                cg.addPath(ap); cg.fillPath()
                // Thorax + head
                cg.fillEllipse(in: CGRect(x: w * 0.38, y: h * 0.42, width: w * 0.24, height: h * 0.28))
                cg.fillEllipse(in: CGRect(x: w * 0.58, y: h * 0.34, width: w * 0.32, height: h * 0.40))
                // Mandible pincers
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(1.2, w * 0.04))
                cg.move(to: CGPoint(x: w * 0.87, y: h * 0.44))
                cg.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.56), control: CGPoint(x: w * 0.99, y: h * 0.42))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.87, y: h * 0.62))
                cg.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.52), control: CGPoint(x: w * 0.99, y: h * 0.66))
                cg.strokePath()
                // Abdomen stripe
                cg.setFillColor(accent.withAlphaComponent(0.7).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.44, width: w * 0.14, height: h * 0.14))
                drawAngryEye(cg, cx: w * 0.75, cy: h * 0.48, r: w * 0.058, color: eye)

            case .wisp:
                // Outer glow
                cg.setFillColor(body.withAlphaComponent(0.30).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.02, y: h * 0.02, width: w * 0.86, height: h * 0.80))
                // Ghost body with wavy bottom
                cg.setFillColor(body.withAlphaComponent(0.9).cgColor)
                let gp = CGMutablePath()
                gp.move(to: CGPoint(x: w * 0.12, y: h * 0.66))
                gp.addQuadCurve(to: CGPoint(x: w * 0.45, y: h * 0.06), control: CGPoint(x: w * 0.08, y: h * 0.10))
                gp.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.66), control: CGPoint(x: w * 0.84, y: h * 0.10))
                gp.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.74), control: CGPoint(x: w * 0.72, y: h * 0.88))
                gp.addQuadCurve(to: CGPoint(x: w * 0.45, y: h * 0.78), control: CGPoint(x: w * 0.54, y: h * 0.62))
                gp.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.72), control: CGPoint(x: w * 0.36, y: h * 0.92))
                gp.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.66), control: CGPoint(x: w * 0.20, y: h * 0.58))
                gp.closeSubpath()
                cg.addPath(gp); cg.fillPath()
                // Trailing wisp
                cg.setStrokeColor(body.withAlphaComponent(0.7).cgColor)
                cg.setLineWidth(max(1.2, w * 0.04)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.22, y: h * 0.72))
                cg.addQuadCurve(to: CGPoint(x: w * 0.06, y: h * 0.94), control: CGPoint(x: w * 0.06, y: h * 0.76))
                cg.strokePath()
                // Inner swirl
                cg.setStrokeColor(accent.withAlphaComponent(0.6).cgColor)
                cg.setLineWidth(max(1.0, w * 0.03))
                cg.move(to: CGPoint(x: w * 0.34, y: h * 0.52))
                cg.addQuadCurve(to: CGPoint(x: w * 0.54, y: h * 0.56), control: CGPoint(x: w * 0.44, y: h * 0.66))
                cg.strokePath()
                drawAngryEye(cg, cx: w * 0.36, cy: h * 0.32, r: w * 0.058, color: eye)
                drawAngryEye(cg, cx: w * 0.56, cy: h * 0.32, r: w * 0.058, color: eye)

            case .swarm:
                // Cluster of bugs — pale wings behind each one so the swarm
                // reads clearly against dark swamp skies
                let dotXs: [CGFloat] = [0.18, 0.38, 0.26, 0.55, 0.44, 0.70, 0.60, 0.80]
                let dotYs: [CGFloat] = [0.30, 0.16, 0.55, 0.28, 0.66, 0.55, 0.10, 0.34]
                for i in 0..<8 {
                    let r = w * ((i % 3 == 0) ? 0.075 : 0.055)
                    cg.setFillColor(UIColor(white: 0.95, alpha: 0.55).cgColor)
                    cg.fillEllipse(in: CGRect(x: w * dotXs[i] - r * 1.5, y: h * dotYs[i] - r * 1.6, width: r * 1.6, height: r * 0.9))
                    cg.fillEllipse(in: CGRect(x: w * dotXs[i] - r * 0.1, y: h * dotYs[i] - r * 1.6, width: r * 1.6, height: r * 0.9))
                    cg.setFillColor(body.cgColor)
                    cg.fillEllipse(in: CGRect(x: w * dotXs[i] - r, y: h * dotYs[i] - r, width: r * 2, height: r * 2))
                    // Glowing red eye on every bug
                    cg.setFillColor(eye.withAlphaComponent(0.9).cgColor)
                    cg.fillEllipse(in: CGRect(x: w * dotXs[i] + r * 0.2, y: h * dotYs[i] - r * 0.4, width: r * 0.7, height: r * 0.7))
                }
                // Lead bug, bigger, angry, with pale wings
                cg.setFillColor(UIColor(white: 0.95, alpha: 0.60).cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.50, y: h * 0.60, width: w * 0.16, height: h * 0.10))
                cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.58, width: w * 0.16, height: h * 0.10))
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.46, y: h * 0.66, width: w * 0.34, height: h * 0.26))
                // Proboscis needle
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(1.0, w * 0.025)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.80, y: h * 0.78))
                cg.addLine(to: CGPoint(x: w * 0.95, y: h * 0.82))
                cg.strokePath()
                drawAngryEye(cg, cx: w * 0.72, cy: h * 0.75, r: w * 0.05, color: eye)

            case .spikeball:
                let scx = w * 0.50; let scy = h * 0.52
                let bodyR = min(w, h) * 0.33
                // Radiating spikes
                cg.setFillColor(accent.cgColor)
                for i in 0..<9 {
                    let ang = CGFloat(i) * (CGFloat.pi * 2.0 / 9.0)
                    let tip = CGPoint(x: scx + cos(ang) * bodyR * 1.55, y: scy + sin(ang) * bodyR * 1.55)
                    let b1 = CGPoint(x: scx + cos(ang + 0.26) * bodyR * 0.95, y: scy + sin(ang + 0.26) * bodyR * 0.95)
                    let b2 = CGPoint(x: scx + cos(ang - 0.26) * bodyR * 0.95, y: scy + sin(ang - 0.26) * bodyR * 0.95)
                    cg.move(to: tip); cg.addLine(to: b1); cg.addLine(to: b2)
                    cg.closePath(); cg.fillPath()
                }
                // Body
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: scx - bodyR, y: scy - bodyR, width: bodyR * 2, height: bodyR * 2))
                drawAngryEye(cg, cx: scx + bodyR * 0.15, cy: scy - bodyR * 0.10, r: bodyR * 0.28, color: eye)
                // Frown
                cg.setStrokeColor(UIColor.black.withAlphaComponent(0.7).cgColor)
                cg.setLineWidth(max(1.0, bodyR * 0.12)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: scx - bodyR * 0.25, y: scy + bodyR * 0.55))
                cg.addQuadCurve(to: CGPoint(x: scx + bodyR * 0.50, y: scy + bodyR * 0.50),
                                control: CGPoint(x: scx + bodyR * 0.12, y: scy + bodyR * 0.28))
                cg.strokePath()

            case .centipede:
                // Many little legs
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(0.9, w * 0.018)); cg.setLineCap(.round)
                let legXs: [CGFloat] = [0.12, 0.22, 0.32, 0.42, 0.52, 0.62]
                for lx in legXs {
                    cg.move(to: CGPoint(x: w * lx, y: h * 0.66))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.03), y: h * 0.92))
                    cg.strokePath()
                }
                // Alternating segments
                let segXs: [CGFloat] = [0.10, 0.24, 0.38, 0.52, 0.66]
                for i in 0..<5 {
                    cg.setFillColor(((i % 2 == 0) ? body : shade(body, 0.78)).cgColor)
                    let r = w * 0.095
                    cg.fillEllipse(in: CGRect(x: w * segXs[i] - r, y: h * 0.52 - r * 1.2, width: r * 2, height: r * 2.4))
                }
                // Head
                cg.setFillColor(dark.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.72, y: h * 0.34, width: w * 0.24, height: h * 0.40))
                // Forward antennae
                cg.setStrokeColor(dark.cgColor)
                cg.setLineWidth(max(0.9, w * 0.02))
                cg.move(to: CGPoint(x: w * 0.92, y: h * 0.40))
                cg.addLine(to: CGPoint(x: w * 0.99, y: h * 0.22))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.93, y: h * 0.56))
                cg.addLine(to: CGPoint(x: w * 0.99, y: h * 0.74))
                cg.strokePath()
                // Accent dots along the back
                cg.setFillColor(accent.withAlphaComponent(0.8).cgColor)
                for sx in segXs {
                    let r = w * 0.025
                    cg.fillEllipse(in: CGRect(x: w * sx - r, y: h * 0.40 - r, width: r * 2, height: r * 2))
                }
                drawAngryEye(cg, cx: w * 0.84, cy: h * 0.48, r: w * 0.05, color: eye)

            case .cat:
                // Tail
                cg.setStrokeColor(body.cgColor)
                cg.setLineWidth(h * 0.14); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.12, y: h * 0.60))
                cg.addQuadCurve(to: CGPoint(x: w * 0.03, y: h * 0.18), control: CGPoint(x: w * 0.00, y: h * 0.52))
                cg.strokePath()
                // Body + legs
                cg.setFillColor(body.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.08, y: h * 0.36, width: w * 0.62, height: h * 0.52))
                cg.fill(CGRect(x: w * 0.16, y: h * 0.72, width: w * 0.09, height: h * 0.24))
                cg.fill(CGRect(x: w * 0.52, y: h * 0.72, width: w * 0.09, height: h * 0.24))
                // Stripes
                cg.setStrokeColor(accent.cgColor)
                cg.setLineWidth(max(1.2, w * 0.025)); cg.setLineCap(.round)
                let stripeXs: [CGFloat] = [0.24, 0.34, 0.44]
                for sx in stripeXs {
                    cg.move(to: CGPoint(x: w * sx, y: h * 0.40))
                    cg.addQuadCurve(to: CGPoint(x: w * (sx + 0.02), y: h * 0.62),
                                    control: CGPoint(x: w * (sx + 0.06), y: h * 0.50))
                    cg.strokePath()
                }
                // Ears then head
                cg.setFillColor(body.cgColor)
                cg.move(to: CGPoint(x: w * 0.60, y: h * 0.28))
                cg.addLine(to: CGPoint(x: w * 0.58, y: h * 0.02))
                cg.addLine(to: CGPoint(x: w * 0.72, y: h * 0.20))
                cg.closePath(); cg.fillPath()
                cg.move(to: CGPoint(x: w * 0.80, y: h * 0.18))
                cg.addLine(to: CGPoint(x: w * 0.88, y: h * 0.00))
                cg.addLine(to: CGPoint(x: w * 0.93, y: h * 0.26))
                cg.closePath(); cg.fillPath()
                cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.16, width: w * 0.38, height: h * 0.46))
                // Nose
                cg.setFillColor(dark.cgColor)
                cg.fillEllipse(in: CGRect(x: w * 0.88, y: h * 0.42, width: w * 0.05, height: h * 0.06))
                // Whiskers
                cg.setStrokeColor(UIColor(white: 0.95, alpha: 0.8).cgColor)
                cg.setLineWidth(max(0.8, w * 0.012)); cg.setLineCap(.round)
                cg.move(to: CGPoint(x: w * 0.86, y: h * 0.50))
                cg.addLine(to: CGPoint(x: w * 0.99, y: h * 0.46))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.86, y: h * 0.54))
                cg.addLine(to: CGPoint(x: w * 0.99, y: h * 0.58))
                cg.strokePath()
                // Fang
                cg.setFillColor(UIColor.white.cgColor)
                cg.move(to: CGPoint(x: w * 0.80, y: h * 0.56))
                cg.addLine(to: CGPoint(x: w * 0.82, y: h * 0.66))
                cg.addLine(to: CGPoint(x: w * 0.84, y: h * 0.56))
                cg.closePath(); cg.fillPath()
                drawAngryEye(cg, cx: w * 0.76, cy: h * 0.34, r: w * 0.05, color: eye)
            }
        }
        return SKTexture(image: image)
    }

    // MARK: - Bespoke creatures

    static func generateSeahorseTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            let body = UIColor(red: 1.00, green: 0.72, blue: 0.35, alpha: 1)
            let fin = UIColor(red: 0.95, green: 0.50, blue: 0.45, alpha: 1)
            // Curled tail (spiral at bottom)
            cg.setStrokeColor(body.cgColor)
            cg.setLineWidth(w * 0.14); cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.46, y: h * 0.66))
            cg.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.88), control: CGPoint(x: w * 0.28, y: h * 0.70))
            cg.strokePath()
            cg.setLineWidth(w * 0.10)
            cg.move(to: CGPoint(x: w * 0.30, y: h * 0.88))
            cg.addQuadCurve(to: CGPoint(x: w * 0.52, y: h * 0.90), control: CGPoint(x: w * 0.44, y: h * 0.98))
            cg.strokePath()
            // Dorsal fin (back, left side)
            cg.setFillColor(fin.withAlphaComponent(0.85).cgColor)
            let fp = CGMutablePath()
            fp.move(to: CGPoint(x: w * 0.34, y: h * 0.34))
            fp.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.62), control: CGPoint(x: w * 0.06, y: h * 0.48))
            fp.addLine(to: CGPoint(x: w * 0.42, y: h * 0.56))
            fp.closeSubpath()
            cg.addPath(fp); cg.fillPath()
            // Body (upright, belly out)
            cg.setFillColor(body.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.26, width: w * 0.40, height: h * 0.44))
            // Head
            cg.fillEllipse(in: CGRect(x: w * 0.36, y: h * 0.08, width: w * 0.36, height: h * 0.22))
            // Snout tube
            cg.fill(CGRect(x: w * 0.66, y: h * 0.14, width: w * 0.30, height: h * 0.07))
            // Coronet (little crown)
            cg.setFillColor(fin.cgColor)
            cg.move(to: CGPoint(x: w * 0.42, y: h * 0.09))
            cg.addLine(to: CGPoint(x: w * 0.48, y: h * 0.00))
            cg.addLine(to: CGPoint(x: w * 0.56, y: h * 0.08))
            cg.closePath(); cg.fillPath()
            // Belly ridges
            cg.setStrokeColor(shade(body, 0.75).cgColor)
            cg.setLineWidth(max(1.0, w * 0.03))
            let ridgeYs: [CGFloat] = [0.38, 0.48, 0.58]
            for ry in ridgeYs {
                cg.move(to: CGPoint(x: w * 0.52, y: h * ry))
                cg.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * ry), control: CGPoint(x: w * 0.62, y: h * (ry + 0.04)))
                cg.strokePath()
            }
            drawCuteEye(cg, cx: w * 0.56, cy: h * 0.17, r: w * 0.09)
        }
        return SKTexture(image: image)
    }

    static func generateKomodoTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            let body = UIColor(red: 0.42, green: 0.40, blue: 0.28, alpha: 1)
            let dark = shade(body, 0.6)
            // Long tapering tail (left)
            cg.setFillColor(body.cgColor)
            cg.move(to: CGPoint(x: w * 0.00, y: h * 0.58))
            cg.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.42), control: CGPoint(x: w * 0.14, y: h * 0.40))
            cg.addLine(to: CGPoint(x: w * 0.34, y: h * 0.68))
            cg.closePath(); cg.fillPath()
            // Stubby bent legs
            cg.setStrokeColor(dark.cgColor)
            cg.setLineWidth(max(1.6, w * 0.035)); cg.setLineCap(.round); cg.setLineJoin(.round)
            let legXs: [CGFloat] = [0.36, 0.48, 0.62, 0.72]
            for lx in legXs {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.68))
                cg.addLine(to: CGPoint(x: w * (lx - 0.05), y: h * 0.82))
                cg.addLine(to: CGPoint(x: w * (lx - 0.02), y: h * 0.96))
                cg.strokePath()
            }
            // Low-slung body
            cg.setFillColor(body.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.26, y: h * 0.36, width: w * 0.52, height: h * 0.40))
            // Head with heavy jaw
            cg.fillEllipse(in: CGRect(x: w * 0.72, y: h * 0.30, width: w * 0.24, height: h * 0.34))
            cg.setFillColor(dark.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.80, y: h * 0.46, width: w * 0.17, height: h * 0.14))
            // Forked tongue
            cg.setStrokeColor(UIColor(red: 0.90, green: 0.25, blue: 0.30, alpha: 1).cgColor)
            cg.setLineWidth(max(1.0, w * 0.014))
            cg.move(to: CGPoint(x: w * 0.96, y: h * 0.48))
            cg.addLine(to: CGPoint(x: w * 1.00, y: h * 0.42))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.96, y: h * 0.48))
            cg.addLine(to: CGPoint(x: w * 1.00, y: h * 0.52))
            cg.strokePath()
            // Scale dots along the back
            cg.setFillColor(dark.withAlphaComponent(0.8).cgColor)
            let scaleXs: [CGFloat] = [0.34, 0.44, 0.54, 0.64]
            for sx in scaleXs {
                let r = w * 0.018
                cg.fillEllipse(in: CGRect(x: w * sx - r, y: h * 0.40 - r, width: r * 2, height: r * 2))
            }
            drawAngryEye(cg, cx: w * 0.84, cy: h * 0.40, r: w * 0.035, color: UIColor(red: 0.95, green: 0.75, blue: 0.20, alpha: 1))
        }
        return SKTexture(image: image)
    }

    static func generateSlothTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            let body = UIColor(red: 0.48, green: 0.42, blue: 0.34, alpha: 1)
            let dark = shade(body, 0.6)
            // Arms reaching up to grip the vine
            cg.setStrokeColor(body.cgColor)
            cg.setLineWidth(w * 0.11); cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.38, y: h * 0.34))
            cg.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.03), control: CGPoint(x: w * 0.24, y: h * 0.16))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.60, y: h * 0.34))
            cg.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.03), control: CGPoint(x: w * 0.74, y: h * 0.16))
            cg.strokePath()
            // Gripping claws at the top
            cg.setStrokeColor(dark.cgColor)
            cg.setLineWidth(max(1.2, w * 0.03))
            cg.move(to: CGPoint(x: w * 0.26, y: h * 0.04)); cg.addLine(to: CGPoint(x: w * 0.36, y: h * 0.02)); cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.64, y: h * 0.02)); cg.addLine(to: CGPoint(x: w * 0.73, y: h * 0.05)); cg.strokePath()
            // Shaggy body hanging below
            cg.setFillColor(body.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.30, width: w * 0.64, height: h * 0.52))
            // Fur fringe
            cg.setStrokeColor(body.withAlphaComponent(0.8).cgColor)
            cg.setLineWidth(max(1.0, w * 0.025))
            let furXs: [CGFloat] = [0.26, 0.38, 0.50, 0.62, 0.72]
            for fx in furXs {
                cg.move(to: CGPoint(x: w * fx, y: h * 0.78))
                cg.addLine(to: CGPoint(x: w * (fx - 0.03), y: h * 0.88))
                cg.strokePath()
            }
            // Head (pale face)
            cg.setFillColor(UIColor(red: 0.78, green: 0.70, blue: 0.58, alpha: 1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.32, width: w * 0.40, height: h * 0.30))
            // Dark eye stripes
            cg.setStrokeColor(dark.cgColor)
            cg.setLineWidth(w * 0.055); cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.38, y: h * 0.40)); cg.addLine(to: CGPoint(x: w * 0.30, y: h * 0.48)); cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.62, y: h * 0.40)); cg.addLine(to: CGPoint(x: w * 0.70, y: h * 0.48)); cg.strokePath()
            // Nose + mouth
            cg.setFillColor(dark.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.46, y: h * 0.48, width: w * 0.08, height: h * 0.05))
            // Long swiping claws (free paw at the side)
            cg.setStrokeColor(UIColor(white: 0.92, alpha: 1).cgColor)
            cg.setLineWidth(max(1.2, w * 0.028))
            let clawYs: [CGFloat] = [0.62, 0.67, 0.72]
            for cy in clawYs {
                cg.move(to: CGPoint(x: w * 0.80, y: h * cy))
                cg.addQuadCurve(to: CGPoint(x: w * 0.97, y: h * (cy + 0.04)), control: CGPoint(x: w * 0.92, y: h * cy))
                cg.strokePath()
            }
            drawAngryEye(cg, cx: w * 0.40, cy: h * 0.42, r: w * 0.045, color: UIColor(red: 0.30, green: 0.22, blue: 0.15, alpha: 1))
            drawAngryEye(cg, cx: w * 0.60, cy: h * 0.42, r: w * 0.045, color: UIColor(red: 0.30, green: 0.22, blue: 0.15, alpha: 1))
        }
        return SKTexture(image: image)
    }

    static func generateGuardDogTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            let body = UIColor(red: 0.55, green: 0.38, blue: 0.22, alpha: 1)
            let dark = shade(body, 0.55)
            // Tail up
            cg.setStrokeColor(body.cgColor)
            cg.setLineWidth(h * 0.10); cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.10, y: h * 0.42))
            cg.addQuadCurve(to: CGPoint(x: w * 0.02, y: h * 0.12), control: CGPoint(x: w * 0.00, y: h * 0.34))
            cg.strokePath()
            // Legs
            cg.setFillColor(body.cgColor)
            cg.fill(CGRect(x: w * 0.14, y: h * 0.66, width: w * 0.08, height: h * 0.30))
            cg.fill(CGRect(x: w * 0.30, y: h * 0.68, width: w * 0.08, height: h * 0.28))
            cg.fill(CGRect(x: w * 0.48, y: h * 0.66, width: w * 0.08, height: h * 0.30))
            // Body (leaning forward)
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.30, width: w * 0.58, height: h * 0.46))
            // Chest patch
            cg.setFillColor(shade(body, 1.25).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.48, width: w * 0.20, height: h * 0.24))
            // Head
            cg.setFillColor(body.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.10, width: w * 0.34, height: h * 0.42))
            // Pointed ears
            cg.move(to: CGPoint(x: w * 0.60, y: h * 0.20))
            cg.addLine(to: CGPoint(x: w * 0.58, y: h * 0.00))
            cg.addLine(to: CGPoint(x: w * 0.70, y: h * 0.12))
            cg.closePath(); cg.fillPath()
            cg.move(to: CGPoint(x: w * 0.78, y: h * 0.10))
            cg.addLine(to: CGPoint(x: w * 0.86, y: h * 0.00))
            cg.addLine(to: CGPoint(x: w * 0.88, y: h * 0.16))
            cg.closePath(); cg.fillPath()
            // Snout with open jaw
            cg.fill(CGRect(x: w * 0.84, y: h * 0.26, width: w * 0.14, height: h * 0.13))
            cg.setFillColor(dark.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.94, y: h * 0.25, width: w * 0.05, height: h * 0.07))
            // Open mouth + teeth
            cg.setFillColor(UIColor(red: 0.45, green: 0.12, blue: 0.12, alpha: 1).cgColor)
            cg.move(to: CGPoint(x: w * 0.84, y: h * 0.42))
            cg.addLine(to: CGPoint(x: w * 0.98, y: h * 0.44))
            cg.addLine(to: CGPoint(x: w * 0.86, y: h * 0.54))
            cg.closePath(); cg.fillPath()
            cg.setFillColor(UIColor.white.cgColor)
            cg.move(to: CGPoint(x: w * 0.87, y: h * 0.43))
            cg.addLine(to: CGPoint(x: w * 0.89, y: h * 0.49))
            cg.addLine(to: CGPoint(x: w * 0.91, y: h * 0.43))
            cg.closePath(); cg.fillPath()
            // Red collar with tag
            cg.setStrokeColor(UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1).cgColor)
            cg.setLineWidth(h * 0.07)
            cg.move(to: CGPoint(x: w * 0.56, y: h * 0.46))
            cg.addQuadCurve(to: CGPoint(x: w * 0.74, y: h * 0.52), control: CGPoint(x: w * 0.64, y: h * 0.54))
            cg.strokePath()
            cg.setFillColor(UIColor(red: 0.95, green: 0.80, blue: 0.20, alpha: 1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.52, width: w * 0.06, height: h * 0.09))
            drawAngryEye(cg, cx: w * 0.74, cy: h * 0.26, r: w * 0.045, color: UIColor(red: 0.90, green: 0.55, blue: 0.15, alpha: 1))
        }
        return SKTexture(image: image)
    }

    static func generateBubblePowerupTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            // Translucent body
            cg.setFillColor(UIColor(red: 0.55, green: 0.80, blue: 1.00, alpha: 0.30).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.04, y: h * 0.04, width: w * 0.92, height: h * 0.92))
            // Rim
            cg.setStrokeColor(UIColor(red: 0.75, green: 0.92, blue: 1.00, alpha: 0.85).cgColor)
            cg.setLineWidth(max(1.2, w * 0.05))
            cg.strokeEllipse(in: CGRect(x: w * 0.06, y: h * 0.06, width: w * 0.88, height: h * 0.88))
            // Gleam highlight (upper left)
            cg.setFillColor(UIColor(white: 1.0, alpha: 0.65).cgColor)
            cg.saveGState()
            cg.translateBy(x: w * 0.32, y: h * 0.24)
            cg.rotate(by: -0.5)
            cg.fillEllipse(in: CGRect(x: -w * 0.13, y: -h * 0.07, width: w * 0.26, height: h * 0.14))
            cg.restoreGState()
            // Tiny sparkle lower right
            cg.setFillColor(UIColor(white: 1.0, alpha: 0.5).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.64, y: h * 0.62, width: w * 0.10, height: h * 0.10))
        }
        return SKTexture(image: image)
    }

    static func generateCrowBossTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            let feather = UIColor(red: 0.13, green: 0.13, blue: 0.17, alpha: 1)
            let sheen = UIColor(red: 0.30, green: 0.28, blue: 0.45, alpha: 1)
            // Tail feathers (left)
            cg.setFillColor(feather.cgColor)
            let tailYs: [CGFloat] = [0.42, 0.50, 0.58]
            for ty in tailYs {
                cg.move(to: CGPoint(x: w * 0.22, y: h * ty))
                cg.addLine(to: CGPoint(x: w * 0.00, y: h * (ty - 0.06)))
                cg.addLine(to: CGPoint(x: w * 0.02, y: h * (ty + 0.06)))
                cg.closePath(); cg.fillPath()
            }
            // Body
            cg.fillEllipse(in: CGRect(x: w * 0.14, y: h * 0.26, width: w * 0.52, height: h * 0.52))
            // Raised wing
            cg.setFillColor(sheen.withAlphaComponent(0.9).cgColor)
            let wing = CGMutablePath()
            wing.move(to: CGPoint(x: w * 0.30, y: h * 0.40))
            wing.addQuadCurve(to: CGPoint(x: w * 0.10, y: h * 0.06), control: CGPoint(x: w * 0.06, y: h * 0.28))
            wing.addQuadCurve(to: CGPoint(x: w * 0.46, y: h * 0.32), control: CGPoint(x: w * 0.34, y: h * 0.10))
            wing.closeSubpath()
            cg.addPath(wing); cg.fillPath()
            // Head
            cg.setFillColor(feather.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.54, y: h * 0.10, width: w * 0.30, height: h * 0.34))
            // Big open beak
            cg.setFillColor(UIColor(red: 0.95, green: 0.70, blue: 0.15, alpha: 1).cgColor)
            cg.move(to: CGPoint(x: w * 0.80, y: h * 0.22))
            cg.addLine(to: CGPoint(x: w * 1.00, y: h * 0.26))
            cg.addLine(to: CGPoint(x: w * 0.81, y: h * 0.32))
            cg.closePath(); cg.fillPath()
            cg.setFillColor(UIColor(red: 0.80, green: 0.55, blue: 0.10, alpha: 1).cgColor)
            cg.move(to: CGPoint(x: w * 0.80, y: h * 0.34))
            cg.addLine(to: CGPoint(x: w * 0.97, y: h * 0.38))
            cg.addLine(to: CGPoint(x: w * 0.80, y: h * 0.42))
            cg.closePath(); cg.fillPath()
            // Angry red eye
            drawAngryEye(cg, cx: w * 0.68, cy: h * 0.24, r: w * 0.030, color: UIColor(red: 0.95, green: 0.20, blue: 0.15, alpha: 1))
            // Legs + talons
            cg.setStrokeColor(UIColor(red: 0.35, green: 0.28, blue: 0.10, alpha: 1).cgColor)
            cg.setLineWidth(max(2.0, w * 0.02)); cg.setLineCap(.round); cg.setLineJoin(.round)
            let legXs: [CGFloat] = [0.36, 0.48]
            for lx in legXs {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.76))
                cg.addLine(to: CGPoint(x: w * lx, y: h * 0.92))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * (lx - 0.04), y: h * 0.98))
                cg.addLine(to: CGPoint(x: w * lx, y: h * 0.92))
                cg.addLine(to: CGPoint(x: w * (lx + 0.04), y: h * 0.98))
                cg.strokePath()
            }
            // Feather sheen strokes on the body
            cg.setStrokeColor(sheen.withAlphaComponent(0.5).cgColor)
            cg.setLineWidth(max(1.5, w * 0.012))
            let sheenXs: [CGFloat] = [0.28, 0.38, 0.48]
            for sx in sheenXs {
                cg.move(to: CGPoint(x: w * sx, y: h * 0.62))
                cg.addQuadCurve(to: CGPoint(x: w * (sx + 0.08), y: h * 0.74), control: CGPoint(x: w * (sx + 0.08), y: h * 0.64))
                cg.strokePath()
            }
        }
        return SKTexture(image: image)
    }

    static func generateVacuumTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            // Vortex body
            cg.setFillColor(UIColor(red: 0.30, green: 0.75, blue: 0.95, alpha: 0.85).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.05, y: h * 0.05, width: w * 0.90, height: h * 0.90))
            // Spiral arms
            cg.setStrokeColor(UIColor(white: 1.0, alpha: 0.9).cgColor)
            cg.setLineWidth(max(1.5, w * 0.06)); cg.setLineCap(.round)
            let cx = w * 0.5; let cy = h * 0.5
            cg.addArc(center: CGPoint(x: cx, y: cy), radius: w * 0.34, startAngle: 0, endAngle: CGFloat.pi * 1.2, clockwise: false)
            cg.strokePath()
            cg.addArc(center: CGPoint(x: cx + w * 0.04, y: cy - h * 0.02), radius: w * 0.20, startAngle: CGFloat.pi * 1.2, endAngle: CGFloat.pi * 2.4, clockwise: false)
            cg.strokePath()
            // Center dot
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillEllipse(in: CGRect(x: cx - w * 0.05, y: cy - h * 0.05, width: w * 0.10, height: h * 0.10))
        }
        return SKTexture(image: image)
    }

    static func generateUFOBossTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width; let h = size.height
            // Tractor beam glow underneath
            cg.setFillColor(UIColor(red: 0.45, green: 1.00, blue: 0.55, alpha: 0.18).cgColor)
            cg.move(to: CGPoint(x: w * 0.38, y: h * 0.55))
            cg.addLine(to: CGPoint(x: w * 0.62, y: h * 0.55))
            cg.addLine(to: CGPoint(x: w * 0.78, y: h * 1.00))
            cg.addLine(to: CGPoint(x: w * 0.22, y: h * 1.00))
            cg.closePath(); cg.fillPath()
            // Glass dome
            cg.setFillColor(UIColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 0.45).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.32, y: h * 0.06, width: w * 0.36, height: h * 0.40))
            // Alien pilot: green head with big black eyes
            cg.setFillColor(UIColor(red: 0.45, green: 0.85, blue: 0.35, alpha: 1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.43, y: h * 0.16, width: w * 0.14, height: h * 0.20))
            cg.setFillColor(UIColor.black.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.455, y: h * 0.21, width: w * 0.035, height: h * 0.07))
            cg.fillEllipse(in: CGRect(x: w * 0.51, y: h * 0.21, width: w * 0.035, height: h * 0.07))
            // Saucer hull
            cg.setFillColor(UIColor(red: 0.55, green: 0.58, blue: 0.68, alpha: 1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.30, width: w * 0.88, height: h * 0.34))
            // Hull underside shading
            cg.setFillColor(UIColor(red: 0.40, green: 0.42, blue: 0.52, alpha: 1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.44, width: w * 0.88, height: h * 0.18))
            // Running lights
            let lightXs: [CGFloat] = [0.16, 0.32, 0.50, 0.68, 0.84]
            let lightColors: [UIColor] = [
                UIColor(red: 1.00, green: 0.35, blue: 0.35, alpha: 1),
                UIColor(red: 1.00, green: 0.85, blue: 0.25, alpha: 1),
                UIColor(red: 0.35, green: 1.00, blue: 0.45, alpha: 1),
                UIColor(red: 0.35, green: 0.65, blue: 1.00, alpha: 1),
                UIColor(red: 0.90, green: 0.45, blue: 1.00, alpha: 1),
            ]
            for i in 0..<5 {
                cg.setFillColor(lightColors[i].cgColor)
                let r = w * 0.022
                cg.fillEllipse(in: CGRect(x: w * lightXs[i] - r, y: h * 0.47 - r, width: r * 2, height: r * 2))
            }
        }
        return SKTexture(image: image)
    }

    // MARK: - Central registry: creature name -> styled texture
    // Single source of truth used by both GameScene spawns and the Bugopedia,
    // so the collection icons always match the in-game look.

    static func biomeCreatureTexture(named name: String, size: CGSize) -> SKTexture {
        switch name {
        // Underwater
        case "Starfish":
            return generateFoodCreature(size: size, style: .star, body: UIColor(red: 1.00, green: 0.55, blue: 0.38, alpha: 1), accent: UIColor(red: 1.00, green: 0.78, blue: 0.58, alpha: 1))
        case "Seahorse":
            return generateSeahorseTexture(size: size)
        case "Komodo Dragon":
            return generateKomodoTexture(size: size)
        case "Sloth":
            return generateSlothTexture(size: size)
        case "Guard Dog":
            return generateGuardDogTexture(size: size)
        case "Shrimplet":
            return generateFoodCreature(size: size, style: .shrimp, body: UIColor(red: 0.90, green: 0.55, blue: 0.45, alpha: 1), accent: UIColor(red: 0.98, green: 0.72, blue: 0.60, alpha: 1))
        case "Sea Snail":
            return generateFoodCreature(size: size, style: .snail, body: UIColor(red: 0.78, green: 0.68, blue: 0.62, alpha: 1), accent: UIColor(red: 0.55, green: 0.45, blue: 0.60, alpha: 1))
        // Volcano
        case "Ember Beetle":
            return generateFoodCreature(size: size, style: .beetle, body: UIColor(red: 0.70, green: 0.30, blue: 0.10, alpha: 1), accent: UIColor(red: 1.00, green: 0.62, blue: 0.15, alpha: 1))
        case "Ash Moth":
            return generateFoodCreature(size: size, style: .moth, body: UIColor(red: 0.62, green: 0.60, blue: 0.57, alpha: 1), accent: UIColor(red: 0.86, green: 0.84, blue: 0.80, alpha: 1))
        case "Magma Snail":
            return generateFoodCreature(size: size, style: .snail, body: UIColor(red: 0.95, green: 0.55, blue: 0.20, alpha: 1), accent: UIColor(red: 0.36, green: 0.26, blue: 0.24, alpha: 1))
        case "Fire Ant":
            return generateEnemyCreature(size: size, style: .ant, body: UIColor(red: 0.75, green: 0.15, blue: 0.08, alpha: 1), eye: UIColor.orange, accent: UIColor(red: 0.98, green: 0.50, blue: 0.10, alpha: 1))
        case "Obsidian Golem":
            return generateEnemyCreature(size: size, style: .golem, body: UIColor(red: 0.20, green: 0.17, blue: 0.23, alpha: 1), eye: UIColor.red, accent: UIColor(red: 0.95, green: 0.32, blue: 0.10, alpha: 1))
        // Cloud
        case "Cloud Mite":
            return generateFoodCreature(size: size, style: .mite, body: UIColor(red: 0.90, green: 0.92, blue: 0.98, alpha: 1), accent: UIColor(red: 0.55, green: 0.70, blue: 0.95, alpha: 1))
        case "Star Bug":
            return generateFoodCreature(size: size, style: .star, body: UIColor(red: 0.95, green: 0.88, blue: 0.40, alpha: 1), accent: UIColor(red: 1.00, green: 0.97, blue: 0.75, alpha: 1))
        case "Sky Butterfly":
            return generateButterflyTexture(size: size,
                                            upperWing: UIColor(red: 0.30, green: 0.55, blue: 0.95, alpha: 0.95),
                                            lowerWing: UIColor(red: 0.22, green: 0.42, blue: 0.85, alpha: 0.90))
        case "Wind Sprite":
            return generateEnemyCreature(size: size, style: .wisp, body: UIColor(red: 0.72, green: 0.85, blue: 0.92, alpha: 1), eye: UIColor(red: 0.05, green: 0.55, blue: 0.75, alpha: 1), accent: UIColor.white)
        case "Lightning Bug":
            return generateEnemyCreature(size: size, style: .spikeball, body: UIColor(red: 0.95, green: 0.90, blue: 0.30, alpha: 1), eye: UIColor(red: 0.15, green: 0.35, blue: 0.90, alpha: 1), accent: UIColor(red: 1.00, green: 0.98, blue: 0.70, alpha: 1))
        case "Mosquito Swarm":
            return generateEnemyCreature(size: size, style: .swarm, body: UIColor(red: 0.35, green: 0.30, blue: 0.28, alpha: 1), eye: UIColor.red, accent: UIColor(red: 0.75, green: 0.72, blue: 0.68, alpha: 1))
        // Swamp
        case "Mud Cricket":
            return generateFoodCreature(size: size, style: .cricket, body: UIColor(red: 0.50, green: 0.42, blue: 0.28, alpha: 1), accent: UIColor(red: 0.32, green: 0.26, blue: 0.16, alpha: 1))
        case "Swamp Fly":
            return generateFoodCreature(size: size, style: .moth, body: UIColor(red: 0.42, green: 0.50, blue: 0.28, alpha: 1), accent: UIColor(red: 0.65, green: 0.72, blue: 0.45, alpha: 1))
        case "Leech":
            return generateFoodCreature(size: size, style: .grub, body: UIColor(red: 0.38, green: 0.22, blue: 0.18, alpha: 1), accent: UIColor(red: 0.62, green: 0.38, blue: 0.30, alpha: 1))
        case "Bog Spider":
            return generateEnemyCreature(size: size, style: .spider, body: UIColor(red: 0.35, green: 0.30, blue: 0.22, alpha: 1), eye: UIColor.red, accent: UIColor(red: 0.60, green: 0.52, blue: 0.30, alpha: 1))
        case "Swamp Snake":
            return generateEnemyCreature(size: size, style: .serpent, body: UIColor(red: 0.32, green: 0.35, blue: 0.20, alpha: 1), eye: UIColor.yellow, accent: UIColor(red: 0.62, green: 0.62, blue: 0.35, alpha: 1))
        case "Alligator":
            return generateEnemyCreature(size: size, style: .serpent, body: UIColor(red: 0.28, green: 0.38, blue: 0.18, alpha: 1), eye: UIColor.yellow, accent: UIColor(red: 0.55, green: 0.60, blue: 0.35, alpha: 1))
        // City / Garden
        case "Garden Ant":
            return generateFoodCreature(size: size, style: .ant, body: UIColor(red: 0.22, green: 0.18, blue: 0.15, alpha: 1), accent: UIColor(red: 0.50, green: 0.42, blue: 0.35, alpha: 1))
        case "Honeybee":
            return generateFoodCreature(size: size, style: .bee, body: UIColor(red: 0.92, green: 0.75, blue: 0.15, alpha: 1), accent: UIColor(red: 0.25, green: 0.20, blue: 0.10, alpha: 1))
        case "Pill Bug":
            return generateFoodCreature(size: size, style: .grub, body: UIColor(red: 0.48, green: 0.48, blue: 0.52, alpha: 1), accent: UIColor(red: 0.72, green: 0.72, blue: 0.76, alpha: 1))
        case "Garden Spider":
            return generateEnemyCreature(size: size, style: .spider, body: UIColor(red: 0.50, green: 0.42, blue: 0.25, alpha: 1), eye: UIColor.red, accent: UIColor(red: 0.80, green: 0.65, blue: 0.30, alpha: 1))
        case "Garden Snake":
            return generateEnemyCreature(size: size, style: .serpent, body: UIColor(red: 0.30, green: 0.55, blue: 0.22, alpha: 1), eye: UIColor.yellow, accent: UIColor(red: 0.70, green: 0.85, blue: 0.45, alpha: 1))
        case "House Cat":
            return generateEnemyCreature(size: size, style: .cat, body: UIColor(red: 0.75, green: 0.55, blue: 0.35, alpha: 1), eye: UIColor(red: 0.25, green: 0.85, blue: 0.35, alpha: 1), accent: UIColor(red: 0.50, green: 0.34, blue: 0.20, alpha: 1))
        // Ruins
        case "Scarab":
            return generateFoodCreature(size: size, style: .beetle, body: UIColor(red: 0.80, green: 0.65, blue: 0.20, alpha: 1), accent: UIColor(red: 0.20, green: 0.65, blue: 0.60, alpha: 1))
        case "Dust Mite":
            return generateFoodCreature(size: size, style: .mite, body: UIColor(red: 0.68, green: 0.60, blue: 0.46, alpha: 1), accent: UIColor(red: 0.85, green: 0.78, blue: 0.62, alpha: 1))
        case "Temple Worm":
            return generateFoodCreature(size: size, style: .grub, body: UIColor(red: 0.58, green: 0.44, blue: 0.32, alpha: 1), accent: UIColor(red: 0.85, green: 0.70, blue: 0.30, alpha: 1))
        case "Stone Guardian":
            return generateEnemyCreature(size: size, style: .golem, body: UIColor(red: 0.48, green: 0.45, blue: 0.40, alpha: 1), eye: UIColor(red: 0.90, green: 0.65, blue: 0.10, alpha: 1), accent: UIColor(red: 0.90, green: 0.65, blue: 0.10, alpha: 1))
        case "Tomb Spider":
            return generateEnemyCreature(size: size, style: .spider, body: UIColor(red: 0.35, green: 0.28, blue: 0.22, alpha: 1), eye: UIColor(red: 0.60, green: 0.90, blue: 0.30, alpha: 1), accent: UIColor(red: 0.60, green: 0.90, blue: 0.30, alpha: 1))
        case "Sand Viper":
            return generateEnemyCreature(size: size, style: .serpent, body: UIColor(red: 0.70, green: 0.58, blue: 0.35, alpha: 1), eye: UIColor.yellow, accent: UIColor(red: 0.45, green: 0.35, blue: 0.20, alpha: 1))
        case "Curse Wraith":
            return generateEnemyCreature(size: size, style: .wisp, body: UIColor(red: 0.40, green: 0.35, blue: 0.50, alpha: 1), eye: UIColor(red: 0.85, green: 0.25, blue: 0.85, alpha: 1), accent: UIColor(red: 0.70, green: 0.55, blue: 0.85, alpha: 1))
        // Mushroom
        case "Spore Bug":
            return generateFoodCreature(size: size, style: .beetle, body: UIColor(red: 0.55, green: 0.40, blue: 0.55, alpha: 1), accent: UIColor(red: 0.85, green: 0.72, blue: 0.88, alpha: 1))
        case "Glow Shroom":
            return generateFoodCreature(size: size, style: .jelly, body: UIColor(red: 0.40, green: 0.70, blue: 0.45, alpha: 1), accent: UIColor(red: 0.80, green: 1.00, blue: 0.50, alpha: 1))
        case "Fungus Gnat":
            return generateFoodCreature(size: size, style: .moth, body: UIColor(red: 0.48, green: 0.38, blue: 0.32, alpha: 1), accent: UIColor(red: 0.72, green: 0.62, blue: 0.50, alpha: 1))
        case "Shroom Golem":
            return generateEnemyCreature(size: size, style: .golem, body: UIColor(red: 0.50, green: 0.35, blue: 0.28, alpha: 1), eye: UIColor(red: 0.80, green: 0.90, blue: 0.40, alpha: 1), accent: UIColor(red: 0.80, green: 0.90, blue: 0.40, alpha: 1))
        case "Mycelium Crawler":
            return generateEnemyCreature(size: size, style: .centipede, body: UIColor(red: 0.62, green: 0.52, blue: 0.44, alpha: 1), eye: UIColor(red: 0.95, green: 0.90, blue: 0.75, alpha: 1), accent: UIColor(red: 0.88, green: 0.80, blue: 0.68, alpha: 1))
        case "Cap Bouncer":
            return generateEnemyCreature(size: size, style: .spikeball, body: UIColor(red: 0.80, green: 0.25, blue: 0.20, alpha: 1), eye: UIColor.white, accent: UIColor(red: 0.95, green: 0.90, blue: 0.85, alpha: 1))
        case "Toxic Spore":
            return generateEnemyCreature(size: size, style: .spikeball, body: UIColor(red: 0.50, green: 0.65, blue: 0.15, alpha: 1), eye: UIColor.yellow, accent: UIColor(red: 0.72, green: 0.85, blue: 0.30, alpha: 1))
        // Crystal
        case "Gem Larva":
            return generateFoodCreature(size: size, style: .grub, body: UIColor(red: 0.50, green: 0.35, blue: 0.75, alpha: 1), accent: UIColor(red: 0.80, green: 0.90, blue: 1.00, alpha: 1))
        case "Prism Fly":
            return generateFoodCreature(size: size, style: .moth, body: UIColor(red: 0.70, green: 0.55, blue: 0.90, alpha: 1), accent: UIColor(red: 0.95, green: 0.90, blue: 1.00, alpha: 1))
        case "Crystal Mite":
            return generateFoodCreature(size: size, style: .mite, body: UIColor(red: 0.55, green: 0.65, blue: 0.85, alpha: 1), accent: UIColor(red: 0.85, green: 0.90, blue: 1.00, alpha: 1))
        case "Shard Sentinel":
            return generateEnemyCreature(size: size, style: .golem, body: UIColor(red: 0.35, green: 0.25, blue: 0.55, alpha: 1), eye: UIColor(red: 0.90, green: 0.40, blue: 0.90, alpha: 1), accent: UIColor(red: 0.90, green: 0.40, blue: 0.90, alpha: 1))
        case "Crystal Wyrm":
            return generateEnemyCreature(size: size, style: .serpent, body: UIColor(red: 0.45, green: 0.30, blue: 0.65, alpha: 1), eye: UIColor(red: 0.60, green: 0.80, blue: 1.00, alpha: 1), accent: UIColor(red: 0.75, green: 0.85, blue: 1.00, alpha: 1))
        case "Geode Roller":
            return generateEnemyCreature(size: size, style: .spikeball, body: UIColor(red: 0.40, green: 0.35, blue: 0.50, alpha: 1), eye: UIColor(red: 0.70, green: 0.50, blue: 0.90, alpha: 1), accent: UIColor(red: 0.75, green: 0.65, blue: 0.90, alpha: 1))
        case "Refractor":
            return generateEnemyCreature(size: size, style: .wisp, body: UIColor(red: 0.75, green: 0.80, blue: 0.95, alpha: 1), eye: UIColor(red: 0.90, green: 0.40, blue: 0.90, alpha: 1), accent: UIColor.white)
        // Space
        case "Cosmic Dust":
            return generateFoodCreature(size: size, style: .mite, body: UIColor(red: 0.62, green: 0.57, blue: 0.82, alpha: 1), accent: UIColor(red: 0.88, green: 0.85, blue: 1.00, alpha: 1))
        case "Star Larva":
            return generateFoodCreature(size: size, style: .grub, body: UIColor(red: 0.95, green: 0.85, blue: 0.35, alpha: 1), accent: UIColor(red: 1.00, green: 0.98, blue: 0.75, alpha: 1))
        case "Nebula Jelly":
            return generateFoodCreature(size: size, style: .jelly, body: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), accent: UIColor(red: 0.85, green: 0.55, blue: 1.00, alpha: 1))
        case "Asteroid Beetle":
            return generateEnemyCreature(size: size, style: .golem, body: UIColor(red: 0.40, green: 0.38, blue: 0.35, alpha: 1), eye: UIColor(red: 0.90, green: 0.45, blue: 0.20, alpha: 1), accent: UIColor(red: 0.90, green: 0.45, blue: 0.20, alpha: 1))
        case "Cosmic Serpent":
            return generateEnemyCreature(size: size, style: .serpent, body: UIColor(red: 0.28, green: 0.23, blue: 0.48, alpha: 1), eye: UIColor(red: 0.50, green: 0.80, blue: 1.00, alpha: 1), accent: UIColor(red: 0.55, green: 0.65, blue: 0.95, alpha: 1))
        default:
            return generateSimpleCreature(size: size, bodyColor: UIColor(white: 0.6, alpha: 1), eyeColor: .white)
        }
    }
}
