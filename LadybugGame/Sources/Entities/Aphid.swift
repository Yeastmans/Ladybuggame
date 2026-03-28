import SpriteKit

class Aphid: SKSpriteNode {

    let points: Int
    let colorType: TextureGenerator.AphidColor
    private var walkFrames: [SKTexture]

    init(walkFrames: [SKTexture], colorType: TextureGenerator.AphidColor) {
        self.points = colorType.points
        self.colorType = colorType
        self.walkFrames = walkFrames
        let first = walkFrames.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.7)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.aphid
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startMoving() {
        // Walk animation
        if walkFrames.count >= 2 {
            let anim = SKAction.animate(with: walkFrames, timePerFrame: 0.12)
            run(SKAction.repeatForever(anim), withKey: "walk")
        }

        // Scurry back and forth, flip based on direction
        let scurryDist = CGFloat.random(in: 8...20)
        let flipRight = SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) }
        let scurryRight = SKAction.moveBy(x: scurryDist, y: 0, duration: Double.random(in: 0.3...0.6))
        let flipLeft = SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) }
        let scurryLeft = SKAction.moveBy(x: -scurryDist, y: 0, duration: Double.random(in: 0.3...0.6))
        let pause = SKAction.wait(forDuration: Double.random(in: 0.3...0.8))
        run(SKAction.repeatForever(SKAction.sequence([flipRight, scurryRight, pause, flipLeft, scurryLeft, pause])), withKey: "scurry")
    }
}
