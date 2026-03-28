import SpriteKit

class HeartBug: SKSpriteNode {

    var minY: CGFloat = 0

    init(textures: [SKTexture]) {
        let first = textures.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 7

        if textures.count >= 2 {
            let flap = SKAction.animate(with: textures, timePerFrame: 0.10)
            run(SKAction.repeatForever(flap), withKey: "flap")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.5)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.fruitfly
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    /// Erratic movement that tries to avoid the player
    func startMoving(playerGetter: @escaping () -> CGPoint?) {
        let evade = SKAction.run { [weak self] in
            guard let self = self else { return }
            let playerPos = playerGetter()

            var dx = CGFloat.random(in: -20...20)
            var dy = CGFloat.random(in: -25...25)

            // If player is close, flee away from them
            if let pp = playerPos {
                let distToPlayer = hypot(pp.x - self.position.x, pp.y - self.position.y)
                if distToPlayer < 100 {
                    dx += (self.position.x - pp.x) * 0.3
                    dy += (self.position.y - pp.y) * 0.3
                }
            }

            // Flip based on direction
            if dx > 0 { self.xScale = abs(self.xScale) }
            else { self.xScale = -abs(self.xScale) }

            let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.2...0.4))
            move.timingMode = .easeInEaseOut
            self.run(move, withKey: "evadeMove")
        }
        let clamp = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.position.y < self.minY + self.size.height / 2 {
                self.position.y = self.minY + self.size.height / 2
            }
        }
        let wait = SKAction.wait(forDuration: 0.25, withRange: 0.15)
        run(SKAction.repeatForever(SKAction.sequence([evade, wait, clamp])), withKey: "evade")
    }
}
