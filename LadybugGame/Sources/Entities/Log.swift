import SpriteKit

class Log: SKSpriteNode {

    var isLadybugInside = false
    private let normalAlpha: CGFloat = 1.0
    private let seeThruAlpha: CGFloat = 0.4

    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        // No physics body — collision is handled manually in GameScene
    }

    /// The rect the ladybug can walk through (slightly inset)
    var tubeRect: CGRect {
        CGRect(
            x: position.x - size.width * 0.42,
            y: position.y - size.height * 0.3,
            width: size.width * 0.84,
            height: size.height * 0.6
        )
    }

    func showSeeThrough() {
        guard !isLadybugInside else { return }
        isLadybugInside = true
        run(SKAction.fadeAlpha(to: seeThruAlpha, duration: 0.15), withKey: "fade")
        zPosition = 15 // Draw above ladybug so you see it as a tunnel
    }

    func showOpaque() {
        guard isLadybugInside else { return }
        isLadybugInside = false
        run(SKAction.fadeAlpha(to: normalAlpha, duration: 0.15), withKey: "fade")
        zPosition = 4
    }
}
