import SpriteKit

/// Cave spider that hangs from the ceiling on a silk thread and lunges down when player approaches.
class CaveSpider: SKSpriteNode {

    private var webLine = SKShapeNode()
    private var hasLunged = false
    private var anchorCeilingY: CGFloat
    private let lungeDistance: CGFloat = 80

    init(texture: SKTexture, ceilingY: CGFloat) {
        self.anchorCeilingY = ceilingY
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5

        webLine.strokeColor = SKColor(white: 0.70, alpha: 0.6)
        webLine.lineWidth = 1.2
        webLine.zPosition = -1
        addChild(webLine)
        updateWebLine()
    }

    required init?(coder: NSCoder) { fatalError() }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.6)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startSwaying() {
        let sway = SKAction.sequence([
            SKAction.moveBy(x: 6, y: 0, duration: 1.5),
            SKAction.moveBy(x: -6, y: 0, duration: 1.5),
        ])
        run(SKAction.repeatForever(sway), withKey: "sway")
    }

    func lungeIfPlayerNear(playerX: CGFloat) {
        guard !hasLunged else { return }
        let dist = playerX - position.x
        if dist > -20 && dist < 80 {
            hasLunged = true
            removeAction(forKey: "sway")
            SoundManager.shared.play("hiss")

            let drop = SKAction.moveBy(x: 0, y: -lungeDistance, duration: 0.20)
            drop.timingMode = .easeIn
            let hold = SKAction.wait(forDuration: 0.4)
            let retract = SKAction.moveBy(x: 0, y: lungeDistance, duration: 1.0)
            retract.timingMode = .easeInEaseOut
            let done = SKAction.run { [weak self] in
                self?.hasLunged = false
                self?.startSwaying()
            }
            run(SKAction.sequence([drop, hold, retract, done]))
        }
    }

    /// Called each frame — keeps silk line drawn from ceiling to spider
    func updateVisuals(currentCeilingY: CGFloat) {
        anchorCeilingY = currentCeilingY
        updateWebLine()
    }

    private func updateWebLine() {
        // Silk always extends from ceiling anchor point to the spider's current position
        let path = CGMutablePath()
        let topY = anchorCeilingY - position.y // ceiling in local coords
        path.move(to: CGPoint(x: 0, y: topY))
        path.addLine(to: .zero) // spider center
        webLine.path = path
    }
}
