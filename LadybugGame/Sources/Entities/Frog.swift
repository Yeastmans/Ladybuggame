import SpriteKit

class Frog: SKSpriteNode {

    private var tongueNode: SKShapeNode?
    private var hasAttacked = false

    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        // Tongue tip acts as the contact body — created during attack
    }

    /// Shoot tongue toward a target point
    func attackToward(_ target: CGPoint) {
        guard !hasAttacked else { return }
        hasAttacked = true

        let dx = target.x - position.x
        let dy = target.y - position.y
        let dist = min(hypot(dx, dy), 120) // Max tongue length
        guard dist > 10 else { return }
        let nx = dx / hypot(dx, dy)
        let ny = dy / hypot(dx, dy)
        let tipX = nx * dist
        let tipY = ny * dist

        // Tongue line
        let tongue = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width * 0.4, y: size.height * 0.3))
        path.addLine(to: CGPoint(x: tipX, y: tipY))
        tongue.path = path.cgPath
        tongue.strokeColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tongue.lineWidth = 2.5
        tongue.zPosition = -1
        addChild(tongue)
        tongueNode = tongue

        // Tongue tip (hitbox)
        let tip = SKShapeNode(circleOfRadius: 5)
        tip.fillColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tip.strokeColor = .clear
        tip.position = CGPoint(x: tipX, y: tipY)
        tip.zPosition = -1
        tongue.addChild(tip)

        let tipBody = SKPhysicsBody(circleOfRadius: 5)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = GameScene.PhysicsCategory.bird // Reuse bird category for damage
        tipBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        tip.physicsBody = tipBody

        // Animate: extend then retract
        tongue.alpha = 0
        let extend = SKAction.fadeIn(withDuration: 0.08)
        let hold = SKAction.wait(forDuration: 0.25)
        let retract = SKAction.fadeOut(withDuration: 0.12)
        let remove = SKAction.run { [weak self] in
            tongue.removeFromParent()
            self?.tongueNode = nil
        }
        tongue.run(SKAction.sequence([extend, hold, retract, remove]))
    }
}
