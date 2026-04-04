import SpriteKit

/// Cave hazard: warning shadow → fall from ceiling → stay as obstacle.
class FallingRock: SKSpriteNode {

    enum State { case warning, falling, landed }
    private(set) var state: State = .warning
    private var warningTimer: TimeInterval = 0
    private let warningDuration: TimeInterval = 0.8
    var shadow: SKShapeNode?
    private var targetGroundY: CGFloat

    init(rockSize: CGSize, groundY: CGFloat, ceilingY: CGFloat) {
        self.targetGroundY = groundY
        let texture = TextureGenerator.generateFallingRockTexture(size: rockSize)
        super.init(texture: texture, color: .clear, size: rockSize)
        zPosition = 5
        alpha = 0
        position.y = ceilingY
    }

    required init?(coder: NSCoder) { fatalError() }

    func createWarningShadow(groundY: CGFloat) -> SKShapeNode {
        let s = SKShapeNode(ellipseOf: CGSize(width: size.width * 1.2, height: 6))
        s.fillColor = SKColor(white: 0, alpha: 0.3)
        s.strokeColor = .clear
        s.position = CGPoint(x: position.x, y: groundY + 2)
        s.zPosition = 1
        s.name = "rockShadow"
        s.setScale(0.3)
        s.run(SKAction.scale(to: 1.0, duration: warningDuration))
        shadow = s
        return s
    }

    func update(dt: TimeInterval) {
        guard state == .warning else { return }
        warningTimer += dt
        if warningTimer >= warningDuration {
            state = .falling
            alpha = 1
            let fallDist = position.y - targetGroundY - size.height / 2
            let fallDuration = max(0.15, Double(fallDist / 600))
            let fall = SKAction.moveTo(y: targetGroundY + size.height / 2, duration: fallDuration)
            fall.timingMode = .easeIn
            run(SKAction.sequence([fall, SKAction.run { [weak self] in self?.land() }]))
        }
    }

    private func land() {
        state = .landed
        shadow?.removeFromParent()
        shadow = nil
        SoundManager.shared.play("crunch")

        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: size.height * 0.7))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }
}
