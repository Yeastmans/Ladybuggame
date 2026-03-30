import SpriteKit
import UIKit

class BiomeSwooper: SKSpriteNode {

    let biomeName: String

    init(textures: [SKTexture], biomeName: String) {
        self.biomeName = biomeName
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
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.6, height: size.height * 0.4))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    /// Dive from top-right toward player near ground, pull up sharply, exit left
    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, groundY: CGFloat, duration: TimeInterval) {
        xScale = -abs(xScale)

        let diveTargetX = ladybugX + CGFloat.random(in: -20...20)
        let diveTargetY = targetY
        let diveDx = diveTargetX - position.x
        let diveDy = diveTargetY - position.y

        let exitX: CGFloat = -100
        let exitY = position.y * 0.8
        let pullDx = exitX - diveTargetX
        let pullDy = exitY - diveTargetY

        let path = UIBezierPath()
        path.move(to: .zero)
        path.addQuadCurve(to: CGPoint(x: diveDx, y: diveDy),
                          controlPoint: CGPoint(x: diveDx * 0.3, y: diveDy * 0.85))
        path.addQuadCurve(to: CGPoint(x: diveDx + pullDx, y: diveDy + pullDy),
                          controlPoint: CGPoint(x: diveDx + pullDx * 0.3, y: diveDy - 15))

        let follow = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, duration: duration)
        run(SKAction.sequence([follow, SKAction.removeFromParent()]))
    }
}
