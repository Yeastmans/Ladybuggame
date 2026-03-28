import SpriteKit
import UIKit

enum TextureGenerator {

    // MARK: - Ladybug (walking — no mouth, no legs)

    static func generateLadybugTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            let bodyRect = CGRect(x: w * 0.1, y: h * 0.18, width: w * 0.8, height: h * 0.72)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: bodyRect)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.setLineWidth(1.5)
            cg.strokeEllipse(in: bodyRect)

            cg.setStrokeColor(UIColor(red: 0.20, green: 0.02, blue: 0.02, alpha: 1.0).cgColor)
            cg.setLineWidth(2.0)
            cg.move(to: CGPoint(x: w * 0.5, y: h * 0.22))
            cg.addLine(to: CGPoint(x: w * 0.5, y: h * 0.86))
            cg.strokePath()

            let spotColor = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
            cg.setFillColor(spotColor)
            cg.fillEllipse(in: CGRect(x: w * 0.14, y: h * 0.30, width: w * 0.17, height: w * 0.17))
            cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.50, width: w * 0.12, height: w * 0.12))
            cg.fillEllipse(in: CGRect(x: w * 0.13, y: h * 0.65, width: w * 0.14, height: w * 0.14))
            cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.40, width: w * 0.06, height: w * 0.06))
            cg.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.56, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.28, width: w * 0.13, height: w * 0.13))
            cg.fillEllipse(in: CGRect(x: w * 0.70, y: h * 0.44, width: w * 0.18, height: w * 0.18))
            cg.fillEllipse(in: CGRect(x: w * 0.55, y: h * 0.58, width: w * 0.09, height: w * 0.09))
            cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.68, width: w * 0.15, height: w * 0.15))
            cg.fillEllipse(in: CGRect(x: w * 0.60, y: h * 0.38, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.75, y: h * 0.60, width: w * 0.08, height: w * 0.08))

            drawLadybugHead(cg: cg, w: w, h: h, eyesClosed: false)
        }
        return SKTexture(image: image)
    }

    static func generateLadybugBlinkTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            let bodyRect = CGRect(x: w * 0.1, y: h * 0.18, width: w * 0.8, height: h * 0.72)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: bodyRect)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.setLineWidth(1.5)
            cg.strokeEllipse(in: bodyRect)

            cg.setStrokeColor(UIColor(red: 0.20, green: 0.02, blue: 0.02, alpha: 1.0).cgColor)
            cg.setLineWidth(2.0)
            cg.move(to: CGPoint(x: w * 0.5, y: h * 0.22))
            cg.addLine(to: CGPoint(x: w * 0.5, y: h * 0.86))
            cg.strokePath()

            let spotColor = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
            cg.setFillColor(spotColor)
            cg.fillEllipse(in: CGRect(x: w * 0.14, y: h * 0.30, width: w * 0.17, height: w * 0.17))
            cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.50, width: w * 0.12, height: w * 0.12))
            cg.fillEllipse(in: CGRect(x: w * 0.13, y: h * 0.65, width: w * 0.14, height: w * 0.14))
            cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.40, width: w * 0.06, height: w * 0.06))
            cg.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.56, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.28, width: w * 0.13, height: w * 0.13))
            cg.fillEllipse(in: CGRect(x: w * 0.70, y: h * 0.44, width: w * 0.18, height: w * 0.18))
            cg.fillEllipse(in: CGRect(x: w * 0.55, y: h * 0.58, width: w * 0.09, height: w * 0.09))
            cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.68, width: w * 0.15, height: w * 0.15))
            cg.fillEllipse(in: CGRect(x: w * 0.60, y: h * 0.38, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.75, y: h * 0.60, width: w * 0.08, height: w * 0.08))

            drawLadybugHead(cg: cg, w: w, h: h, eyesClosed: true)
        }
        return SKTexture(image: image)
    }

    // MARK: - Ladybug Glide (wings open)

    static func generateLadybugGlideTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Translucent flight wings
            cg.setFillColor(UIColor(red: 0.78, green: 0.85, blue: 0.91, alpha: 0.30).cgColor)
            cg.saveGState()
            cg.translateBy(x: w * 0.30, y: h * 0.52)
            cg.rotate(by: -0.15)
            cg.fillEllipse(in: CGRect(x: -w * 0.18, y: -h * 0.20, width: w * 0.30, height: h * 0.40))
            cg.restoreGState()
            cg.saveGState()
            cg.translateBy(x: w * 0.70, y: h * 0.52)
            cg.rotate(by: 0.15)
            cg.fillEllipse(in: CGRect(x: -w * 0.12, y: -h * 0.20, width: w * 0.30, height: h * 0.40))
            cg.restoreGState()

            // Red elytra spread
            let spotColor = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
            cg.saveGState()
            cg.translateBy(x: w * 0.22, y: h * 0.52)
            cg.rotate(by: -0.25)
            let lw = CGRect(x: -w * 0.22, y: -h * 0.24, width: w * 0.38, height: h * 0.48)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: lw)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.setLineWidth(1.2)
            cg.strokeEllipse(in: lw)
            cg.setFillColor(spotColor)
            cg.fillEllipse(in: CGRect(x: -w * 0.16, y: -h * 0.14, width: w * 0.10, height: w * 0.10))
            cg.fillEllipse(in: CGRect(x: -w * 0.06, y: h * 0.04, width: w * 0.08, height: w * 0.08))
            cg.fillEllipse(in: CGRect(x: -w * 0.18, y: h * 0.08, width: w * 0.12, height: w * 0.12))
            cg.restoreGState()

            cg.saveGState()
            cg.translateBy(x: w * 0.78, y: h * 0.52)
            cg.rotate(by: 0.25)
            let rw = CGRect(x: -w * 0.16, y: -h * 0.24, width: w * 0.38, height: h * 0.48)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: rw)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.strokeEllipse(in: rw)
            cg.setFillColor(spotColor)
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: -h * 0.14, width: w * 0.10, height: w * 0.10))
            cg.fillEllipse(in: CGRect(x: -w * 0.02, y: h * 0.04, width: w * 0.08, height: w * 0.08))
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.08, width: w * 0.12, height: w * 0.12))
            cg.restoreGState()

            // Black abdomen
            cg.setFillColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.38, y: h * 0.28, width: w * 0.24, height: h * 0.52))

            drawLadybugHead(cg: cg, w: w, h: h, eyesClosed: false)
        }
        return SKTexture(image: image)
    }

    private static func drawLadybugHead(cg: CGContext, w: CGFloat, h: CGFloat, eyesClosed: Bool) {
        let cx: CGFloat = 0.5
        let headSize = w * 0.35
        cg.setFillColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
        cg.fillEllipse(in: CGRect(x: w * cx - headSize / 2, y: h * 0.05, width: headSize, height: headSize))

        // Antennae
        let dark = UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor
        cg.setStrokeColor(dark)
        cg.setLineWidth(1.6)
        cg.setLineCap(.round)
        cg.move(to: CGPoint(x: w * 0.40, y: h * 0.10))
        cg.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.0), control: CGPoint(x: w * 0.28, y: h * 0.03))
        cg.strokePath()
        cg.move(to: CGPoint(x: w * 0.60, y: h * 0.10))
        cg.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.0), control: CGPoint(x: w * 0.72, y: h * 0.03))
        cg.strokePath()
        cg.setFillColor(dark)
        cg.fillEllipse(in: CGRect(x: w * 0.20, y: -2.5, width: 5, height: 5))
        cg.fillEllipse(in: CGRect(x: w * 0.76, y: -2.5, width: 5, height: 5))

        if eyesClosed {
            cg.setStrokeColor(UIColor.white.cgColor)
            cg.setLineWidth(1.5)
            cg.move(to: CGPoint(x: w * 0.34, y: h * 0.10))
            cg.addQuadCurve(to: CGPoint(x: w * 0.44, y: h * 0.10), control: CGPoint(x: w * 0.39, y: h * 0.13))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.56, y: h * 0.10))
            cg.addQuadCurve(to: CGPoint(x: w * 0.66, y: h * 0.10), control: CGPoint(x: w * 0.61, y: h * 0.13))
            cg.strokePath()
        } else {
            cg.setFillColor(UIColor.white.cgColor)
            let eyeR = w * 0.10
            cg.fillEllipse(in: CGRect(x: w * 0.33, y: h * 0.07, width: eyeR, height: eyeR))
            cg.fillEllipse(in: CGRect(x: w * 0.57, y: h * 0.07, width: eyeR, height: eyeR))
            cg.setFillColor(UIColor.black.cgColor)
            let pupilR = w * 0.05
            cg.fillEllipse(in: CGRect(x: w * 0.36, y: h * 0.09, width: pupilR, height: pupilR))
            cg.fillEllipse(in: CGRect(x: w * 0.60, y: h * 0.09, width: pupilR, height: pupilR))
            cg.setFillColor(UIColor.white.cgColor)
            let shineR = w * 0.025
            cg.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.075, width: shineR, height: shineR))
            cg.fillEllipse(in: CGRect(x: w * 0.59, y: h * 0.075, width: shineR, height: shineR))
        }

        // Cheek blush
        cg.setFillColor(UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.35).cgColor)
        cg.fillEllipse(in: CGRect(x: w * 0.28, y: h * 0.15, width: w * 0.10, height: w * 0.05))
        cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.15, width: w * 0.10, height: w * 0.05))
    }

    // MARK: - Aphid (colored variants)

    enum AphidColor {
        case green, yellow, red

        var bodyColor: UIColor {
            switch self {
            case .green: return UIColor(red: 0.65, green: 0.86, blue: 0.40, alpha: 1.0)
            case .yellow: return UIColor(red: 0.90, green: 0.82, blue: 0.25, alpha: 1.0)
            case .red: return UIColor(red: 0.88, green: 0.30, blue: 0.35, alpha: 1.0)
            }
        }
        var headColor: UIColor {
            switch self {
            case .green: return UIColor(red: 0.50, green: 0.70, blue: 0.30, alpha: 1.0)
            case .yellow: return UIColor(red: 0.75, green: 0.68, blue: 0.15, alpha: 1.0)
            case .red: return UIColor(red: 0.72, green: 0.20, blue: 0.25, alpha: 1.0)
            }
        }
        var legColor: UIColor {
            switch self {
            case .green: return UIColor(red: 0.30, green: 0.45, blue: 0.15, alpha: 1.0)
            case .yellow: return UIColor(red: 0.55, green: 0.50, blue: 0.10, alpha: 1.0)
            case .red: return UIColor(red: 0.50, green: 0.12, blue: 0.15, alpha: 1.0)
            }
        }
        var points: Int {
            switch self {
            case .green: return 10
            case .yellow: return 25
            case .red: return 50
            }
        }
    }

    static func generateAphidTexture(size: CGSize, color: AphidColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Legs
            cg.setStrokeColor(color.legColor.cgColor)
            cg.setLineWidth(0.7)
            cg.setLineCap(.round)
            let legPairs: [(y: CGFloat, outX: CGFloat, endY: CGFloat)] = [(0.40, 0.08, 0.48), (0.55, 0.03, 0.63), (0.70, 0.10, 0.80)]
            for lp in legPairs {
                cg.move(to: CGPoint(x: w * 0.25, y: h * lp.y))
                cg.addLine(to: CGPoint(x: w * lp.outX, y: h * lp.y))
                cg.addLine(to: CGPoint(x: w * lp.outX, y: h * lp.endY))
                cg.strokePath()
                cg.move(to: CGPoint(x: w * 0.75, y: h * lp.y))
                cg.addLine(to: CGPoint(x: w * (1.0 - lp.outX), y: h * lp.y))
                cg.addLine(to: CGPoint(x: w * (1.0 - lp.outX), y: h * lp.endY))
                cg.strokePath()
            }

            // Body
            cg.setFillColor(color.bodyColor.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.40, width: w * 0.64, height: h * 0.50))

            // Head
            let headSize = w * 0.32
            cg.setFillColor(color.headColor.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.5 - headSize / 2, y: h * 0.10, width: headSize, height: headSize))

            // Antennae
            cg.setStrokeColor(color.legColor.cgColor)
            cg.setLineWidth(0.8)
            cg.move(to: CGPoint(x: w * 0.40, y: h * 0.16))
            cg.addLine(to: CGPoint(x: w * 0.28, y: h * 0.02))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.60, y: h * 0.16))
            cg.addLine(to: CGPoint(x: w * 0.72, y: h * 0.02))
            cg.strokePath()

            // Eyes
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.36, y: h * 0.16, width: w * 0.10, height: w * 0.10))
            cg.fillEllipse(in: CGRect(x: w * 0.54, y: h * 0.16, width: w * 0.10, height: w * 0.10))
            cg.setFillColor(UIColor.black.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.39, y: h * 0.18, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.57, y: h * 0.18, width: w * 0.05, height: w * 0.05))
        }
        return SKTexture(image: image)
    }

    // MARK: - Bird (two flap frames)

    static func generateBirdTextures(size: CGSize) -> [SKTexture] {
        return [generateBirdFrame(size: size, wingsUp: true),
                generateBirdFrame(size: size, wingsUp: false)]
    }

    private static func generateBirdFrame(size: CGSize, wingsUp: Bool) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            cg.setFillColor(UIColor(red: 0.29, green: 0.29, blue: 0.33, alpha: 1.0).cgColor)
            if wingsUp {
                cg.move(to: CGPoint(x: w * 0.30, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 0.04, y: h * -0.05), control: CGPoint(x: w * 0.05, y: h * 0.15))
                cg.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.40), control: CGPoint(x: w * 0.20, y: h * 0.10))
                cg.fillPath()
                cg.move(to: CGPoint(x: w * 0.70, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 0.96, y: h * -0.05), control: CGPoint(x: w * 0.95, y: h * 0.15))
                cg.addQuadCurve(to: CGPoint(x: w * 0.66, y: h * 0.40), control: CGPoint(x: w * 0.80, y: h * 0.10))
                cg.fillPath()
            } else {
                cg.move(to: CGPoint(x: w * 0.30, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * -0.04, y: h * 0.85), control: CGPoint(x: w * 0.02, y: h * 0.65))
                cg.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.50), control: CGPoint(x: w * 0.15, y: h * 0.60))
                cg.fillPath()
                cg.move(to: CGPoint(x: w * 0.70, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 1.04, y: h * 0.85), control: CGPoint(x: w * 0.98, y: h * 0.65))
                cg.addQuadCurve(to: CGPoint(x: w * 0.66, y: h * 0.50), control: CGPoint(x: w * 0.85, y: h * 0.60))
                cg.fillPath()
            }

            // Tail
            cg.setFillColor(UIColor(red: 0.40, green: 0.30, blue: 0.22, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.40, y: h * 0.78))
            cg.addLine(to: CGPoint(x: w * 0.32, y: h * 1.0))
            cg.addLine(to: CGPoint(x: w * 0.50, y: h * 0.90))
            cg.addLine(to: CGPoint(x: w * 0.68, y: h * 1.0))
            cg.addLine(to: CGPoint(x: w * 0.60, y: h * 0.78))
            cg.closePath()
            cg.fillPath()

            // Body
            cg.setFillColor(UIColor(red: 0.50, green: 0.38, blue: 0.28, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.28, y: h * 0.25, width: w * 0.44, height: h * 0.55))
            cg.setFillColor(UIColor(red: 0.60, green: 0.47, blue: 0.34, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.37, y: h * 0.45, width: w * 0.26, height: h * 0.28))

            // Head
            cg.setFillColor(UIColor(red: 0.55, green: 0.42, blue: 0.32, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.08, width: w * 0.30, height: w * 0.30))

            // Beak
            cg.setFillColor(UIColor(red: 0.95, green: 0.65, blue: 0.10, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.50, y: h * 0.0))
            cg.addLine(to: CGPoint(x: w * 0.43, y: h * 0.14))
            cg.addLine(to: CGPoint(x: w * 0.57, y: h * 0.14))
            cg.closePath()
            cg.fillPath()

            // Eyes
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.38, y: h * 0.13, width: w * 0.09, height: w * 0.09))
            cg.fillEllipse(in: CGRect(x: w * 0.53, y: h * 0.13, width: w * 0.09, height: w * 0.09))
            cg.setFillColor(UIColor(red: 0.80, green: 0.20, blue: 0.0, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.40, y: h * 0.15, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.15, width: w * 0.05, height: w * 0.05))

            // Eyebrows
            cg.setStrokeColor(UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1.0).cgColor)
            cg.setLineWidth(2.5)
            cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.34, y: h * 0.09))
            cg.addLine(to: CGPoint(x: w * 0.46, y: h * 0.13))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.66, y: h * 0.09))
            cg.addLine(to: CGPoint(x: w * 0.54, y: h * 0.13))
            cg.strokePath()
        }
        return SKTexture(image: image)
    }

    // MARK: - Log (horizontal obstacle with moss)

    static func generateLogTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            cg.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.05, y: h * 0.82, width: w * 0.9, height: h * 0.18))

            let logRect = CGRect(x: w * 0.06, y: h * 0.15, width: w * 0.88, height: h * 0.65)
            cg.setFillColor(UIColor(red: 0.545, green: 0.41, blue: 0.08, alpha: 1.0).cgColor)
            let logPath = UIBezierPath(roundedRect: logRect, cornerRadius: h * 0.2)
            cg.addPath(logPath.cgPath)
            cg.fillPath()
            cg.setStrokeColor(UIColor(red: 0.42, green: 0.31, blue: 0.06, alpha: 1.0).cgColor)
            cg.setLineWidth(0.8)
            cg.addPath(logPath.cgPath)
            cg.strokePath()

            // Bark lines
            cg.setStrokeColor(UIColor(red: 0.42, green: 0.31, blue: 0.06, alpha: 0.4).cgColor)
            cg.setLineWidth(0.5)
            for lx in [0.20, 0.40, 0.60, 0.80] as [CGFloat] {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.18))
                cg.addLine(to: CGPoint(x: w * lx, y: h * 0.78))
                cg.strokePath()
            }

            // Log ends
            let endRx = w * 0.07
            let endRy = h * 0.32
            cg.setFillColor(UIColor(red: 0.63, green: 0.47, blue: 0.16, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.02, y: h * 0.48 - endRy, width: endRx * 2, height: endRy * 2))
            cg.fillEllipse(in: CGRect(x: w * 0.88, y: h * 0.48 - endRy, width: endRx * 2, height: endRy * 2))

            // Moss
            cg.setFillColor(UIColor(red: 0.29, green: 0.55, blue: 0.16, alpha: 0.7).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.15, y: h * 0.08, width: w * 0.14, height: h * 0.12))
            cg.fillEllipse(in: CGRect(x: w * 0.45, y: h * 0.06, width: w * 0.18, height: h * 0.14))
            cg.setFillColor(UIColor(red: 0.35, green: 0.64, blue: 0.21, alpha: 0.5).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.50, y: h * 0.09, width: w * 0.10, height: h * 0.08))
            cg.fillEllipse(in: CGRect(x: w * 0.70, y: h * 0.10, width: w * 0.10, height: h * 0.10))
        }
        return SKTexture(image: image)
    }
}
