import SpriteKit

/// Cave spider that hangs from the ceiling on a web and lunges down when the player approaches.
class CaveSpider: SKSpriteNode {

    private var webLine = SKShapeNode()
    private var hasLunged = false
    private var anchorCeilingY: CGFloat
    private let lungeDistance: CGFloat = 80

    init(texture: SKTexture, ceilingY: CGFloat) {
        self.anchorCeilingY = ceilingY
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5

        webLine.strokeColor = SKColor(white: 0.65, alpha: 0.5)
        webLine.lineWidth = 1
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
            SKAction.moveBy(x: 8, y: 0, duration: 1.2),
            SKAction.moveBy(x: -8, y: 0, duration: 1.2),
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

            let drop = SKAction.moveBy(x: 0, y: -lungeDistance, duration: 0.15)
            drop.timingMode = .easeIn
            let hold = SKAction.wait(forDuration: 0.3)
            let retract = SKAction.moveBy(x: 0, y: lungeDistance, duration: 0.8)
            retract.timingMode = .easeInEaseOut
            let done = SKAction.run { [weak self] in
                self?.hasLunged = false
                self?.startSwaying()
            }
            run(SKAction.sequence([drop, hold, retract, done]))
        }
    }

    func updateVisuals(currentCeilingY: CGFloat) {
        anchorCeilingY = currentCeilingY
        updateWebLine()
    }

    private func updateWebLine() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: anchorCeilingY - position.y))
        path.addLine(to: .zero)
        webLine.path = path
    }
}
