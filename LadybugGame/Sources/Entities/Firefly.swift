import SpriteKit

class Firefly: SKSpriteNode {

    init(textures: [SKTexture]) {
        let first = textures.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 6

        if textures.count >= 2 {
            let glow = SKAction.animate(with: textures, timePerFrame: 0.4)
            run(SKAction.repeatForever(glow), withKey: "glow")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.5)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.fruitfly // Collected like a fly
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startMoving(minY: CGFloat, maxY: CGFloat) {
        let drift = SKAction.run { [weak self] in
            guard let self = self else { return }
            let ty = CGFloat.random(in: minY...maxY)
            let dy = ty - self.position.y
            let dx = CGFloat.random(in: -8...8)
            let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.6...1.2))
            move.timingMode = .easeInEaseOut
            self.run(move, withKey: "driftMove")
        }
        let wait = SKAction.wait(forDuration: 0.6, withRange: 0.4)
        run(SKAction.repeatForever(SKAction.sequence([drift, wait])), withKey: "drift")
    }
}
