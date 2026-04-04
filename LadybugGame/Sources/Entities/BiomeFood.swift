import SpriteKit

/// Generic food entity used across biomes
class BiomeFood: SKSpriteNode {

    let points: Int
    let biomeName: String
    let isFlying: Bool
    var isGemBug: Bool = false
    var minY: CGFloat = 0

    init(texture: SKTexture, points: Int, biomeName: String, isFlying: Bool) {
        self.points = points
        self.biomeName = biomeName
        self.isFlying = isFlying
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5
    }

    /// Make this a rare gemstone bug — pink glow aura around it
    func makeGemBug() {
        isGemBug = true
        // Pink glow circle behind the bug (like firefly but pink and smaller)
        let glow = SKShapeNode(circleOfRadius: size.width * 0.6)
        glow.fillColor = SKColor(red: 1.0, green: 0.35, blue: 0.65, alpha: 0.22)
        glow.strokeColor = SKColor(red: 1.0, green: 0.40, blue: 0.70, alpha: 0.35)
        glow.lineWidth = 1.5
        glow.zPosition = -1
        glow.name = "gemGlow"
        addChild(glow)
        // Pulse the glow
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3),
        ])
        glow.run(SKAction.repeatForever(pulse))
        // Also tint the bug slightly pink
        let flash = SKAction.sequence([
            SKAction.colorize(with: SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0), colorBlendFactor: 0.5, duration: 0.2),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2),
        ])
        run(SKAction.repeatForever(flash), withKey: "gemFlash")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.6)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.aphid
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startMoving() {
        if isFlying {
            let bob = SKAction.run { [weak self] in
                guard let self = self else { return }
                let dy = CGFloat.random(in: 8...22) * (Bool.random() ? 1.0 : -1.0)
                let dx = CGFloat.random(in: 3...10) * (Bool.random() ? 1.0 : -1.0)
                if dx > 0 { self.xScale = abs(self.xScale) } else { self.xScale = -abs(self.xScale) }
                let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.3...0.6))
                move.timingMode = .easeInEaseOut
                self.run(move, withKey: "flyMove")
            }
            let clamp = SKAction.run { [weak self] in
                guard let self = self else { return }
                if self.position.y < self.minY + self.size.height / 2 {
                    self.position.y = self.minY + self.size.height / 2
                }
            }
            run(SKAction.repeatForever(SKAction.sequence([bob, SKAction.wait(forDuration: 0.3), clamp])), withKey: "fly")

            // Gentle body tilt while flying
            let tilt = SKAction.sequence([
                SKAction.rotate(toAngle: 0.12, duration: 0.4),
                SKAction.rotate(toAngle: -0.12, duration: 0.4),
            ])
            run(SKAction.repeatForever(tilt), withKey: "tilt")
        } else {
            let dist = CGFloat.random(in: 8...18)
            let right = SKAction.sequence([
                SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) },
                SKAction.moveBy(x: dist, y: 0, duration: Double.random(in: 0.4...0.7))
            ])
            let left = SKAction.sequence([
                SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) },
                SKAction.moveBy(x: -dist, y: 0, duration: Double.random(in: 0.4...0.7))
            ])
            let pause = SKAction.wait(forDuration: Double.random(in: 0.3...0.6))
            run(SKAction.repeatForever(SKAction.sequence([right, pause, left, pause])), withKey: "crawl")

            // Walking bob
            let walkBob = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 2, duration: 0.15),
                SKAction.moveBy(x: 0, y: -2, duration: 0.15),
            ])
            run(SKAction.repeatForever(walkBob), withKey: "walkBob")

            // Squash/stretch while walking
            let squash = SKAction.sequence([
                SKAction.group([SKAction.scaleX(to: 1.08, duration: 0.18), SKAction.scaleY(to: 0.94, duration: 0.18)]),
                SKAction.group([SKAction.scaleX(to: 0.95, duration: 0.18), SKAction.scaleY(to: 1.06, duration: 0.18)]),
            ])
            run(SKAction.repeatForever(squash), withKey: "walkSquash")
        }
    }
}
