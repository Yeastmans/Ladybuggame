import SpriteKit

/// A cluster of tiny gnats that buzz around. Night-only food.
class GnatSwarm: SKSpriteNode {

    let points = 5 // Per gnat, but collected as group = 20
    var minY: CGFloat = 0

    init() {
        let size = CGSize(width: 30, height: 30)
        super.init(texture: nil, color: .clear, size: size)
        zPosition = 5

        // Create 4-6 tiny gnat dots
        let count = Int.random(in: 4...6)
        for _ in 0..<count {
            let gnat = SKShapeNode(circleOfRadius: 1.5)
            gnat.fillColor = SKColor(white: 0.85, alpha: 0.7)
            gnat.strokeColor = .clear
            gnat.position = CGPoint(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -10...10))
            addChild(gnat)

            // Individual buzz
            let buzz = SKAction.run { [weak gnat] in
                guard let g = gnat else { return }
                let move = SKAction.moveBy(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), duration: 0.15)
                g.run(move)
            }
            let wait = SKAction.wait(forDuration: 0.1, withRange: 0.1)
            gnat.run(SKAction.repeatForever(SKAction.sequence([buzz, wait])))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 12)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.fruitfly
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startMoving() {
        let drift = SKAction.run { [weak self] in
            guard let self = self else { return }
            let dy = CGFloat.random(in: -15...15)
            let dx = CGFloat.random(in: -8...8)
            let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.3...0.5))
            self.run(move, withKey: "driftMove")
        }
        let clamp = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.position.y < self.minY + 15 { self.position.y = self.minY + 15 }
        }
        let wait = SKAction.wait(forDuration: 0.3, withRange: 0.2)
        run(SKAction.repeatForever(SKAction.sequence([drift, wait, clamp])), withKey: "drift")
    }
}
