import SpriteKit
import UIKit

/// Flying enemy that swoops (hawk, owl, toucan) — replaces Bird in non-meadow biomes
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

    func swoopAcross(sceneWidth: CGFloat, ladybugX: CGFloat, targetY: CGFloat, duration: TimeInterval) {
        xScale = -abs(xScale)

        let exitX = -size.width * 3 - position.x
        let diveX = ladybugX - position.x
        let diveY = targetY - position.y

        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: diveX, y: diveY))
        path.addQuadCurve(to: CGPoint(x: exitX, y: diveY + 30),
                          controlPoint: CGPoint(x: diveX - 80, y: diveY - 20))

        let follow = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, duration: duration)
        follow.timingMode = .easeIn
        run(SKAction.sequence([follow, SKAction.removeFromParent()]))
    }
}
