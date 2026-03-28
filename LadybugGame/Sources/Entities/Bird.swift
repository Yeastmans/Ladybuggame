import SpriteKit

class Bird: SKSpriteNode {

    init(textures: [SKTexture]) {
        let first = textures.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 12

        if textures.count >= 2 {
            let flap = SKAction.animate(with: textures, timePerFrame: 0.12)
            run(SKAction.repeatForever(flap), withKey: "flap")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.6, height: size.height * 0.5))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    /// Swoop: fly in from right at altitude, dive to targetY at the ladybug's X, then fly away left
    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, duration: TimeInterval) {
        // Flip sprite to face left
        xScale = -abs(xScale)

        let enterX = sceneWidth + size.width
        let exitX: CGFloat = -size.width * 2

        // Path: enter high → dive at ladybug X → exit low-left
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0)) // relative start
        let diveX = ladybugX - position.x
        let diveY = targetY - position.y
        path.addQuadCurve(to: CGPoint(x: exitX - position.x, y: diveY - 20),
                          controlPoint: CGPoint(x: diveX, y: diveY))

        let followPath = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, duration: duration)
        followPath.timingMode = .easeIn
        run(SKAction.sequence([followPath, SKAction.removeFromParent()]))
    }
}
