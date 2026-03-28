import SpriteKit

class Aphid: SKSpriteNode {

    let points: Int
    let colorType: TextureGenerator.AphidColor
    let isFlying: Bool

    init(texture: SKTexture, colorType: TextureGenerator.AphidColor, isFlying: Bool) {
        self.points = colorType.points
        self.colorType = colorType
        self.isFlying = isFlying
        super.init(texture: texture, color: .clear, size: texture.size())
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
        if isFlying {
            // Bob up and down gently
            let bobUp = SKAction.moveBy(x: 0, y: CGFloat.random(in: 12...25), duration: Double.random(in: 0.6...1.0))
            bobUp.timingMode = .easeInEaseOut
            let bobDown = SKAction.moveBy(x: 0, y: CGFloat.random(in: -25...-12), duration: Double.random(in: 0.6...1.0))
            bobDown.timingMode = .easeInEaseOut
            run(SKAction.repeatForever(SKAction.sequence([bobUp, bobDown])), withKey: "bob")
        } else {
            // Scurry back and forth on the ground
            let scurryRight = SKAction.moveBy(x: CGFloat.random(in: 8...20), y: 0, duration: Double.random(in: 0.3...0.6))
            let scurryLeft = SKAction.moveBy(x: CGFloat.random(in: -20...-8), y: 0, duration: Double.random(in: 0.3...0.6))
            let pause = SKAction.wait(forDuration: Double.random(in: 0.2...0.5))
            run(SKAction.repeatForever(SKAction.sequence([scurryRight, pause, scurryLeft, pause])), withKey: "scurry")
        }
    }
}
