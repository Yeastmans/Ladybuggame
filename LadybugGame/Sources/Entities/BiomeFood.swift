import SpriteKit

/// Generic food entity used across biomes
class BiomeFood: SKSpriteNode {

    let points: Int
    let biomeName: String
    let isFlying: Bool
    var isGemBug: Bool = false
    var minY: CGFloat = 0
    weak var playerRef: SKNode?  // For evasion (butterfly)

    init(texture: SKTexture, points: Int, biomeName: String, isFlying: Bool) {
        self.points = points
        self.biomeName = biomeName
        self.isFlying = isFlying
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5
    }

    /// Make this a rare gemstone bug without wrapping friendly art in an aura.
    /// A compact diamond badge communicates the bonus without resembling danger.
    func makeGemBug() {
        isGemBug = true

        let marker = SKNode()
        marker.name = "gemMarker"
        marker.position = CGPoint(x: 0, y: size.height * 0.72)
        marker.zPosition = 6
        addChild(marker)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 7))
        path.addLine(to: CGPoint(x: 6, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -7))
        path.addLine(to: CGPoint(x: -6, y: 0))
        path.closeSubpath()
        let diamond = SKShapeNode(path: path)
        diamond.fillColor = SKColor(red: 0.95, green: 0.34, blue: 0.82, alpha: 1)
        diamond.strokeColor = SKColor(white: 1, alpha: 0.92)
        diamond.lineWidth = 1
        marker.addChild(diamond)

        let sparkle = SKLabelNode(text: "✦")
        sparkle.fontSize = 8
        sparkle.fontColor = SKColor(red: 1.0, green: 0.88, blue: 0.35, alpha: 1)
        sparkle.position = CGPoint(x: 10, y: 5)
        sparkle.zPosition = 1
        marker.addChild(sparkle)

        marker.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.45),
            SKAction.moveBy(x: 0, y: -3, duration: 0.45),
        ])))
        diamond.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.12, duration: 0.35),
            SKAction.scale(to: 0.92, duration: 0.35),
        ])))
        sparkle.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.25, duration: 0.28),
            SKAction.fadeAlpha(to: 1.0, duration: 0.28),
        ])))
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
                var dy = CGFloat.random(in: 8...22) * (Bool.random() ? 1.0 : -1.0)
                var dx = CGFloat.random(in: 3...10) * (Bool.random() ? 1.0 : -1.0)
                // Butterfly/glowworm/seahorse evasion: flee if player is close
                if (self.biomeName.contains("Butterfly") || self.biomeName == "Glowworm" || self.biomeName == "Seahorse"), let player = self.playerRef {
                    let dist = hypot(player.position.x - self.position.x, player.position.y - self.position.y)
                    let fleeRange: CGFloat = self.biomeName.contains("Butterfly") ? 120 : (self.biomeName == "Seahorse" ? 150 : 80)
                    let fleeFactor: CGFloat = self.biomeName.contains("Butterfly") ? 0.40 : (self.biomeName == "Seahorse" ? 0.55 : 0.30)
                    if dist < fleeRange {
                        dx = (self.position.x - player.position.x) * fleeFactor
                        dy = (self.position.y - player.position.y) * fleeFactor
                    }
                }
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

            // Body tilt/flap — faster for butterflies
            let tiltSpeed = biomeName.contains("Butterfly") ? 0.15 : (biomeName == "Glowworm" ? 0.25 : 0.4)
            let tiltAngle: CGFloat = biomeName.contains("Butterfly") ? 0.25 : (biomeName == "Glowworm" ? 0.18 : 0.12)
            let tilt = SKAction.sequence([
                SKAction.rotate(toAngle: tiltAngle, duration: tiltSpeed),
                SKAction.rotate(toAngle: -tiltAngle, duration: tiltSpeed),
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

            // Squash/stretch while walking (preserves facing direction)
            let squash = SKAction.sequence([
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let sign: CGFloat = self.xScale >= 0 ? 1 : -1
                    self.run(SKAction.scaleX(to: 1.08 * sign, duration: 0.18))
                },
                SKAction.scaleY(to: 0.94, duration: 0.18),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let sign: CGFloat = self.xScale >= 0 ? 1 : -1
                    self.run(SKAction.scaleX(to: 0.95 * sign, duration: 0.18))
                },
                SKAction.scaleY(to: 1.06, duration: 0.18),
            ])
            run(SKAction.repeatForever(squash), withKey: "walkSquash")
        }
    }
}
