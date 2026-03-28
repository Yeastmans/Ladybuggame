import SpriteKit
import UIKit

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

    /// Shoot tongue toward a target in SCENE coordinates
    func attackToward(sceneTarget: CGPoint) {
        guard !hasAttacked else { return }
        hasAttacked = true

        // Convert scene target to local coordinates
        let localTarget = CGPoint(x: sceneTarget.x - position.x, y: sceneTarget.y - position.y)

        // Tongue starts from mouth (right side of frog, upper area)
        let mouthX = size.width * 0.45
        let mouthY = size.height * 0.1

        let dx = localTarget.x - mouthX
        let dy = localTarget.y - mouthY
        let dist = min(hypot(dx, dy), 120)
        guard dist > 10 else { return }
        let nx = dx / hypot(dx, dy)
        let ny = dy / hypot(dx, dy)
        let tipX = mouthX + nx * dist
        let tipY = mouthY + ny * dist

        let tongue = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: mouthX, y: mouthY))
        path.addLine(to: CGPoint(x: tipX, y: tipY))
        tongue.path = path.cgPath
        tongue.strokeColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tongue.lineWidth = 2.5
        tongue.zPosition = -1
        addChild(tongue)
        tongueNode = tongue

        // Tip hitbox
        let tip = SKShapeNode(circleOfRadius: 6)
        tip.fillColor = SKColor(red: 0.95, green: 0.35, blue: 0.40, alpha: 1.0)
        tip.strokeColor = .clear
        tip.position = CGPoint(x: tipX, y: tipY)
        let tipBody = SKPhysicsBody(circleOfRadius: 6)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = GameScene.PhysicsCategory.bird
        tipBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        tip.physicsBody = tipBody
        tongue.addChild(tip)

        // Extend, hold, retract
        tongue.setScale(0.01)
        let extend = SKAction.scale(to: 1.0, duration: 0.08)
        let hold = SKAction.wait(forDuration: 0.2)
        let retract = SKAction.scale(to: 0.01, duration: 0.10)
        let remove = SKAction.run { [weak self] in
            tongue.removeFromParent()
            self?.tongueNode = nil
        }
        tongue.run(SKAction.sequence([extend, hold, retract, remove]))
    }
}
