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

    func attackToward(sceneTarget: CGPoint, groundY: CGFloat) {
        guard !hasAttacked else { return }
        hasAttacked = true

        // Direction from frog center to target
        let dirX = sceneTarget.x - position.x
        let dirY = sceneTarget.y - position.y

        // Never aim down
        let aimY = max(dirY, 0)
        let aimX = dirX

        let dist = hypot(aimX, aimY)
        guard dist > 5 else { return }

        let tongueLen = min(dist, 110.0)
        let nx = aimX / dist
        let ny = aimY / dist

        // Tongue in scene coordinates (add as child of scene parent, not frog)
        guard let parentNode = self.parent else { return }

        let startPt = CGPoint(x: position.x, y: position.y + size.height * 0.15)
        let endPt = CGPoint(x: startPt.x + nx * tongueLen, y: max(groundY + 2, startPt.y + ny * tongueLen))

        let tongue = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: startPt)
        path.addLine(to: endPt)
        tongue.path = path.cgPath
        tongue.strokeColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tongue.lineWidth = 2.5
        tongue.zPosition = 6
        parentNode.addChild(tongue)
        tongueNode = tongue

        // Tip with hitbox
        let tip = SKShapeNode(circleOfRadius: 7)
        tip.fillColor = SKColor(red: 0.95, green: 0.35, blue: 0.40, alpha: 1.0)
        tip.strokeColor = .clear
        tip.position = endPt
        tip.zPosition = 6
        let tipBody = SKPhysicsBody(circleOfRadius: 7)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = GameScene.PhysicsCategory.bird
        tipBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        tip.physicsBody = tipBody
        parentNode.addChild(tip)

        // Animate: appear, hold, retract
        tongue.alpha = 0
        tip.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.06)
        let hold = SKAction.wait(forDuration: 0.25)
        let fadeOut = SKAction.fadeOut(withDuration: 0.10)
        let removeTongue = SKAction.removeFromParent()
        tongue.run(SKAction.sequence([fadeIn, hold, fadeOut, removeTongue]))
        tip.run(SKAction.sequence([fadeIn, hold, fadeOut, SKAction.removeFromParent()]))
    }
}
