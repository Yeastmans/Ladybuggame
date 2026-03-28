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

    /// Dive at player, pull up near ground, exit high off screen
    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, startY: CGFloat, duration: TimeInterval) {
        xScale = -abs(xScale)

        let diveX = ladybugX - position.x
        let diveY = targetY - position.y
        let pullUpY = startY - position.y // Go back up to start height
        let exitX = -size.width * 2 - position.x

        let path = UIBezierPath()
        path.move(to: .zero)
        // Dive down toward player
        path.addQuadCurve(to: CGPoint(x: diveX, y: diveY),
                          controlPoint: CGPoint(x: diveX * 0.6, y: diveY * 0.3))
        // Pull up sharply and exit high
        path.addQuadCurve(to: CGPoint(x: exitX, y: pullUpY),
                          controlPoint: CGPoint(x: diveX + exitX * 0.15, y: diveY - 40))

        let follow = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, duration: duration)
        run(SKAction.sequence([follow, SKAction.removeFromParent()]))
    }
}
