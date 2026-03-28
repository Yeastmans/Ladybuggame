import SpriteKit

class FruitFly: SKSpriteNode {

    let points: Int

    init(textures: [SKTexture], points: Int) {
        self.points = points
        let first = textures.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 5

        // Wing flap animation
        if textures.count >= 2 {
            let flap = SKAction.animate(with: textures, timePerFrame: 0.06)
            run(SKAction.repeatForever(flap), withKey: "flap")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.6)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.fruitfly
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    var minY: CGFloat = 0

    func startMoving() {
        let bob = SKAction.run { [weak self] in
            guard let self = self else { return }
            let dy = CGFloat.random(in: 10...30) * (Bool.random() ? 1.0 : -1.0)
            let dx = CGFloat.random(in: 5...15) * (Bool.random() ? 1.0 : -1.0)
            // Flip based on horizontal direction
            if dx > 0 { self.xScale = abs(self.xScale) }
            else { self.xScale = -abs(self.xScale) }
            let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.3...0.6))
            move.timingMode = .easeInEaseOut
            self.run(move, withKey: "bobMove")
        }
        let clamp = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.position.y < self.minY + self.size.height / 2 {
                self.position.y = self.minY + self.size.height / 2
            }
        }
        let wait = SKAction.wait(forDuration: 0.3, withRange: 0.3)
        run(SKAction.repeatForever(SKAction.sequence([bob, wait, clamp])), withKey: "bob")
    }
}
