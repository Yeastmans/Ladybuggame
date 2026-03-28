import SpriteKit
import UIKit

class Ladybug: SKSpriteNode {

    private let walkTexture: SKTexture
    private let glideTexture: SKTexture
    private let blinkTexture: SKTexture
    private let walkSize: CGSize
    private let glideSize: CGSize

    private(set) var isGliding = false
    private var jumpVelocity: CGFloat = 0
    private let gravity: CGFloat = -600
    private var shadowNode: SKShapeNode?

    init(walkTexture: SKTexture, glideTexture: SKTexture, blinkTexture: SKTexture) {
        self.walkTexture = walkTexture
        self.glideTexture = glideTexture
        self.blinkTexture = blinkTexture
        self.walkSize = walkTexture.size()
        self.glideSize = glideTexture.size()
        super.init(texture: walkTexture, color: .clear, size: walkTexture.size())
        zPosition = 5

        // Ground shadow
        let shadow = SKShapeNode(ellipseOf: CGSize(width: walkSize.width * 0.6, height: walkSize.height * 0.2))
        shadow.fillColor = SKColor(white: 0.0, alpha: 0.18)
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        shadow.position = CGPoint(x: 0, y: -walkSize.height * 0.4)
        addChild(shadow)
        self.shadowNode = shadow

        startBlinking()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics(category: UInt32, contact: UInt32, collision: UInt32) {
        let body = SKPhysicsBody(circleOfRadius: walkSize.width / 2 * 0.8)
        body.isDynamic = true
        body.categoryBitMask = category
        body.contactTestBitMask = contact
        body.collisionBitMask = collision
        body.allowsRotation = false
        body.linearDamping = 2.0
        physicsBody = body
    }

    // MARK: - Blinking

    private func startBlinking() {
        let wait = SKAction.wait(forDuration: 3.0, withRange: 3.0) // Blink every 1.5–4.5s
        let close = SKAction.run { [weak self] in
            guard let self = self, !self.isGliding else { return }
            self.texture = self.blinkTexture
        }
        let holdClosed = SKAction.wait(forDuration: 0.12)
        let open = SKAction.run { [weak self] in
            guard let self = self, !self.isGliding else { return }
            self.texture = self.walkTexture
        }
        // Sometimes double-blink
        let maybeBlink = SKAction.run { [weak self] in
            guard let self = self, !self.isGliding else { return }
            if Bool.random() {
                let doubleBlink = SKAction.sequence([
                    SKAction.wait(forDuration: 0.18),
                    SKAction.run { self.texture = self.blinkTexture },
                    SKAction.wait(forDuration: 0.10),
                    SKAction.run { self.texture = self.walkTexture }
                ])
                self.run(doubleBlink)
            }
        }
        let blinkSequence = SKAction.sequence([wait, close, holdClosed, open, maybeBlink])
        run(SKAction.repeatForever(blinkSequence), withKey: "blink")
    }

    // MARK: - Jump / Glide

    func jump() {
        guard !isGliding else { return }
        isGliding = true
        jumpVelocity = 300

        // Unfurl wings animation
        let unfurl = SKAction.group([
            SKAction.setTexture(glideTexture, resize: true),
            SKAction.scale(to: 1.3, duration: 0.2)
        ])
        run(unfurl, withKey: "unfurl")
    }

    func updateJump(dt: TimeInterval) {
        guard isGliding else { return }

        jumpVelocity += gravity * CGFloat(dt)

        // Shadow moves down and spreads as we go higher
        let heightFactor = max(0, jumpVelocity / 300)
        shadowNode?.position.y = -(walkSize.height * 0.4) - (heightFactor * 20)
        shadowNode?.setScale(1.0 + heightFactor * 0.5)
        shadowNode?.alpha = CGFloat(0.18 - heightFactor * 0.08)

        if jumpVelocity <= 0 {
            land()
        }
    }

    private func land() {
        isGliding = false
        jumpVelocity = 0

        let fold = SKAction.group([
            SKAction.setTexture(walkTexture, resize: true),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        run(fold, withKey: "unfurl")

        // Reset shadow
        shadowNode?.position.y = -(walkSize.height * 0.4)
        shadowNode?.setScale(1.0)
        shadowNode?.alpha = 0.18

        // Landing dust effect using small shape nodes instead of emitter
        if let parent = self.parent {
            for _ in 0..<6 {
                let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3.0))
                particle.fillColor = SKColor(red: 0.60, green: 0.55, blue: 0.40, alpha: 0.5)
                particle.strokeColor = .clear
                particle.position = position
                particle.zPosition = 1
                parent.addChild(particle)

                let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
                let dist = CGFloat.random(in: 15...30)
                let endPos = CGPoint(x: position.x + cos(angle) * dist,
                                     y: position.y + sin(angle) * dist)
                let move = SKAction.move(to: endPos, duration: 0.3)
                let fade = SKAction.fadeOut(withDuration: 0.3)
                let group = SKAction.group([move, fade])
                particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
            }
        }
    }

    func moveToward(_ target: CGPoint, speed: CGFloat, dt: TimeInterval) {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = hypot(dx, dy)

        guard distance > 4 else { return }

        let actualSpeed = isGliding ? speed * 1.4 : speed
        let moveSpeed = min(actualSpeed, distance / CGFloat(dt))
        let vx = (dx / distance) * moveSpeed
        let vy = (dy / distance) * moveSpeed
        physicsBody?.velocity = CGVector(dx: vx, dy: vy)

        let angle = atan2(dy, dx) - .pi / 2
        zRotation = angle
    }

    func pulse() {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        run(SKAction.sequence([scaleUp, scaleDown]))
    }

    func flash() {
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        run(SKAction.repeat(blink, count: 3))
    }
}
