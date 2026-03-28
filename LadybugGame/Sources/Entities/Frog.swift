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

    func attackToward(playerPos: CGPoint) {
        guard !hasAttacked else { return }
        hasAttacked = true

        // Convert player position to frog's local coordinates
        // This handles xScale flipping automatically
        guard let scene = parent else { return }
        let localTarget = self.convert(playerPos, from: scene)

        // Mouth is near the front of the face
        let mouthLocal = CGPoint(x: size.width * 0.40, y: size.height * 0.15)

        var dx = localTarget.x - mouthLocal.x
        var dy = localTarget.y - mouthLocal.y
        if dy < -5 { dy = 0 }
        if abs(dx) < 3 { dx = 20 }

        let dist = hypot(dx, dy)
        guard dist > 5 else { return }
        let tongueLen = min(dist, 100.0)
        let nx = dx / dist
        let ny = dy / dist

        let tipLocal = CGPoint(x: mouthLocal.x + nx * tongueLen,
                                y: mouthLocal.y + ny * tongueLen)

        // Tongue as child of frog — moves and scrolls with it
        let tongue = SKShapeNode()
        tongue.strokeColor = SKColor(red: 0.90, green: 0.30, blue: 0.35, alpha: 1.0)
        tongue.lineWidth = 3
        tongue.zPosition = -1
        addChild(tongue)

        // Tip node with hitbox (also child of tongue/frog)
        let tipNode = SKNode()
        let tipBody = SKPhysicsBody(circleOfRadius: 7)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = GameScene.PhysicsCategory.bird
        tipBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug

        // Tip visual
        let tipDot = SKShapeNode(circleOfRadius: 6)
        tipDot.fillColor = SKColor(red: 0.95, green: 0.40, blue: 0.45, alpha: 1.0)
        tipDot.strokeColor = .clear
        tipNode.addChild(tipDot)
        addChild(tipNode)

        let extendDur: TimeInterval = 0.12
        let holdDur: TimeInterval = 0.20
        let retractDur: TimeInterval = 0.10

        let extend = SKAction.customAction(withDuration: extendDur) { _, elapsed in
            let p = min(1.0, elapsed / extendDur)
            let curX = mouthLocal.x + (tipLocal.x - mouthLocal.x) * p
            let curY = mouthLocal.y + (tipLocal.y - mouthLocal.y) * p
            let path = UIBezierPath()
            path.move(to: mouthLocal)
            path.addLine(to: CGPoint(x: curX, y: curY))
            tongue.path = path.cgPath
            tipNode.position = CGPoint(x: curX, y: curY)
            if p > 0.85 { tipNode.physicsBody = tipBody }
        }

        let hold = SKAction.wait(forDuration: holdDur)

        let retract = SKAction.customAction(withDuration: retractDur) { _, elapsed in
            let p = max(0, 1.0 - elapsed / retractDur)
            let curX = mouthLocal.x + (tipLocal.x - mouthLocal.x) * p
            let curY = mouthLocal.y + (tipLocal.y - mouthLocal.y) * p
            let path = UIBezierPath()
            path.move(to: mouthLocal)
            path.addLine(to: CGPoint(x: curX, y: curY))
            tongue.path = path.cgPath
            tipNode.position = CGPoint(x: curX, y: curY)
            tipNode.physicsBody = nil
        }

        let cleanup = SKAction.run {
            tongue.removeFromParent()
            tipNode.removeFromParent()
        }

        tongue.run(SKAction.sequence([extend, hold, retract, cleanup]))
    }
}
