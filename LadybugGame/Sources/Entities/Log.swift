import SpriteKit

class Log: SKSpriteNode {

    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.85, height: size.height * 0.6))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.log
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        body.collisionBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }
}
