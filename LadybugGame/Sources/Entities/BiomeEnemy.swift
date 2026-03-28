import SpriteKit

/// Generic ground enemy used across biomes (scorpion, ice spider, jungle spider)
class BiomeEnemy: SKSpriteNode {

    let biomeName: String
    private var hasLunged = false

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
    }

    /// Lunge toward player when close
    func lungeIfNear(playerX: CGFloat) {
        guard !hasLunged else { return }
        let dist = playerX - position.x
        if dist > -15 && dist < 60 {
            hasLunged = true
            let lunge = SKAction.moveBy(x: 45, y: 30, duration: 0.15)
            lunge.timingMode = .easeOut
            let fall = SKAction.moveBy(x: 10, y: -30, duration: 0.18)
            fall.timingMode = .easeIn
            run(SKAction.sequence([lunge, fall]))
        }
    }
}
