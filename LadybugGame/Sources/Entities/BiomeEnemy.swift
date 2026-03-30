import SpriteKit

/// Generic ground enemy used across biomes (scorpion, rattlesnake, ice spider, etc.)
class BiomeEnemy: SKSpriteNode {

    let biomeName: String
    private var hasLunged = false
    private var baseY: CGFloat = 0

    init(texture: SKTexture, biomeName: String) {
        self.biomeName = biomeName
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.6)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startPatrolling() {
        baseY = position.y

        let dist = CGFloat.random(in: 12...30)
        let right = SKAction.sequence([
            SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) },
            SKAction.moveBy(x: dist, y: 0, duration: Double.random(in: 0.6...1.2))
        ])
        let left = SKAction.sequence([
            SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) },
            SKAction.moveBy(x: -dist, y: 0, duration: Double.random(in: 0.6...1.2))
        ])
        let pause = SKAction.wait(forDuration: Double.random(in: 0.4...1.0))
        run(SKAction.repeatForever(SKAction.sequence([right, pause, left, pause])), withKey: "patrol")

        // Idle breathing animation
        let breathe = SKAction.sequence([
            SKAction.scaleY(to: 1.06, duration: 0.6),
            SKAction.scaleY(to: 0.96, duration: 0.6),
        ])
        run(SKAction.repeatForever(breathe), withKey: "breathe")
    }

    /// Big lunge toward player when close — scorpions/snakes jump HIGH
    func lungeIfNear(playerX: CGFloat) {
        guard !hasLunged else { return }
        let dist = playerX - position.x
        if dist > -15 && dist < 70 {
            hasLunged = true
            baseY = position.y

            // Anticipation squash
            let squash = SKAction.group([
                SKAction.scaleX(to: 1.2, duration: 0.08),
                SKAction.scaleY(to: 0.8, duration: 0.08),
            ])

            // BIG jump — high arc
            let jumpH: CGFloat = biomeName == "Rattlesnake" ? 110 : 100
            let jumpX: CGFloat = biomeName == "Rattlesnake" ? 60 : 50
            let jumpUp = SKAction.group([
                SKAction.moveBy(x: jumpX * 0.6, y: jumpH, duration: 0.22),
                SKAction.scaleX(to: 0.9, duration: 0.22),
                SKAction.scaleY(to: 1.15, duration: 0.22),
            ])
            jumpUp.timingMode = .easeOut

            // Hang at apex briefly
            let apex = SKAction.wait(forDuration: 0.06)

            // Fall down
            let fallDown = SKAction.group([
                SKAction.moveBy(x: jumpX * 0.4, y: -jumpH, duration: 0.2),
                SKAction.scaleX(to: 1.0, duration: 0.2),
                SKAction.scaleY(to: 1.0, duration: 0.2),
            ])
            fallDown.timingMode = .easeIn

            // Landing impact squash
            let landSquash = SKAction.group([
                SKAction.scaleX(to: 1.25, duration: 0.05),
                SKAction.scaleY(to: 0.75, duration: 0.05),
            ])
            let landRecover = SKAction.group([
                SKAction.scaleX(to: 1.0, duration: 0.12),
                SKAction.scaleY(to: 1.0, duration: 0.12),
            ])

            let sound = SKAction.run {
                SoundManager.shared.play("hiss")
            }

            run(SKAction.sequence([sound, squash, jumpUp, apex, fallDown, landSquash, landRecover]))
        }
    }
}
