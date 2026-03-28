import SpriteKit

class Aphid: SKSpriteNode {

    private var skitterTextures: [SKTexture] = []

    init(textures: [SKTexture]) {
        self.skitterTextures = textures
        let first = textures.first!
        super.init(texture: first, color: .clear, size: first.size())
        zPosition = 3
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics(category: UInt32, contact: UInt32, collision: UInt32) {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.8)
        body.isDynamic = true
        body.categoryBitMask = category
        body.contactTestBitMask = contact
        body.collisionBitMask = collision
        body.allowsRotation = false
        body.linearDamping = 3.0
        physicsBody = body
    }

    func startWandering(in bounds: CGRect) {
        // Skitter leg animation (runs continuously)
        if skitterTextures.count >= 2 {
            let skitterAction = SKAction.animate(with: skitterTextures, timePerFrame: 0.10)
            run(SKAction.repeatForever(skitterAction), withKey: "skitter")
        }

        // Wandering movement with pauses
        let wander = SKAction.run { [weak self] in
            guard let self = self else { return }
            let margin: CGFloat = 30
            let xMax = max(margin, bounds.width - margin)
            let yMax = max(margin, bounds.height - margin)
            let target = CGPoint(
                x: CGFloat.random(in: margin...xMax),
                y: CGFloat.random(in: margin...yMax)
            )
            let dx = target.x - self.position.x
            let dy = target.y - self.position.y
            let distance = hypot(dx, dy)

            // Rotate to face direction
            let angle = atan2(dy, dx) - .pi / 2
            let rotate = SKAction.rotate(toAngle: angle, duration: 0.15, shortestUnitArc: true)

            let duration = TimeInterval(distance / 30)
            let move = SKAction.move(to: target, duration: duration)
            move.timingMode = .easeInEaseOut

            // Speed up skitter when moving, pause when idle
            let speedUp = SKAction.run { [weak self] in
                self?.removeAction(forKey: "skitter")
                if let textures = self?.skitterTextures, textures.count >= 2 {
                    let fast = SKAction.animate(with: textures, timePerFrame: 0.06)
                    self?.run(SKAction.repeatForever(fast), withKey: "skitter")
                }
            }
            let slowDown = SKAction.run { [weak self] in
                self?.removeAction(forKey: "skitter")
                // Stop on first frame when idle
                if let tex = self?.skitterTextures.first {
                    self?.texture = tex
                }
            }

            self.run(SKAction.sequence([speedUp, rotate, move, slowDown]), withKey: "wanderMove")
        }
        let wait = SKAction.wait(forDuration: 1.5, withRange: 2.0)
        let sequence = SKAction.sequence([wander, wait])
        run(SKAction.repeatForever(sequence), withKey: "wander")
    }
}
