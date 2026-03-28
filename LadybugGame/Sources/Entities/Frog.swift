import SpriteKit
import UIKit

class Frog: SKSpriteNode {

    private var hasAttacked = false

    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shoot tongue from frog's mouth toward the player position (scene coords)
    func attackToward(playerPos: CGPoint) {
        guard !hasAttacked, let scene = parent else { return }
        hasAttacked = true

        // Frog faces right by default. Mouth is on the right.
        // When xScale < 0, frog faces left, mouth is on the left.
        let facingRight = xScale > 0
        let mouthOffset: CGFloat = facingRight ? size.width * 0.45 : -size.width * 0.45
        let mouthScene = CGPoint(x: position.x + mouthOffset, y: position.y + size.height * 0.15)

        // Direction toward player
        var dx = playerPos.x - mouthScene.x
        var dy = playerPos.y - mouthScene.y
        if dy < -5 { dy = 0 } // Don't aim too far down
        if abs(dx) < 3 { dx = facingRight ? 20 : -20 }

        let dist = hypot(dx, dy)
        guard dist > 5 else { return }
        let tongueLen = min(dist, 100.0)
        let nx = dx / dist
        let ny = dy / dist

        let tipScene = CGPoint(x: mouthScene.x + nx * tongueLen,
                                y: mouthScene.y + ny * tongueLen)

        // Tongue line in scene
        let tongue = SKShapeNode()
        tongue.strokeColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tongue.lineWidth = 3
        tongue.zPosition = 4
        scene.addChild(tongue)

        // Tip with hitbox
        let tip = SKShapeNode(circleOfRadius: 7)
        tip.fillColor = SKColor(red: 0.95, green: 0.40, blue: 0.45, alpha: 1.0)
        tip.strokeColor = .clear
        tip.zPosition = 4
        let tipBody = SKPhysicsBody(circleOfRadius: 7)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = GameScene.PhysicsCategory.bird
        tipBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        scene.addChild(tip)

        // Extend animation
        let extendDur: TimeInterval = 0.12
        let holdDur: TimeInterval = 0.20
        let retractDur: TimeInterval = 0.10

        let extend = SKAction.customAction(withDuration: extendDur) { _, elapsed in
            let p = min(1.0, elapsed / extendDur)
            let curTip = CGPoint(x: mouthScene.x + nx * tongueLen * p,
                                  y: mouthScene.y + ny * tongueLen * p)
            let path = UIBezierPath()
            path.move(to: mouthScene)
            path.addLine(to: curTip)
            tongue.path = path.cgPath
            tip.position = curTip
            if p > 0.9 { tip.physicsBody = tipBody }
        }

        let hold = SKAction.wait(forDuration: holdDur)

        let retract = SKAction.customAction(withDuration: retractDur) { _, elapsed in
            let p = max(0, 1.0 - elapsed / retractDur)
            let curTip = CGPoint(x: mouthScene.x + nx * tongueLen * p,
                                  y: mouthScene.y + ny * tongueLen * p)
            let path = UIBezierPath()
            path.move(to: mouthScene)
            path.addLine(to: curTip)
            tongue.path = path.cgPath
            tip.position = curTip
            tip.physicsBody = nil
        }

        let cleanup = SKAction.run {
            tongue.removeFromParent()
            tip.removeFromParent()
        }

        // Run on the tongue node
        tongue.run(SKAction.sequence([extend, hold, retract, cleanup]))
        tip.run(SKAction.sequence([
            SKAction.wait(forDuration: extendDur + holdDur + retractDur),
            SKAction.removeFromParent()
        ]))
    }
}
