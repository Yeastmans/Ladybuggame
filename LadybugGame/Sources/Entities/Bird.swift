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

    /// Steep dive at player, then pull up and exit
    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, groundY: CGFloat, duration: TimeInterval) {
        xScale = -abs(xScale)

        let diveTargetX = ladybugX + CGFloat.random(in: -15...15)
        let diveTargetY = targetY

        // Phase 1: Dive — steep curve, accelerating down
        let divePath = UIBezierPath()
        divePath.move(to: .zero)
        let diveDx = diveTargetX - position.x
        let diveDy = diveTargetY - position.y
        // Control point near top-center: bird drops almost straight down first, then arcs toward player
        divePath.addQuadCurve(to: CGPoint(x: diveDx, y: diveDy),
                              controlPoint: CGPoint(x: diveDx * 0.12, y: diveDy * 0.7))
        let dive = SKAction.follow(divePath.cgPath, asOffset: true, orientToPath: false, duration: duration * 0.55)
        dive.timingMode = .easeIn

        // Phase 2: Pull up — fast sweep upward and left off screen
        let pullPath = UIBezierPath()
        pullPath.move(to: .zero)
        let exitDx = -sceneWidth * 0.4
        let exitDy = -diveDy * 0.7 // Go back up most of the dive height
        pullPath.addQuadCurve(to: CGPoint(x: exitDx, y: exitDy),
                              controlPoint: CGPoint(x: exitDx * 0.25, y: -20))
        let pull = SKAction.follow(pullPath.cgPath, asOffset: true, orientToPath: false, duration: duration * 0.45)
        pull.timingMode = .easeOut

        run(SKAction.sequence([dive, pull, SKAction.removeFromParent()]))
    }
}
