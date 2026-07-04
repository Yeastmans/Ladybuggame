import SpriteKit

/// Rare power-up that drifts down from the sky (appears after the second boss).
/// Collect it to become a bug vacuum: for a few seconds every snack on screen
/// gets pulled toward the ladybug and gobbled up.
class Vacuum: SKSpriteNode {

    init() {
        let tex = TextureGenerator.generateVacuumTexture(size: CGSize(width: 36, height: 36))
        super.init(texture: tex, color: .clear, size: tex.size())
        zPosition = 7
        // Slow spin so it reads as a swirling vortex
        run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi * 2, duration: 2.5)), withKey: "spin")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.8)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.fruitfly
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    /// Slow downward drift with a gentle sway. Fades out if it reaches the ground.
    func startDrifting(floorY: CGFloat) {
        let sway = SKAction.sequence([
            SKAction.moveBy(x: 14, y: -22, duration: 1.1),
            SKAction.moveBy(x: -14, y: -22, duration: 1.1),
        ])
        run(SKAction.repeatForever(sway), withKey: "drift")
        let floorCheck = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.position.y <= floorY + self.size.height / 2 {
                self.removeAllActions()
                self.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.4), floorCheck])), withKey: "floorCheck")
    }
}
