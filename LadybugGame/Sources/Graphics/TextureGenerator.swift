import SpriteKit
import UIKit

/// Generates all game textures programmatically using Core Graphics.
enum TextureGenerator {

    // MARK: - Ladybug (walking — no mouth, no legs)

    static func generateLadybugTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // === Body (red oval) ===
            let bodyRect = CGRect(x: w * 0.1, y: h * 0.18, width: w * 0.8, height: h * 0.72)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: bodyRect)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.setLineWidth(1.5)
            cg.strokeEllipse(in: bodyRect)

            // === Wing line (closed) ===
            cg.setStrokeColor(UIColor(red: 0.20, green: 0.02, blue: 0.02, alpha: 1.0).cgColor)
            cg.setLineWidth(2.0)
            cg.move(to: CGPoint(x: w * 0.5, y: h * 0.22))
            cg.addLine(to: CGPoint(x: w * 0.5, y: h * 0.86))
            cg.strokePath()

            // === CHAOTIC SPOTS ===
            let spotColor = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
            cg.setFillColor(spotColor)

            // Left wing
            cg.fillEllipse(in: CGRect(x: w * 0.14, y: h * 0.30, width: w * 0.17, height: w * 0.17))
            cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.50, width: w * 0.12, height: w * 0.12))
            cg.fillEllipse(in: CGRect(x: w * 0.13, y: h * 0.65, width: w * 0.14, height: w * 0.14))
            cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.40, width: w * 0.06, height: w * 0.06))
            cg.fillEllipse(in: CGRect(x: w * 0.22, y: h * 0.78, width: w * 0.08, height: w * 0.08))
            cg.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.56, width: w * 0.05, height: w * 0.05))

            // Right wing
            cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.28, width: w * 0.13, height: w * 0.13))
            cg.fillEllipse(in: CGRect(x: w * 0.70, y: h * 0.44, width: w * 0.18, height: w * 0.18))
            cg.fillEllipse(in: CGRect(x: w * 0.55, y: h * 0.58, width: w * 0.09, height: w * 0.09))
            cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.68, width: w * 0.15, height: w * 0.15))
            cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.75, width: w * 0.07, height: w * 0.07))
            cg.fillEllipse(in: CGRect(x: w * 0.60, y: h * 0.38, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.75, y: h * 0.60, width: w * 0.08, height: w * 0.08))

            // === Head ===
            drawLadybugHead(cg: cg, w: w, h: h, headCenterX: 0.5)
        }
        return SKTexture(image: image)
    }

    // MARK: - Ladybug (gliding — wings unfurled, wider)

    static func generateLadybugGlideTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // === Left elytra (unfurled, rotated out) ===
            cg.saveGState()
            cg.translateBy(x: w * 0.22, y: h * 0.52)
            cg.rotate(by: -0.25)
            let leftWing = CGRect(x: -w * 0.22, y: -h * 0.24, width: w * 0.38, height: h * 0.48)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: leftWing)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.setLineWidth(1.2)
            cg.strokeEllipse(in: leftWing)
            // Left wing spots
            let lSpot = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
            cg.setFillColor(lSpot)
            cg.fillEllipse(in: CGRect(x: -w * 0.16, y: -h * 0.14, width: w * 0.10, height: w * 0.10))
            cg.fillEllipse(in: CGRect(x: -w * 0.06, y: h * 0.04, width: w * 0.08, height: w * 0.08))
            cg.fillEllipse(in: CGRect(x: -w * 0.18, y: h * 0.08, width: w * 0.12, height: w * 0.12))
            cg.fillEllipse(in: CGRect(x: -w * 0.08, y: -h * 0.06, width: w * 0.06, height: w * 0.06))
            cg.fillEllipse(in: CGRect(x: -w * 0.14, y: h * 0.16, width: w * 0.07, height: w * 0.07))
            cg.restoreGState()

            // === Right elytra (unfurled, rotated out) ===
            cg.saveGState()
            cg.translateBy(x: w * 0.78, y: h * 0.52)
            cg.rotate(by: 0.25)
            let rightWing = CGRect(x: -w * 0.16, y: -h * 0.24, width: w * 0.38, height: h * 0.48)
            cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
            cg.fillEllipse(in: rightWing)
            cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
            cg.setLineWidth(1.2)
            cg.strokeEllipse(in: rightWing)
            cg.setFillColor(lSpot)
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: -h * 0.14, width: w * 0.10, height: w * 0.10))
            cg.fillEllipse(in: CGRect(x: -w * 0.02, y: h * 0.04, width: w * 0.08, height: w * 0.08))
            cg.fillEllipse(in: CGRect(x: w * 0.06, y: h * 0.08, width: w * 0.12, height: w * 0.12))
            cg.fillEllipse(in: CGRect(x: w * 0.02, y: -h * 0.06, width: w * 0.06, height: w * 0.06))
            cg.fillEllipse(in: CGRect(x: w * 0.07, y: h * 0.16, width: w * 0.07, height: w * 0.07))
            cg.restoreGState()

            // === Translucent flight wings ===
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

            // Wing veins
            cg.setStrokeColor(UIColor(red: 0.63, green: 0.69, blue: 0.75, alpha: 0.4).cgColor)
            cg.setLineWidth(0.4)
            cg.move(to: CGPoint(x: w * 0.38, y: h * 0.38))
            cg.addLine(to: CGPoint(x: w * 0.20, y: h * 0.68))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.62, y: h * 0.38))
            cg.addLine(to: CGPoint(x: w * 0.80, y: h * 0.68))
            cg.strokePath()

            // === Black body/abdomen (exposed between wings) ===
            cg.setFillColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.38, y: h * 0.28, width: w * 0.24, height: h * 0.52))

            // Abdomen segments
            cg.setStrokeColor(UIColor(red: 0.16, green: 0.12, blue: 0.12, alpha: 0.5).cgColor)
            cg.setLineWidth(0.6)
            for segY in stride(from: 0.38, through: 0.68, by: 0.10) {
                cg.move(to: CGPoint(x: w * 0.40, y: h * segY))
                cg.addLine(to: CGPoint(x: w * 0.60, y: h * segY))
                cg.strokePath()
            }

            // === Head ===
            drawLadybugHead(cg: cg, w: w, h: h, headCenterX: 0.5)
        }
        return SKTexture(image: image)
    }

    // MARK: - Ladybug (blink — same as walking but eyes closed)

    static func generateLadybugBlinkTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Same body as walking texture
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
            cg.fillEllipse(in: CGRect(x: w * 0.22, y: h * 0.78, width: w * 0.08, height: w * 0.08))
            cg.fillEllipse(in: CGRect(x: w * 0.35, y: h * 0.56, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.28, width: w * 0.13, height: w * 0.13))
            cg.fillEllipse(in: CGRect(x: w * 0.70, y: h * 0.44, width: w * 0.18, height: w * 0.18))
            cg.fillEllipse(in: CGRect(x: w * 0.55, y: h * 0.58, width: w * 0.09, height: w * 0.09))
            cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.68, width: w * 0.15, height: w * 0.15))
            cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.75, width: w * 0.07, height: w * 0.07))
            cg.fillEllipse(in: CGRect(x: w * 0.60, y: h * 0.38, width: w * 0.05, height: w * 0.05))
            cg.fillEllipse(in: CGRect(x: w * 0.75, y: h * 0.60, width: w * 0.08, height: w * 0.08))

            drawLadybugHead(cg: cg, w: w, h: h, headCenterX: 0.5, eyesClosed: true)
        }
        return SKTexture(image: image)
    }

    /// Shared head drawing for all ladybug states.
    private static func drawLadybugHead(cg: CGContext, w: CGFloat, h: CGFloat, headCenterX: CGFloat, eyesClosed: Bool = false) {
        let headSize = w * 0.35
        let headRect = CGRect(x: w * headCenterX - headSize / 2, y: h * 0.05, width: headSize, height: headSize)
        cg.setFillColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
        cg.fillEllipse(in: headRect)

        // Antennae
        let darkLeg = UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor
        cg.setStrokeColor(darkLeg)
        cg.setLineWidth(1.6)
        cg.setLineCap(.round)
        cg.move(to: CGPoint(x: w * (headCenterX - 0.10), y: h * 0.10))
        cg.addQuadCurve(to: CGPoint(x: w * (headCenterX - 0.28), y: h * 0.0),
                        control: CGPoint(x: w * (headCenterX - 0.22), y: h * 0.03))
        cg.strokePath()
        cg.move(to: CGPoint(x: w * (headCenterX + 0.10), y: h * 0.10))
        cg.addQuadCurve(to: CGPoint(x: w * (headCenterX + 0.28), y: h * 0.0),
                        control: CGPoint(x: w * (headCenterX + 0.22), y: h * 0.03))
        cg.strokePath()

        // Antenna tips
        cg.setFillColor(darkLeg)
        cg.fillEllipse(in: CGRect(x: w * (headCenterX - 0.30), y: -2.5, width: 5, height: 5))
        cg.fillEllipse(in: CGRect(x: w * (headCenterX + 0.26), y: -2.5, width: 5, height: 5))

        if eyesClosed {
            // Closed eyes — curved lines (happy squint)
            cg.setStrokeColor(UIColor.white.cgColor)
            cg.setLineWidth(1.5)
            // Left eye — curved line
            cg.move(to: CGPoint(x: w * (headCenterX - 0.16), y: h * 0.10))
            cg.addQuadCurve(to: CGPoint(x: w * (headCenterX - 0.06), y: h * 0.10),
                            control: CGPoint(x: w * (headCenterX - 0.11), y: h * 0.13))
            cg.strokePath()
            // Right eye — curved line
            cg.move(to: CGPoint(x: w * (headCenterX + 0.06), y: h * 0.10))
            cg.addQuadCurve(to: CGPoint(x: w * (headCenterX + 0.16), y: h * 0.10),
                            control: CGPoint(x: w * (headCenterX + 0.11), y: h * 0.13))
            cg.strokePath()
        } else {
            // Open eyes
            cg.setFillColor(UIColor.white.cgColor)
            let eyeR = w * 0.10
            cg.fillEllipse(in: CGRect(x: w * (headCenterX - 0.17), y: h * 0.07, width: eyeR, height: eyeR))
            cg.fillEllipse(in: CGRect(x: w * (headCenterX + 0.07), y: h * 0.07, width: eyeR, height: eyeR))

            cg.setFillColor(UIColor.black.cgColor)
            let pupilR = w * 0.05
            cg.fillEllipse(in: CGRect(x: w * (headCenterX - 0.14), y: h * 0.09, width: pupilR, height: pupilR))
            cg.fillEllipse(in: CGRect(x: w * (headCenterX + 0.10), y: h * 0.09, width: pupilR, height: pupilR))

            // Eye shine
            cg.setFillColor(UIColor.white.cgColor)
            let shineR = w * 0.025
            cg.fillEllipse(in: CGRect(x: w * (headCenterX - 0.15), y: h * 0.075, width: shineR, height: shineR))
            cg.fillEllipse(in: CGRect(x: w * (headCenterX + 0.09), y: h * 0.075, width: shineR, height: shineR))
        }

        // Cheek blush
        cg.setFillColor(UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.35).cgColor)
        cg.fillEllipse(in: CGRect(x: w * (headCenterX - 0.22), y: h * 0.15, width: w * 0.10, height: w * 0.05))
        cg.fillEllipse(in: CGRect(x: w * (headCenterX + 0.12), y: h * 0.15, width: w * 0.10, height: w * 0.05))
    }

    // MARK: - Aphid (two frames for skittering)

    static func generateAphidTextures(size: CGSize) -> [SKTexture] {
        return [
            generateAphidFrame(size: size, strideOffset: false),
            generateAphidFrame(size: size, strideOffset: true)
        ]
    }

    private static func generateAphidFrame(size: CGSize, strideOffset: Bool) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            let legColor = UIColor(red: 0.30, green: 0.45, blue: 0.15, alpha: 1.0).cgColor
            cg.setStrokeColor(legColor)
            cg.setLineCap(.round)

            // Stride alternation: swap which legs go forward vs back
            let fwd: CGFloat = strideOffset ? 0.06 : -0.06
            let bck: CGFloat = strideOffset ? -0.06 : 0.06

            // Antennae (bounce with stride)
            let antBounce: CGFloat = strideOffset ? -0.02 : 0.02
            cg.setLineWidth(0.8)
            cg.move(to: CGPoint(x: w * 0.40, y: h * 0.18))
            cg.addQuadCurve(to: CGPoint(x: w * 0.25, y: h * (0.02 + antBounce)),
                            control: CGPoint(x: w * 0.32, y: h * 0.08))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.60, y: h * 0.18))
            cg.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * (0.02 - antBounce)),
                            control: CGPoint(x: w * 0.68, y: h * 0.08))
            cg.strokePath()
            cg.setFillColor(legColor)
            cg.fillEllipse(in: CGRect(x: w * 0.23, y: h * (0.0 + antBounce), width: w * 0.06, height: w * 0.06))
            cg.fillEllipse(in: CGRect(x: w * 0.73, y: h * (0.0 - antBounce), width: w * 0.06, height: w * 0.06))

            // === 3 pairs of legs with stride ===
            cg.setLineWidth(0.7)

            // Front legs
            cg.move(to: CGPoint(x: w * 0.25, y: h * 0.42))
            cg.addLine(to: CGPoint(x: w * (0.08 + fwd), y: h * 0.34))
            cg.addLine(to: CGPoint(x: w * (0.05 + fwd), y: h * 0.40))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.75, y: h * 0.42))
            cg.addLine(to: CGPoint(x: w * (0.92 + bck), y: h * 0.34))
            cg.addLine(to: CGPoint(x: w * (0.95 + bck), y: h * 0.40))
            cg.strokePath()

            // Middle legs
            cg.move(to: CGPoint(x: w * 0.20, y: h * 0.56))
            cg.addLine(to: CGPoint(x: w * (0.03 + bck), y: h * 0.56))
            cg.addLine(to: CGPoint(x: w * (0.02 + bck), y: h * 0.63))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.80, y: h * 0.56))
            cg.addLine(to: CGPoint(x: w * (0.97 + fwd), y: h * 0.56))
            cg.addLine(to: CGPoint(x: w * (0.98 + fwd), y: h * 0.63))
            cg.strokePath()

            // Back legs
            cg.move(to: CGPoint(x: w * 0.25, y: h * 0.72))
            cg.addLine(to: CGPoint(x: w * (0.10 + fwd), y: h * 0.80))
            cg.addLine(to: CGPoint(x: w * (0.08 + fwd), y: h * 0.88))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.75, y: h * 0.72))
            cg.addLine(to: CGPoint(x: w * (0.90 + bck), y: h * 0.80))
            cg.addLine(to: CGPoint(x: w * (0.92 + bck), y: h * 0.88))
            cg.strokePath()

            // === Body ===
            cg.setFillColor(UIColor(red: 0.65, green: 0.86, blue: 0.40, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.18, y: h * 0.48, width: w * 0.64, height: h * 0.42))
            cg.setFillColor(UIColor(red: 0.70, green: 0.86, blue: 0.47, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.22, y: h * 0.32, width: w * 0.56, height: h * 0.32))
            cg.setStrokeColor(UIColor(red: 0.40, green: 0.55, blue: 0.25, alpha: 1.0).cgColor)
            cg.setLineWidth(0.8)
            cg.strokeEllipse(in: CGRect(x: w * 0.18, y: h * 0.48, width: w * 0.64, height: h * 0.42))

            // === Head ===
            let headSize = w * 0.32
            cg.setFillColor(UIColor(red: 0.50, green: 0.70, blue: 0.30, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.5 - headSize / 2, y: h * 0.12, width: headSize, height: headSize))
            cg.setStrokeColor(UIColor(red: 0.35, green: 0.50, blue: 0.20, alpha: 1.0).cgColor)
            cg.setLineWidth(0.6)
            cg.strokeEllipse(in: CGRect(x: w * 0.5 - headSize / 2, y: h * 0.12, width: headSize, height: headSize))

            // Eyes
            cg.setFillColor(UIColor.white.cgColor)
            let eyeR = w * 0.10
            cg.fillEllipse(in: CGRect(x: w * 0.34, y: h * 0.16, width: eyeR, height: eyeR))
            cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.16, width: eyeR, height: eyeR))
            cg.setFillColor(UIColor.black.cgColor)
            let pupilR = w * 0.055
            cg.fillEllipse(in: CGRect(x: w * 0.37, y: h * 0.18, width: pupilR, height: pupilR))
            cg.fillEllipse(in: CGRect(x: w * 0.59, y: h * 0.18, width: pupilR, height: pupilR))

            // Worried mouth
            cg.setFillColor(UIColor(red: 0.35, green: 0.50, blue: 0.20, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.44, y: h * 0.28, width: w * 0.12, height: h * 0.06))
        }
        return SKTexture(image: image)
    }

    // MARK: - Bird (two flap frames)

    static func generateBirdTextures(size: CGSize) -> [SKTexture] {
        return [
            generateBirdFrame(size: size, wingsUp: true),
            generateBirdFrame(size: size, wingsUp: false)
        ]
    }

    private static func generateBirdFrame(size: CGSize, wingsUp: Bool) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // === Wings ===
            cg.setFillColor(UIColor(red: 0.29, green: 0.29, blue: 0.33, alpha: 1.0).cgColor)

            if wingsUp {
                // Wings angled upward
                cg.move(to: CGPoint(x: w * 0.30, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 0.04, y: h * -0.05),
                                control: CGPoint(x: w * 0.05, y: h * 0.15))
                cg.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.40),
                                control: CGPoint(x: w * 0.20, y: h * 0.10))
                cg.fillPath()

                cg.move(to: CGPoint(x: w * 0.70, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 0.96, y: h * -0.05),
                                control: CGPoint(x: w * 0.95, y: h * 0.15))
                cg.addQuadCurve(to: CGPoint(x: w * 0.66, y: h * 0.40),
                                control: CGPoint(x: w * 0.80, y: h * 0.10))
                cg.fillPath()
            } else {
                // Wings angled downward
                cg.move(to: CGPoint(x: w * 0.30, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * -0.04, y: h * 0.85),
                                control: CGPoint(x: w * 0.02, y: h * 0.65))
                cg.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.50),
                                control: CGPoint(x: w * 0.15, y: h * 0.60))
                cg.fillPath()

                cg.move(to: CGPoint(x: w * 0.70, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 1.04, y: h * 0.85),
                                control: CGPoint(x: w * 0.98, y: h * 0.65))
                cg.addQuadCurve(to: CGPoint(x: w * 0.66, y: h * 0.50),
                                control: CGPoint(x: w * 0.85, y: h * 0.60))
                cg.fillPath()
            }

            // Feather detail on wings
            cg.setFillColor(UIColor(red: 0.35, green: 0.35, blue: 0.40, alpha: 1.0).cgColor)
            if wingsUp {
                cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.08, width: w * 0.12, height: h * 0.15))
                cg.fillEllipse(in: CGRect(x: w * 0.78, y: h * 0.08, width: w * 0.12, height: h * 0.15))
            } else {
                cg.fillEllipse(in: CGRect(x: w * 0.04, y: h * 0.65, width: w * 0.12, height: h * 0.12))
                cg.fillEllipse(in: CGRect(x: w * 0.84, y: h * 0.65, width: w * 0.12, height: h * 0.12))
            }

            // === Tail ===
            cg.setFillColor(UIColor(red: 0.40, green: 0.30, blue: 0.22, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.40, y: h * 0.78))
            cg.addLine(to: CGPoint(x: w * 0.32, y: h * 1.0))
            cg.addLine(to: CGPoint(x: w * 0.41, y: h * 0.88))
            cg.addLine(to: CGPoint(x: w * 0.50, y: h * 1.0))
            cg.addLine(to: CGPoint(x: w * 0.59, y: h * 0.88))
            cg.addLine(to: CGPoint(x: w * 0.68, y: h * 1.0))
            cg.addLine(to: CGPoint(x: w * 0.60, y: h * 0.78))
            cg.closePath()
            cg.fillPath()

            // === Body ===
            cg.setFillColor(UIColor(red: 0.50, green: 0.38, blue: 0.28, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.28, y: h * 0.25, width: w * 0.44, height: h * 0.55))
            cg.setFillColor(UIColor(red: 0.60, green: 0.47, blue: 0.34, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.37, y: h * 0.45, width: w * 0.26, height: h * 0.28))

            // === Head ===
            cg.setFillColor(UIColor(red: 0.55, green: 0.42, blue: 0.32, alpha: 1.0).cgColor)
            let headSize = w * 0.30
            cg.fillEllipse(in: CGRect(x: w * 0.5 - headSize / 2, y: h * 0.08, width: headSize, height: headSize))

            // Beak
            cg.setFillColor(UIColor(red: 0.95, green: 0.65, blue: 0.10, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.50, y: h * 0.0))
            cg.addLine(to: CGPoint(x: w * 0.43, y: h * 0.14))
            cg.addLine(to: CGPoint(x: w * 0.47, y: h * 0.15))
            cg.addLine(to: CGPoint(x: w * 0.50, y: h * 0.12))
            cg.addLine(to: CGPoint(x: w * 0.53, y: h * 0.15))
            cg.addLine(to: CGPoint(x: w * 0.57, y: h * 0.14))
            cg.closePath()
            cg.fillPath()

            // Eyes (red iris)
            cg.setFillColor(UIColor.white.cgColor)
            let eyeW = w * 0.10
            let eyeH = w * 0.09
            cg.fillEllipse(in: CGRect(x: w * 0.37, y: h * 0.13, width: eyeW, height: eyeH))
            cg.fillEllipse(in: CGRect(x: w * 0.53, y: h * 0.13, width: eyeW, height: eyeH))
            cg.setFillColor(UIColor(red: 0.80, green: 0.20, blue: 0.0, alpha: 1.0).cgColor)
            let irisR = w * 0.05
            cg.fillEllipse(in: CGRect(x: w * 0.40, y: h * 0.15, width: irisR, height: irisR))
            cg.fillEllipse(in: CGRect(x: w * 0.56, y: h * 0.15, width: irisR, height: irisR))
            cg.setFillColor(UIColor.black.cgColor)
            let pupilR = w * 0.03
            cg.fillEllipse(in: CGRect(x: w * 0.41, y: h * 0.155, width: pupilR, height: pupilR))
            cg.fillEllipse(in: CGRect(x: w * 0.57, y: h * 0.155, width: pupilR, height: pupilR))

            // Angry eyebrows
            cg.setStrokeColor(UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1.0).cgColor)
            cg.setLineWidth(2.5)
            cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.32, y: h * 0.09))
            cg.addLine(to: CGPoint(x: w * 0.46, y: h * 0.13))
            cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.68, y: h * 0.09))
            cg.addLine(to: CGPoint(x: w * 0.54, y: h * 0.13))
            cg.strokePath()

            // Talons
            cg.setStrokeColor(UIColor(red: 0.40, green: 0.30, blue: 0.22, alpha: 1.0).cgColor)
            cg.setFillColor(UIColor(red: 0.50, green: 0.38, blue: 0.28, alpha: 1.0).cgColor)
            cg.setLineWidth(0.8)
            cg.move(to: CGPoint(x: w * 0.38, y: h * 0.78))
            cg.addLine(to: CGPoint(x: w * 0.35, y: h * 0.88))
            cg.addLine(to: CGPoint(x: w * 0.38, y: h * 0.85))
            cg.addLine(to: CGPoint(x: w * 0.40, y: h * 0.90))
            cg.addLine(to: CGPoint(x: w * 0.42, y: h * 0.85))
            cg.addLine(to: CGPoint(x: w * 0.44, y: h * 0.88))
            cg.addLine(to: CGPoint(x: w * 0.44, y: h * 0.78))
            cg.fillPath()
            cg.move(to: CGPoint(x: w * 0.56, y: h * 0.78))
            cg.addLine(to: CGPoint(x: w * 0.53, y: h * 0.88))
            cg.addLine(to: CGPoint(x: w * 0.56, y: h * 0.85))
            cg.addLine(to: CGPoint(x: w * 0.58, y: h * 0.90))
            cg.addLine(to: CGPoint(x: w * 0.60, y: h * 0.85))
            cg.addLine(to: CGPoint(x: w * 0.62, y: h * 0.88))
            cg.addLine(to: CGPoint(x: w * 0.62, y: h * 0.78))
            cg.fillPath()
        }
        return SKTexture(image: image)
    }

    // MARK: - Log Horizontal (with moss)

    static func generateLogTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Shadow
            cg.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.05, y: h * 0.82, width: w * 0.9, height: h * 0.18))

            // Log body
            let logRect = CGRect(x: w * 0.06, y: h * 0.20, width: w * 0.88, height: h * 0.55)
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
            for lx in [0.20, 0.35, 0.50, 0.65, 0.80] as [CGFloat] {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.22))
                cg.addLine(to: CGPoint(x: w * lx, y: h * 0.73))
                cg.strokePath()
            }

            // Wood grain
            cg.setStrokeColor(UIColor(red: 0.63, green: 0.50, blue: 0.19, alpha: 0.5).cgColor)
            cg.setLineWidth(0.6)
            cg.move(to: CGPoint(x: w * 0.12, y: h * 0.35)); cg.addLine(to: CGPoint(x: w * 0.30, y: h * 0.35)); cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.42, y: h * 0.55)); cg.addLine(to: CGPoint(x: w * 0.68, y: h * 0.55)); cg.strokePath()
            cg.move(to: CGPoint(x: w * 0.72, y: h * 0.38)); cg.addLine(to: CGPoint(x: w * 0.88, y: h * 0.38)); cg.strokePath()

            // Left end
            let endRx = w * 0.07
            let endRy = h * 0.27
            cg.setFillColor(UIColor(red: 0.63, green: 0.47, blue: 0.16, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.02, y: h * 0.475 - endRy, width: endRx * 2, height: endRy * 2))
            cg.setStrokeColor(UIColor(red: 0.42, green: 0.31, blue: 0.06, alpha: 1.0).cgColor)
            cg.strokeEllipse(in: CGRect(x: w * 0.02, y: h * 0.475 - endRy, width: endRx * 2, height: endRy * 2))
            cg.setStrokeColor(UIColor(red: 0.78, green: 0.63, blue: 0.31, alpha: 0.5).cgColor)
            cg.setLineWidth(0.4)
            cg.strokeEllipse(in: CGRect(x: w * 0.04, y: h * 0.33, width: endRx * 1.4, height: endRy * 1.3))
            cg.strokeEllipse(in: CGRect(x: w * 0.06, y: h * 0.40, width: endRx * 0.8, height: endRy * 0.6))

            // === MOSS patches ===
            let mossColors: [(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)] = [
                (0.29, 0.55, 0.16, 0.70),
                (0.35, 0.64, 0.21, 0.60),
                (0.42, 0.75, 0.25, 0.45)
            ]
            let mossPatches: [(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat, ci: Int)] = [
                (0.20, 0.18, 0.07, 0.08, 0), (0.18, 0.20, 0.05, 0.06, 1), (0.22, 0.17, 0.03, 0.05, 2),
                (0.52, 0.16, 0.09, 0.09, 0), (0.50, 0.19, 0.06, 0.07, 1), (0.55, 0.17, 0.04, 0.06, 2), (0.48, 0.20, 0.03, 0.04, 2),
                (0.78, 0.19, 0.05, 0.07, 0), (0.79, 0.18, 0.03, 0.05, 1)
            ]
            for m in mossPatches {
                let c = mossColors[m.ci]
                cg.setFillColor(UIColor(red: c.r, green: c.g, blue: c.b, alpha: c.a).cgColor)
                cg.fillEllipse(in: CGRect(x: w * (m.cx - m.rx), y: h * (m.cy - m.ry), width: w * m.rx * 2, height: h * m.ry * 2))
            }

            // Leaf
            cg.setFillColor(UIColor(red: 0.35, green: 0.60, blue: 0.20, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.68, y: h * 0.20))
            cg.addQuadCurve(to: CGPoint(x: w * 0.74, y: h * 0.08),
                            control: CGPoint(x: w * 0.74, y: h * 0.16))
            cg.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.20),
                            control: CGPoint(x: w * 0.70, y: h * 0.10))
            cg.fillPath()
        }
        return SKTexture(image: image)
    }

    // MARK: - Log Vertical (branch/stick style with moss)

    static func generateVerticalLogTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Shadow
            cg.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.15, y: h * 0.92, width: w * 0.7, height: h * 0.08))

            // Main branch body (tapered)
            cg.setFillColor(UIColor(red: 0.48, green: 0.36, blue: 0.12, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.30, y: h * 0.08))
            cg.addQuadCurve(to: CGPoint(x: w * 0.32, y: h * 0.92),
                            control: CGPoint(x: w * 0.27, y: h * 0.50))
            cg.addLine(to: CGPoint(x: w * 0.68, y: h * 0.92))
            cg.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.08),
                            control: CGPoint(x: w * 0.73, y: h * 0.50))
            cg.closePath()
            cg.fillPath()

            // Outline
            cg.setStrokeColor(UIColor(red: 0.35, green: 0.26, blue: 0.06, alpha: 1.0).cgColor)
            cg.setLineWidth(0.8)
            cg.move(to: CGPoint(x: w * 0.30, y: h * 0.08))
            cg.addQuadCurve(to: CGPoint(x: w * 0.32, y: h * 0.92),
                            control: CGPoint(x: w * 0.27, y: h * 0.50))
            cg.addLine(to: CGPoint(x: w * 0.68, y: h * 0.92))
            cg.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.08),
                            control: CGPoint(x: w * 0.73, y: h * 0.50))
            cg.closePath()
            cg.strokePath()

            // Bark cracks (horizontal)
            cg.setStrokeColor(UIColor(red: 0.35, green: 0.26, blue: 0.06, alpha: 0.35).cgColor)
            cg.setLineWidth(0.5)
            for ly in [0.18, 0.33, 0.48, 0.63, 0.78] as [CGFloat] {
                cg.move(to: CGPoint(x: w * 0.30, y: h * ly))
                cg.addLine(to: CGPoint(x: w * 0.70, y: h * ly))
                cg.strokePath()
            }

            // Knot hole
            cg.setFillColor(UIColor(red: 0.35, green: 0.26, blue: 0.06, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.52, width: w * 0.16, height: h * 0.08))
            cg.setFillColor(UIColor(red: 0.29, green: 0.22, blue: 0.04, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.45, y: h * 0.54, width: w * 0.10, height: h * 0.05))

            // Top (snapped/jagged)
            cg.setFillColor(UIColor(red: 0.48, green: 0.36, blue: 0.12, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.30, y: h * 0.08))
            cg.addLine(to: CGPoint(x: w * 0.35, y: h * 0.04))
            cg.addLine(to: CGPoint(x: w * 0.42, y: h * 0.07))
            cg.addLine(to: CGPoint(x: w * 0.50, y: h * 0.02))
            cg.addLine(to: CGPoint(x: w * 0.58, y: h * 0.06))
            cg.addLine(to: CGPoint(x: w * 0.65, y: h * 0.04))
            cg.addLine(to: CGPoint(x: w * 0.70, y: h * 0.08))
            cg.closePath()
            cg.fillPath()

            // Bottom end (rings)
            cg.setFillColor(UIColor(red: 0.60, green: 0.47, blue: 0.16, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.88, width: w * 0.40, height: h * 0.10))
            cg.setStrokeColor(UIColor(red: 0.72, green: 0.60, blue: 0.25, alpha: 0.5).cgColor)
            cg.setLineWidth(0.3)
            cg.strokeEllipse(in: CGRect(x: w * 0.36, y: h * 0.90, width: w * 0.28, height: h * 0.06))
            cg.strokeEllipse(in: CGRect(x: w * 0.42, y: h * 0.91, width: w * 0.16, height: h * 0.04))

            // Moss (along left side)
            let mossData: [(cy: CGFloat, rx: CGFloat, ry: CGFloat, a: CGFloat, g: CGFloat)] = [
                (0.24, 0.08, 0.06, 0.6, 0.55), (0.22, 0.06, 0.04, 0.5, 0.64), (0.26, 0.04, 0.03, 0.4, 0.75),
                (0.58, 0.09, 0.07, 0.55, 0.55), (0.56, 0.06, 0.05, 0.45, 0.64), (0.60, 0.04, 0.04, 0.35, 0.75)
            ]
            for m in mossData {
                cg.setFillColor(UIColor(red: 0.29, green: m.g, blue: 0.16, alpha: m.a).cgColor)
                cg.fillEllipse(in: CGRect(x: w * (0.26 - m.rx), y: h * (m.cy - m.ry), width: w * m.rx * 2, height: h * m.ry * 2))
            }

            // Small twig
            cg.setStrokeColor(UIColor(red: 0.48, green: 0.36, blue: 0.12, alpha: 1.0).cgColor)
            cg.setLineWidth(1.2)
            cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.70, y: h * 0.38))
            cg.addLine(to: CGPoint(x: w * 0.88, y: h * 0.32))
            cg.strokePath()
            cg.setLineWidth(0.8)
            cg.move(to: CGPoint(x: w * 0.88, y: h * 0.32))
            cg.addLine(to: CGPoint(x: w * 0.92, y: h * 0.28))
            cg.strokePath()

            // Leaf on twig
            cg.setFillColor(UIColor(red: 0.35, green: 0.60, blue: 0.20, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.89, y: h * 0.30))
            cg.addQuadCurve(to: CGPoint(x: w * 0.95, y: h * 0.25),
                            control: CGPoint(x: w * 0.95, y: h * 0.30))
            cg.addQuadCurve(to: CGPoint(x: w * 0.89, y: h * 0.30),
                            control: CGPoint(x: w * 0.91, y: h * 0.24))
            cg.fillPath()
        }
        return SKTexture(image: image)
    }
}
