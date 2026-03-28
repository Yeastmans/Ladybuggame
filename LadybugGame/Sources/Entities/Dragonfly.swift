import SpriteKit

class Dragonfly: SKSpriteNode {

    init(textures: [SKTexture]) {
        let first = textures.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 11

        if textures.count >= 2 {
            let flap = SKAction.animate(with: textures, timePerFrame: 0.06)
            run(SKAction.repeatForever(flap), withKey: "flap")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.6, height: size.height * 0.4))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird // damages like a bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startHovering(minY: CGFloat, maxY: CGFloat) {
        // Bob up and down while drifting slightly
        let hover = SKAction.run { [weak self] in
            guard let self = self else { return }
            let targetY = CGFloat.random(in: minY...maxY)
            let dy = targetY - self.position.y
            let move = SKAction.moveBy(x: CGFloat.random(in: -10...10), y: dy, duration: Double.random(in: 0.8...1.5))
            move.timingMode = .easeInEaseOut
            self.run(move, withKey: "hoverMove")
        }
        let wait = SKAction.wait(forDuration: 0.8, withRange: 0.6)
        run(SKAction.repeatForever(SKAction.sequence([hover, wait])), withKey: "hover")
    }
}
