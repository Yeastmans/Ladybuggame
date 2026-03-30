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

    /// Dive from top-right toward player near ground, pull up sharply, exit left
    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, groundY: CGFloat, duration: TimeInterval) {
        // Bird starts top-right, facing left
        xScale = -abs(xScale)

        // Phase 1: Steep diagonal dive toward player at ground level
        let diveTargetX = ladybugX + CGFloat.random(in: -20...20)
        let diveTargetY = targetY
        let diveDx = diveTargetX - position.x
        let diveDy = diveTargetY - position.y

        // Phase 2: Sharp pull-up and exit off left
        let exitX: CGFloat = -100
        let exitY = position.y * 0.8  // Exit high but not quite as high as entry
        let pullDx = exitX - diveTargetX
        let pullDy = exitY - diveTargetY

        let path = UIBezierPath()
        path.move(to: .zero)
        // Steep dive — control point pulls the curve to be nearly vertical at first, then curves toward target
        path.addQuadCurve(to: CGPoint(x: diveDx, y: diveDy),
                          controlPoint: CGPoint(x: diveDx * 0.3, y: diveDy * 0.85))
        // Sharp pull-up — control point keeps it low briefly then sweeps up
        path.addQuadCurve(to: CGPoint(x: diveDx + pullDx, y: diveDy + pullDy),
                          controlPoint: CGPoint(x: diveDx + pullDx * 0.3, y: diveDy - 15))

        let follow = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, duration: duration)
        run(SKAction.sequence([follow, SKAction.removeFromParent()]))
    }
}
