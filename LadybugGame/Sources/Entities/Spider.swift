import SpriteKit

class Spider: SKSpriteNode {

    private var walkFrames: [SKTexture]
    private var hasJumped = false
    var baseY: CGFloat = 0

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
        let crawlDist = CGFloat.random(in: 15...30)
        let flipRight = SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) }
        let crawlRight = SKAction.moveBy(x: crawlDist, y: 0, duration: Double.random(in: 0.8...1.4))
        let flipLeft = SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) }
        let crawlLeft = SKAction.moveBy(x: -crawlDist, y: 0, duration: Double.random(in: 0.8...1.4))
        let pause = SKAction.wait(forDuration: Double.random(in: 0.5...1.5))
        run(SKAction.repeatForever(SKAction.sequence([flipRight, crawlRight, pause, flipLeft, crawlLeft, pause])), withKey: "crawl")
    }

    /// Jump up when player is close — call from GameScene update
    func jumpIfPlayerNear(playerX: CGFloat) {
        guard !hasJumped else { return }
        let dist = playerX - position.x
        if dist > -20 && dist < 60 {
            hasJumped = true
            let jumpUp = SKAction.moveBy(x: 0, y: 35, duration: 0.18)
            jumpUp.timingMode = .easeOut
            let jumpDown = SKAction.moveBy(x: 0, y: -35, duration: 0.22)
            jumpDown.timingMode = .easeIn
            run(SKAction.sequence([jumpUp, jumpDown]))
        }
    }
}
