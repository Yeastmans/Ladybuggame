import SpriteKit

class Spider: SKSpriteNode {

    private var walkFrames: [SKTexture]

    init(walkFrames: [SKTexture]) {
        self.walkFrames = walkFrames
        let first = walkFrames.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 5

        if walkFrames.count >= 2 {
            let walk = SKAction.animate(with: walkFrames, timePerFrame: 0.10)
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

    func startCrawling() {
        let crawlDist = CGFloat.random(in: 20...45)
        let flipRight = SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) }
        let crawlRight = SKAction.moveBy(x: crawlDist, y: 0, duration: Double.random(in: 0.8...1.4))
        let flipLeft = SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) }
        let crawlLeft = SKAction.moveBy(x: -crawlDist, y: 0, duration: Double.random(in: 0.8...1.4))
        let pause = SKAction.wait(forDuration: Double.random(in: 0.5...1.5))
        run(SKAction.repeatForever(SKAction.sequence([flipRight, crawlRight, pause, flipLeft, crawlLeft, pause])), withKey: "crawl")
    }
}
