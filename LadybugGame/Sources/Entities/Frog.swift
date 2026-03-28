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

    func attackToward(sceneTarget: CGPoint, groundY: CGFloat) {
        guard !hasAttacked else { return }
        hasAttacked = true

        // Direction from frog to target
        var dx = sceneTarget.x - position.x
        var dy = sceneTarget.y - position.y
        if dy < 0 { dy = 0 } // Never aim down
        if abs(dx) < 5 { dx = xScale > 0 ? 30 : -30 }

        let dist = hypot(dx, dy)
        guard dist > 5 else { return }
        let tongueLen = min(dist, 100.0)
        let nx = dx / dist
        let ny = dy / dist

        // Mouth position in frog's local coords
        let mouthLocalX = xScale > 0 ? size.width * 0.40 : -size.width * 0.40
        let mouthLocalY = size.height * 0.10

        // Tip position relative to mouth
        let tipOffsetX = nx * tongueLen
        let tipOffsetY = max(0, ny * tongueLen) // Clamp above ground relative

        // Tongue line (child of frog so it moves with frog)
        let tongue = SKShapeNode()
        let tipBody = SKPhysicsBody(circleOfRadius: 7)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = GameScene.PhysicsCategory.bird
        tipBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug

        // Animate: grow the tongue outward then retract
        // Phase 1: extend
        let extend = SKAction.customAction(withDuration: 0.10) { [weak self] _, elapsed in
            guard let self = self else { return }
            let progress = elapsed / 0.10
            let curTipX = mouthLocalX + tipOffsetX * progress
            let curTipY = mouthLocalY + tipOffsetY * progress

            let path = UIBezierPath()
            path.move(to: CGPoint(x: mouthLocalX, y: mouthLocalY))
            path.addLine(to: CGPoint(x: curTipX, y: curTipY))
            tongue.path = path.cgPath

            // Move physics body to tip
            tongue.position = .zero
            tongue.removeAllChildren()
            let tipNode = SKNode()
            tipNode.position = CGPoint(x: curTipX, y: curTipY)
            if progress > 0.8 { tipNode.physicsBody = tipBody }
            tongue.addChild(tipNode)
        }

        let hold = SKAction.wait(forDuration: 0.18)

        // Phase 2: retract
        let retract = SKAction.customAction(withDuration: 0.08) { _, elapsed in
            let progress = 1.0 - elapsed / 0.08
            let curTipX = mouthLocalX + tipOffsetX * progress
            let curTipY = mouthLocalY + tipOffsetY * progress

            let path = UIBezierPath()
            path.move(to: CGPoint(x: mouthLocalX, y: mouthLocalY))
            path.addLine(to: CGPoint(x: curTipX, y: curTipY))
            tongue.path = path.cgPath
        }

        let remove = SKAction.run {
            tongue.removeFromParent()
        }

        tongue.strokeColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tongue.lineWidth = 2.5
        tongue.zPosition = -1
        addChild(tongue)

        tongue.run(SKAction.sequence([extend, hold, retract, remove]))
    }
}
