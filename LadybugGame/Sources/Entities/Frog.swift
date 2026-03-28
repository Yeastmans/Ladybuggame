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

        let mouthX = size.width * 0.45
        let mouthY = size.height * 0.1

        var dx = sceneTarget.x - position.x - mouthX
        var dy = sceneTarget.y - position.y - mouthY

        // Never aim downward — clamp dy to 0 or above
        if dy < 0 { dy = 0 }

        // If target is directly above, add slight horizontal
        if abs(dx) < 5 { dx = 20 }

        let rawDist = hypot(dx, dy)
        guard rawDist > 5 else { return }
        let nx = dx / rawDist
        let ny = dy / rawDist

        // Tongue length — stop at max or where it would hit ground
        var tongueLen = min(rawDist, 120.0)

        // Check if tongue tip would go below ground
        let tipSceneY = position.y + mouthY + ny * tongueLen
        if tipSceneY < groundY {
            // Shorten tongue to stop at ground
            let availableY = position.y + mouthY - groundY
            if ny < -0.01 {
                tongueLen = min(tongueLen, abs(availableY / ny))
            }
        }

        let tipX = mouthX + nx * tongueLen
        let tipY = mouthY + ny * tongueLen

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
