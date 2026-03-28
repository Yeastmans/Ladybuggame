import SpriteKit

class Bird: SKSpriteNode {

    private var flapTextures: [SKTexture] = []

    init(textures: [SKTexture]) {
        self.flapTextures = textures
        let first = textures.first!
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 10
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics(category: UInt32, contact: UInt32, collision: UInt32) {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: size.height * 0.5))
        body.isDynamic = true
        body.categoryBitMask = category
        body.contactTestBitMask = contact
        body.collisionBitMask = collision
        body.allowsRotation = false
        physicsBody = body
    }

    func swoop(to target: CGPoint, duration: TimeInterval) {
        // Face movement direction
        let dx = target.x - position.x
        let dy = target.y - position.y
        let angle = atan2(dy, dx) - .pi / 2
        zRotation = angle

        // Wing flap animation using texture frames
        if flapTextures.count >= 2 {
            let flapAction = SKAction.animate(with: flapTextures, timePerFrame: 0.12)
            run(SKAction.repeatForever(flapAction), withKey: "flap")
        }

        // Shadow beneath
        let shadow = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.5, height: size.height * 0.2))
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.15)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -size.height * 0.6)
        shadow.zPosition = -1
        addChild(shadow)

        // Move and remove
        let move = SKAction.move(to: target, duration: duration)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([move, remove]))
    }
}
