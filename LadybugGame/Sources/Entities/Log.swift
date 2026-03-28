import SpriteKit

class Log: SKSpriteNode {

    /// Whether a ladybug is currently hiding under this log.
    var isShielding = false

    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 4 // Above aphids, below birds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: size.height * 0.4))
        body.isDynamic = false
        body.categoryBitMask = 0 // No physics category — collision is checked manually
        physicsBody = body
    }

    func showShieldEffect() {
        guard !isShielding else { return }
        isShielding = true
        let darken = SKAction.colorize(with: .black, colorBlendFactor: 0.15, duration: 0.2)
        run(darken, withKey: "shield")
    }

    func hideShieldEffect() {
        guard isShielding else { return }
        isShielding = false
        let lighten = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        run(lighten, withKey: "shield")
    }
}
