import SpriteKit

class Ant: SKSpriteNode {

    private var walkFrames: [SKTexture]

    init(walkFrames: [SKTexture]) {
        self.walkFrames = walkFrames
        let first = walkFrames.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 5

        if walkFrames.count >= 2 {
            let walk = SKAction.animate(with: walkFrames, timePerFrame: 0.08)
            run(SKAction.repeatForever(walk), withKey: "walk")
        }
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
        let patrolDist = CGFloat.random(in: 10...25)
        let flipRight = SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) }
        let moveRight = SKAction.moveBy(x: patrolDist, y: 0, duration: Double.random(in: 0.5...0.9))
        let flipLeft = SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) }
        let moveLeft = SKAction.moveBy(x: -patrolDist, y: 0, duration: Double.random(in: 0.5...0.9))
        let pause = SKAction.wait(forDuration: Double.random(in: 0.3...0.8))
        run(SKAction.repeatForever(SKAction.sequence([flipRight, moveRight, pause, flipLeft, moveLeft, pause])), withKey: "patrol")

        // Walking bob and squash
        let walkBob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 1, duration: 0.1),
            SKAction.moveBy(x: 0, y: -1, duration: 0.1),
        ])
        run(SKAction.repeatForever(walkBob), withKey: "walkBob")

        let squash = SKAction.sequence([
            SKAction.group([SKAction.scaleX(to: 1.06, duration: 0.12), SKAction.scaleY(to: 0.95, duration: 0.12)]),
            SKAction.group([SKAction.scaleX(to: 0.96, duration: 0.12), SKAction.scaleY(to: 1.04, duration: 0.12)]),
        ])
        run(SKAction.repeatForever(squash), withKey: "squash")
    }
}
