import SpriteKit
import UIKit

enum TextureGenerator {

    // MARK: - Ladybug SIDE VIEW (facing right)

    static func generateLadybugTexture(size: CGSize) -> SKTexture {
        return drawLadybugSide(size: size, eyesClosed: false, wingPhase: nil)
    }

    static func generateLadybugBlinkTexture(size: CGSize) -> SKTexture {
        return drawLadybugSide(size: size, eyesClosed: true, wingPhase: nil)
    }

    /// Two frames: wings up and wings down, legs tucked
    static func generateLadybugFlyFrames(size: CGSize) -> [SKTexture] {
        return [drawLadybugSide(size: size, eyesClosed: false, wingPhase: 0),
                drawLadybugSide(size: size, eyesClosed: false, wingPhase: 1)]
    }

    /// wingPhase: nil = walking (legs out), 0 = wings up, 1 = wings down
    private static func drawLadybugSide(size: CGSize, eyesClosed: Bool, wingPhase: Int?) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            let legColor = UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor
            let isFlying = wingPhase != nil

            // === Legs ===
            cg.setStrokeColor(legColor)
            cg.setLineWidth(1.5)
            cg.setLineCap(.round)

            if isFlying {
                // Tucked legs — shorter, angled back
                let legXs: [CGFloat] = [0.38, 0.52, 0.66]
                for lx in legXs {
                    cg.move(to: CGPoint(x: w * lx, y: h * 0.72))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.04), y: h * 0.80))
                    cg.strokePath()
                }
            } else {
                // Normal walking legs
                let legXs: [CGFloat] = [0.35, 0.52, 0.70]
                for lx in legXs {
                    cg.move(to: CGPoint(x: w * lx, y: h * 0.72))
                    cg.addLine(to: CGPoint(x: w * (lx - 0.03), y: h * 0.88))
                    cg.addLine(to: CGPoint(x: w * (lx + 0.02), y: h * 0.95))
                    cg.strokePath()
                }
            }

            if let phase = wingPhase {
                // === Translucent flight wing ===
                let wingAngle: CGFloat = phase == 0 ? -0.35 : 0.1
                cg.setFillColor(UIColor(red: 0.78, green: 0.85, blue: 0.91, alpha: 0.4).cgColor)
                cg.saveGState()
                cg.translateBy(x: w * 0.48, y: h * 0.40)
                cg.rotate(by: wingAngle)
                cg.fillEllipse(in: CGRect(x: -w * 0.20, y: -h * 0.25, width: w * 0.40, height: h * 0.28))
                // Wing vein
                cg.setStrokeColor(UIColor(red: 0.63, green: 0.69, blue: 0.75, alpha: 0.3).cgColor)
                cg.setLineWidth(0.4)
                cg.move(to: CGPoint(x: 0, y: 0))
                cg.addLine(to: CGPoint(x: w * 0.12, y: -h * 0.18))
                cg.strokePath()
                cg.restoreGState()

                // Body dome (same as walking but drawn over wing)
                let bodyRect = CGRect(x: w * 0.18, y: h * 0.25, width: w * 0.65, height: h * 0.48)
                cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
                cg.fillEllipse(in: bodyRect)
                cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
                cg.setLineWidth(1.2)
                cg.strokeEllipse(in: bodyRect)

                // Spots
                let spotColor = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
                cg.setFillColor(spotColor)
                cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.32, width: w * 0.11, height: w * 0.11))
                cg.fillEllipse(in: CGRect(x: w * 0.50, y: h * 0.30, width: w * 0.14, height: w * 0.14))
                cg.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.48, width: w * 0.09, height: w * 0.09))
                cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.38, width: w * 0.10, height: w * 0.10))
                cg.fillEllipse(in: CGRect(x: w * 0.25, y: h * 0.48, width: w * 0.07, height: w * 0.07))
            } else {
                // === Body dome (red, side profile) ===
                let bodyRect = CGRect(x: w * 0.18, y: h * 0.22, width: w * 0.65, height: h * 0.52)
                cg.setFillColor(UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0).cgColor)
                cg.fillEllipse(in: bodyRect)
                cg.setStrokeColor(UIColor(red: 0.55, green: 0.05, blue: 0.05, alpha: 1.0).cgColor)
                cg.setLineWidth(1.5)
                cg.strokeEllipse(in: bodyRect)

                // Spots
                let spotColor = UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1.0).cgColor
                cg.setFillColor(spotColor)
                cg.fillEllipse(in: CGRect(x: w * 0.30, y: h * 0.30, width: w * 0.12, height: w * 0.12))
                cg.fillEllipse(in: CGRect(x: w * 0.50, y: h * 0.28, width: w * 0.15, height: w * 0.15))
                cg.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.48, width: w * 0.10, height: w * 0.10))
                cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.38, width: w * 0.11, height: w * 0.11))
                cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.52, width: w * 0.07, height: w * 0.07))
                cg.fillEllipse(in: CGRect(x: w * 0.25, y: h * 0.50, width: w * 0.08, height: w * 0.08))
            }

            // === Head (black, on the right) ===
            let headR = w * 0.16
            let headCX = w * 0.88
            let headCY = h * 0.50
            cg.setFillColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: headCX - headR, y: headCY - headR, width: headR * 2, height: headR * 2))

            // Antenna
            cg.setStrokeColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
            cg.setLineWidth(1.4)
            cg.move(to: CGPoint(x: headCX + headR * 0.3, y: headCY - headR * 0.5))
            cg.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.18),
                            control: CGPoint(x: w * 0.96, y: h * 0.30))
            cg.strokePath()
            cg.setFillColor(UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.96, y: h * 0.15, width: 4, height: 4))

            // Eye
            if eyesClosed {
                cg.setStrokeColor(UIColor.white.cgColor)
                cg.setLineWidth(1.2)
                cg.move(to: CGPoint(x: headCX + headR * 0.1, y: headCY - 1))
                cg.addLine(to: CGPoint(x: headCX + headR * 0.7, y: headCY - 1))
                cg.strokePath()
            } else {
                cg.setFillColor(UIColor.white.cgColor)
                let eyeR = headR * 0.55
                cg.fillEllipse(in: CGRect(x: headCX + headR * 0.15, y: headCY - eyeR * 0.7, width: eyeR, height: eyeR))
                cg.setFillColor(UIColor.black.cgColor)
                cg.fillEllipse(in: CGRect(x: headCX + headR * 0.35, y: headCY - eyeR * 0.4, width: eyeR * 0.5, height: eyeR * 0.5))
                cg.setFillColor(UIColor.white.cgColor)
                cg.fillEllipse(in: CGRect(x: headCX + headR * 0.30, y: headCY - eyeR * 0.6, width: eyeR * 0.2, height: eyeR * 0.2))
            }

            // Cheek blush
            cg.setFillColor(UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.3).cgColor)
            cg.fillEllipse(in: CGRect(x: headCX - headR * 0.1, y: headCY + headR * 0.2, width: headR * 0.6, height: headR * 0.3))
        }
        return SKTexture(image: image)
    }

    // MARK: - Aphid SIDE VIEW (two walk frames)

    static func generateAphidWalkFrames(size: CGSize, color: AphidColor) -> [SKTexture] {
        return [drawAphidSide(size: size, color: color, legPhase: 0),
                drawAphidSide(size: size, color: color, legPhase: 1)]
    }

    static func generateAphidTexture(size: CGSize, color: AphidColor) -> SKTexture {
        return drawAphidSide(size: size, color: color, legPhase: 0)
    }

    private static func drawAphidSide(size: CGSize, color: AphidColor, legPhase: Int) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            let legC = color.legColor.cgColor
            cg.setStrokeColor(legC)
            cg.setLineWidth(0.8)
            cg.setLineCap(.round)

            // 3 legs, alternating phase
            let fwd: CGFloat = legPhase == 0 ? 0.04 : -0.04
            let legData: [(x: CGFloat, baseY: CGFloat)] = [(0.28, 0.70), (0.48, 0.72), (0.68, 0.70)]
            for (i, ld) in legData.enumerated() {
                let offset = (i % 2 == 0) ? fwd : -fwd
                cg.move(to: CGPoint(x: w * ld.x, y: h * ld.baseY))
                cg.addLine(to: CGPoint(x: w * (ld.x + offset - 0.02), y: h * 0.88))
                cg.addLine(to: CGPoint(x: w * (ld.x + offset + 0.03), y: h * 0.95))
                cg.strokePath()
            }

            // Body (oval, side profile)
            cg.setFillColor(color.bodyColor.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.30, width: w * 0.70, height: h * 0.45))

            // Head (right side)
            cg.setFillColor(color.headColor.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.32, width: w * 0.28, height: h * 0.36))

            // Eye
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.80, y: h * 0.38, width: w * 0.10, height: w * 0.10))
            cg.setFillColor(UIColor.black.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.83, y: h * 0.40, width: w * 0.05, height: w * 0.05))

            // Antenna
            cg.setStrokeColor(legC)
            cg.setLineWidth(0.6)
            cg.move(to: CGPoint(x: w * 0.85, y: h * 0.34))
            cg.addLine(to: CGPoint(x: w * 0.95, y: h * 0.18))
            cg.strokePath()
        }
        return SKTexture(image: image)
    }

    // MARK: - Fruit Fly (colored variants)

    enum FlyColor {
        case brown, blue, purple
        var body: UIColor {
            switch self {
            case .brown: return UIColor(red: 0.55, green: 0.38, blue: 0.18, alpha: 1.0)
            case .blue: return UIColor(red: 0.20, green: 0.45, blue: 0.75, alpha: 1.0)
            case .purple: return UIColor(red: 0.55, green: 0.25, blue: 0.70, alpha: 1.0)
            }
        }
        var head: UIColor {
            switch self {
            case .brown: return UIColor(red: 0.50, green: 0.35, blue: 0.15, alpha: 1.0)
            case .blue: return UIColor(red: 0.15, green: 0.35, blue: 0.60, alpha: 1.0)
            case .purple: return UIColor(red: 0.42, green: 0.18, blue: 0.55, alpha: 1.0)
            }
        }
        var eye: UIColor {
            switch self {
            case .brown: return UIColor(red: 0.85, green: 0.15, blue: 0.10, alpha: 1.0)
            case .blue: return UIColor(red: 0.20, green: 0.70, blue: 0.90, alpha: 1.0)
            case .purple: return UIColor(red: 0.80, green: 0.30, blue: 0.85, alpha: 1.0)
            }
        }
        var points: Int {
            switch self {
            case .brown: return 15
            case .blue: return 30
            case .purple: return 50
            }
        }
    }

    static func generateFruitFlyFrames(size: CGSize, color: FlyColor = .brown) -> [SKTexture] {
        return [drawFruitFly(size: size, wingsUp: true, color: color),
                drawFruitFly(size: size, wingsUp: false, color: color)]
    }

    private static func drawFruitFly(size: CGSize, wingsUp: Bool, color: FlyColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Wings
            cg.setFillColor(UIColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 0.45).cgColor)
            if wingsUp {
                cg.saveGState()
                cg.translateBy(x: w * 0.45, y: h * 0.30)
                cg.rotate(by: -0.4)
                cg.fillEllipse(in: CGRect(x: -w * 0.18, y: -h * 0.22, width: w * 0.36, height: h * 0.28))
                cg.restoreGState()
            } else {
                cg.saveGState()
                cg.translateBy(x: w * 0.45, y: h * 0.45)
                cg.rotate(by: 0.2)
                cg.fillEllipse(in: CGRect(x: -w * 0.18, y: -h * 0.12, width: w * 0.36, height: h * 0.24))
                cg.restoreGState()
            }

            // Body
            cg.setFillColor(color.body.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.20, y: h * 0.38, width: w * 0.50, height: h * 0.35))

            // Stripes
            cg.setStrokeColor(UIColor(white: 0.0, alpha: 0.15).cgColor)
            cg.setLineWidth(0.5)
            cg.move(to: CGPoint(x: w * 0.30, y: h * 0.52))
            cg.addLine(to: CGPoint(x: w * 0.55, y: h * 0.52))
            cg.strokePath()

            // Head
            cg.setFillColor(color.head.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.62, y: h * 0.35, width: w * 0.28, height: h * 0.32))

            // Eye
            cg.setFillColor(color.eye.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.74, y: h * 0.38, width: w * 0.16, height: w * 0.16))
            cg.setFillColor(UIColor.black.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.80, y: h * 0.42, width: w * 0.06, height: w * 0.06))

            // Legs
            cg.setStrokeColor(UIColor(white: 0.2, alpha: 0.5).cgColor)
            cg.setLineWidth(0.5)
            for lx in [0.35, 0.45, 0.55] as [CGFloat] {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.72))
                cg.addLine(to: CGPoint(x: w * (lx - 0.02), y: h * 0.85))
                cg.strokePath()
            }
        }
        return SKTexture(image: image)
    }

    // MARK: - Aphid Colors

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

    // MARK: - Dragonfly (side view, two wing frames)

    static func generateDragonflyFrames(size: CGSize) -> [SKTexture] {
        return [drawDragonfly(size: size, wingsUp: true),
                drawDragonfly(size: size, wingsUp: false)]
    }

    private static func drawDragonfly(size: CGSize, wingsUp: Bool) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Long thin abdomen
            cg.setFillColor(UIColor(red: 0.15, green: 0.40, blue: 0.60, alpha: 1.0).cgColor)
            cg.fill(CGRect(x: w * 0.02, y: h * 0.42, width: w * 0.55, height: h * 0.16))
            // Abdomen segments
            cg.setStrokeColor(UIColor(red: 0.10, green: 0.30, blue: 0.45, alpha: 0.4).cgColor)
            cg.setLineWidth(0.4)
            for sx in stride(from: 0.10, through: 0.50, by: 0.08) {
                cg.move(to: CGPoint(x: w * CGFloat(sx), y: h * 0.42))
                cg.addLine(to: CGPoint(x: w * CGFloat(sx), y: h * 0.58))
                cg.strokePath()
            }

            // Wings (long, narrow)
            let wingAlpha: CGFloat = 0.35
            cg.setFillColor(UIColor(red: 0.80, green: 0.88, blue: 0.95, alpha: wingAlpha).cgColor)
            let wingAngle: CGFloat = wingsUp ? -0.3 : 0.2
            // Top wing
            cg.saveGState()
            cg.translateBy(x: w * 0.55, y: h * 0.42)
            cg.rotate(by: wingAngle)
            cg.fillEllipse(in: CGRect(x: -w * 0.30, y: -h * 0.15, width: w * 0.55, height: h * 0.18))
            cg.restoreGState()

            // Thorax
            cg.setFillColor(UIColor(red: 0.18, green: 0.48, blue: 0.65, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.50, y: h * 0.32, width: w * 0.22, height: h * 0.36))

            // Head
            cg.setFillColor(UIColor(red: 0.20, green: 0.50, blue: 0.68, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.68, y: h * 0.30, width: w * 0.22, height: h * 0.35))

            // Huge compound eye
            cg.setFillColor(UIColor(red: 0.30, green: 0.80, blue: 0.50, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.78, y: h * 0.32, width: w * 0.15, height: w * 0.15))
            cg.setFillColor(UIColor.black.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.83, y: h * 0.37, width: w * 0.06, height: w * 0.06))

            // Legs
            cg.setStrokeColor(UIColor(red: 0.12, green: 0.30, blue: 0.42, alpha: 0.6).cgColor)
            cg.setLineWidth(0.5)
            cg.setLineCap(.round)
            for lx in [0.55, 0.62, 0.68] as [CGFloat] {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.62))
                cg.addLine(to: CGPoint(x: w * (lx - 0.02), y: h * 0.78))
                cg.strokePath()
            }
        }
        return SKTexture(image: image)
    }

    // MARK: - Firefly (glowing)

    static func generateFireflyFrames(size: CGSize) -> [SKTexture] {
        return [drawFirefly(size: size, glowBright: true),
                drawFirefly(size: size, glowBright: false)]
    }

    private static func drawFirefly(size: CGSize, glowBright: Bool) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Glow aura
            let glowAlpha: CGFloat = glowBright ? 0.4 : 0.2
            cg.setFillColor(UIColor(red: 1.0, green: 0.95, blue: 0.30, alpha: glowAlpha).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.05, y: h * 0.10, width: w * 0.90, height: h * 0.80))

            // Wings
            cg.setFillColor(UIColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 0.35).cgColor)
            cg.saveGState()
            cg.translateBy(x: w * 0.45, y: h * 0.32)
            cg.rotate(by: glowBright ? -0.3 : 0.15)
            cg.fillEllipse(in: CGRect(x: -w * 0.15, y: -h * 0.18, width: w * 0.30, height: h * 0.22))
            cg.restoreGState()

            // Body (dark)
            cg.setFillColor(UIColor(red: 0.20, green: 0.18, blue: 0.15, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.22, y: h * 0.38, width: w * 0.42, height: h * 0.30))

            // Glowing tail
            let tailAlpha: CGFloat = glowBright ? 0.9 : 0.5
            cg.setFillColor(UIColor(red: 0.95, green: 0.95, blue: 0.20, alpha: tailAlpha).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.12, y: h * 0.42, width: w * 0.20, height: h * 0.22))

            // Head
            cg.setFillColor(UIColor(red: 0.22, green: 0.20, blue: 0.16, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.58, y: h * 0.38, width: w * 0.22, height: h * 0.26))

            // Eyes
            cg.setFillColor(UIColor(red: 1.0, green: 0.90, blue: 0.30, alpha: 0.8).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.72, y: h * 0.42, width: w * 0.10, height: w * 0.10))
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

            // Wings
            cg.setFillColor(UIColor(red: 0.29, green: 0.29, blue: 0.33, alpha: 1.0).cgColor)
            if wingsUp {
                cg.move(to: CGPoint(x: w * 0.45, y: h * 0.45))
                cg.addQuadCurve(to: CGPoint(x: w * 0.30, y: h * 0.0), control: CGPoint(x: w * 0.25, y: h * 0.20))
                cg.addQuadCurve(to: CGPoint(x: w * 0.55, y: h * 0.42), control: CGPoint(x: w * 0.50, y: h * 0.15))
                cg.fillPath()
            } else {
                cg.move(to: CGPoint(x: w * 0.45, y: h * 0.50))
                cg.addQuadCurve(to: CGPoint(x: w * 0.20, y: h * 0.90), control: CGPoint(x: w * 0.20, y: h * 0.65))
                cg.addQuadCurve(to: CGPoint(x: w * 0.55, y: h * 0.55), control: CGPoint(x: w * 0.40, y: h * 0.70))
                cg.fillPath()
            }

            // Tail
            cg.setFillColor(UIColor(red: 0.40, green: 0.30, blue: 0.22, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.05, y: h * 0.40))
            cg.addLine(to: CGPoint(x: -w * 0.05, y: h * 0.35))
            cg.addLine(to: CGPoint(x: -w * 0.03, y: h * 0.50))
            cg.addLine(to: CGPoint(x: -w * 0.06, y: h * 0.60))
            cg.addLine(to: CGPoint(x: w * 0.08, y: h * 0.55))
            cg.closePath()
            cg.fillPath()

            // Body
            cg.setFillColor(UIColor(red: 0.50, green: 0.38, blue: 0.28, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.30, width: w * 0.55, height: h * 0.40))

            // Head
            cg.setFillColor(UIColor(red: 0.55, green: 0.42, blue: 0.32, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.58, y: h * 0.28, width: w * 0.28, height: h * 0.32))

            // Beak
            cg.setFillColor(UIColor(red: 0.95, green: 0.65, blue: 0.10, alpha: 1.0).cgColor)
            cg.move(to: CGPoint(x: w * 0.85, y: h * 0.42))
            cg.addLine(to: CGPoint(x: w * 1.02, y: h * 0.46))
            cg.addLine(to: CGPoint(x: w * 0.85, y: h * 0.52))
            cg.closePath()
            cg.fillPath()

            // Eye
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.72, y: h * 0.34, width: w * 0.10, height: w * 0.10))
            cg.setFillColor(UIColor(red: 0.80, green: 0.20, blue: 0.0, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.75, y: h * 0.37, width: w * 0.06, height: w * 0.06))

            // Eyebrow
            cg.setStrokeColor(UIColor(red: 0.25, green: 0.18, blue: 0.12, alpha: 1.0).cgColor)
            cg.setLineWidth(1.8)
            cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.70, y: h * 0.30))
            cg.addLine(to: CGPoint(x: w * 0.80, y: h * 0.34))
            cg.strokePath()
        }
        return SKTexture(image: image)
    }

    // MARK: - Log (hollow tube, side view — open ends for walking through)

    // MARK: - Frog (side view, sitting on ground)

    static func generateFrogTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            // Back leg (behind body)
            cg.setFillColor(UIColor(red: 0.25, green: 0.55, blue: 0.15, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.05, y: h * 0.55, width: w * 0.30, height: h * 0.35))

            // Body
            cg.setFillColor(UIColor(red: 0.30, green: 0.65, blue: 0.20, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.20, width: w * 0.60, height: h * 0.55))

            // Belly
            cg.setFillColor(UIColor(red: 0.70, green: 0.85, blue: 0.50, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.22, y: h * 0.45, width: w * 0.35, height: h * 0.28))

            // Head
            cg.setFillColor(UIColor(red: 0.32, green: 0.68, blue: 0.22, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.55, y: h * 0.12, width: w * 0.40, height: h * 0.45))

            // Big eye (bulging on top)
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.72, y: h * 0.05, width: w * 0.22, height: w * 0.22))
            cg.setFillColor(UIColor.black.cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.78, y: h * 0.10, width: w * 0.12, height: w * 0.12))

            // Mouth line
            cg.setStrokeColor(UIColor(red: 0.20, green: 0.45, blue: 0.12, alpha: 1.0).cgColor)
            cg.setLineWidth(1.2)
            cg.setLineCap(.round)
            cg.move(to: CGPoint(x: w * 0.80, y: h * 0.40))
            cg.addLine(to: CGPoint(x: w * 0.98, y: h * 0.38))
            cg.strokePath()

            // Front leg
            cg.setFillColor(UIColor(red: 0.28, green: 0.60, blue: 0.18, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.55, y: h * 0.60, width: w * 0.18, height: h * 0.32))
            // Foot
            cg.fillEllipse(in: CGRect(x: w * 0.58, y: h * 0.82, width: w * 0.20, height: h * 0.12))

            // Back foot
            cg.fillEllipse(in: CGRect(x: w * 0.02, y: h * 0.82, width: w * 0.22, height: h * 0.12))

            // Spots
            cg.setFillColor(UIColor(red: 0.22, green: 0.50, blue: 0.12, alpha: 0.4).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.25, y: h * 0.28, width: w * 0.10, height: w * 0.10))
            cg.fillEllipse(in: CGRect(x: w * 0.42, y: h * 0.22, width: w * 0.08, height: w * 0.08))
        }
        return SKTexture(image: image)
    }

    // MARK: - Log (hollow tube, side view — open ends for walking through)

    static func generateLogTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            let barkColor = UIColor(red: 0.50, green: 0.38, blue: 0.10, alpha: 1.0)
            let barkDark = UIColor(red: 0.38, green: 0.28, blue: 0.06, alpha: 1.0)

            // Dark hollow interior (full width, middle section)
            cg.setFillColor(UIColor(red: 0.25, green: 0.16, blue: 0.04, alpha: 1.0).cgColor)
            cg.fill(CGRect(x: 0, y: h * 0.30, width: w, height: h * 0.40))

            // Top bark — arch from left to right, peak at center
            let top = UIBezierPath()
            top.move(to: CGPoint(x: 0, y: h * 0.30))
            top.addQuadCurve(to: CGPoint(x: w, y: h * 0.30),
                              controlPoint: CGPoint(x: w * 0.5, y: -h * 0.05))
            top.addLine(to: CGPoint(x: w, y: h * 0.30))
            top.close()
            cg.setFillColor(barkColor.cgColor)
            cg.addPath(top.cgPath)
            cg.fillPath()
            cg.setStrokeColor(barkDark.cgColor)
            cg.setLineWidth(1.0)
            let topCurve = UIBezierPath()
            topCurve.move(to: CGPoint(x: 0, y: h * 0.30))
            topCurve.addQuadCurve(to: CGPoint(x: w, y: h * 0.30),
                                   controlPoint: CGPoint(x: w * 0.5, y: -h * 0.05))
            cg.addPath(topCurve.cgPath)
            cg.strokePath()

            // Bottom bark — FLAT bottom, fills to bottom edge
            cg.setFillColor(barkColor.cgColor)
            cg.fill(CGRect(x: 0, y: h * 0.70, width: w, height: h * 0.30))
            // Inner curve line on top of bottom bark
            cg.setStrokeColor(barkDark.cgColor)
            cg.setLineWidth(0.8)
            cg.move(to: CGPoint(x: 0, y: h * 0.72))
            cg.addQuadCurve(to: CGPoint(x: w, y: h * 0.72),
                             controlPoint: CGPoint(x: w * 0.5, y: h * 0.78))
            cg.strokePath()

            // Bark lines
            cg.setStrokeColor(UIColor(red: 0.42, green: 0.31, blue: 0.08, alpha: 0.3).cgColor)
            cg.setLineWidth(0.5)
            for lx in [0.2, 0.4, 0.6, 0.8] as [CGFloat] {
                cg.move(to: CGPoint(x: w * lx, y: h * 0.02))
                cg.addLine(to: CGPoint(x: w * lx, y: h * 0.28))
                cg.strokePath()
            }

            // Moss
            cg.setFillColor(UIColor(red: 0.29, green: 0.55, blue: 0.16, alpha: 0.5).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.18, y: 0, width: w * 0.15, height: h * 0.08))
            cg.fillEllipse(in: CGRect(x: w * 0.52, y: 0, width: w * 0.20, height: h * 0.06))

            // Right opening (cross-section)
            cg.setFillColor(UIColor(red: 0.58, green: 0.44, blue: 0.14, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.87, y: h * 0.05, width: w * 0.14, height: h * 0.90))
            cg.setStrokeColor(barkDark.cgColor)
            cg.setLineWidth(1.0)
            cg.strokeEllipse(in: CGRect(x: w * 0.87, y: h * 0.05, width: w * 0.14, height: h * 0.90))
            // Rings
            cg.setStrokeColor(UIColor(red: 0.68, green: 0.55, blue: 0.25, alpha: 0.35).cgColor)
            cg.setLineWidth(0.4)
            cg.strokeEllipse(in: CGRect(x: w * 0.89, y: h * 0.20, width: w * 0.10, height: h * 0.60))
            cg.strokeEllipse(in: CGRect(x: w * 0.91, y: h * 0.35, width: w * 0.06, height: h * 0.30))
        }
        return SKTexture(image: image)
    }
}
