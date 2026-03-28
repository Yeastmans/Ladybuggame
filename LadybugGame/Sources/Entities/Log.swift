import SpriteKit

class Log: SKSpriteNode {

    var isLadybugInside = false

    init(texture: SKTexture, width: CGFloat) {
        let scaledSize = CGSize(width: width, height: texture.size().height * (width / texture.size().width))
        super.init(texture: texture, color: .clear, size: scaledSize)
        anchorPoint = CGPoint(x: 0.5, y: 0.0) // Bottom-anchored — sits on ground
        zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {}

    /// The tube rect the ladybug walks through
    var tubeRect: CGRect {
        CGRect(
            x: position.x - size.width * 0.45,
            y: position.y,
            width: size.width * 0.90,
            height: size.height
        )
    }

    func showSeeThrough() {
        guard !isLadybugInside else { return }
        isLadybugInside = true
        run(SKAction.fadeAlpha(to: 0.35, duration: 0.15), withKey: "fade")
        zPosition = 15
    }

    func showOpaque() {
        guard isLadybugInside else { return }
        isLadybugInside = false
        run(SKAction.fadeAlpha(to: 1.0, duration: 0.15), withKey: "fade")
        zPosition = 4
    }
}
