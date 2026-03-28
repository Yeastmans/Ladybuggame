import SpriteKit
import UIKit

class Bird: SKSpriteNode {

    init(textures: [SKTexture]) {
        let first = textures.first ?? SKTexture()
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 12

        if textures.count >= 2 {
            let flap = SKAction.animate(with: textures, timePerFrame: 0.10)
            run(SKAction.repeatForever(flap), withKey: "flap")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: size.height * 0.6))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    /// Aggressive swoop — dives straight at ladybug position then exits
    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, duration: TimeInterval) {
        xScale = -abs(xScale)

        let diveX = ladybugX - position.x
        let diveY = targetY - position.y
        let exitX = -size.width * 3 - position.x

        // Tighter curve — control point is BELOW the target for a steep dive
        let path = UIBezierPath()
        path.move(to: .zero)
        // Dive point (at ladybug)
        path.addLine(to: CGPoint(x: diveX, y: diveY))
        // Exit low-left
        path.addQuadCurve(to: CGPoint(x: exitX, y: diveY + 30),
                          controlPoint: CGPoint(x: diveX - 80, y: diveY - 20))

        let followPath = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, duration: duration)
        followPath.timingMode = .easeIn
        run(SKAction.sequence([followPath, SKAction.removeFromParent()]))
    }
}
