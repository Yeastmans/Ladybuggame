import SpriteKit

/// Rare power-up that drifts down from the sky (appears after the first boss).
/// Pop it to ride inside a bubble: bugs are still eaten on touch, and enemies
/// that hit the bubble are knocked out — flipped upside down and dropped
/// off the bottom of the screen.
class Bubble: SKSpriteNode {

    init() {
        let tex = TextureGenerator.generateBubblePowerupTexture(size: CGSize(width: 36, height: 36))
        super.init(texture: tex, color: .clear, size: tex.size())
        zPosition = 7
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

    /// Slow downward drift with a gentle sway, wobbling like a soap bubble.
    /// Pops (disappears) if it reaches the ground uncollected.
    func startDrifting(floorY: CGFloat) {
        let sway = SKAction.sequence([
            SKAction.moveBy(x: 16, y: -20, duration: 1.1),
            SKAction.moveBy(x: -16, y: -20, duration: 1.1),
        ])
        run(SKAction.repeatForever(sway), withKey: "drift")
        let wobble = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.45),
            SKAction.scale(to: 0.96, duration: 0.45),
        ])
        run(SKAction.repeatForever(wobble), withKey: "wobble")
        let floorCheck = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.position.y <= floorY + self.size.height / 2 {
                self.removeAllActions()
                self.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.scale(to: 1.3, duration: 0.12),
                        SKAction.fadeOut(withDuration: 0.12),
                    ]),
                    SKAction.removeFromParent(),
                ]))
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.4), floorCheck])), withKey: "floorCheck")
    }
}
