import SpriteKit

class Aphid: SKSpriteNode {

    let points: Int
    let colorType: TextureGenerator.AphidColor

    init(texture: SKTexture, colorType: TextureGenerator.AphidColor) {
        self.points = colorType.points
        self.colorType = colorType
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
}
