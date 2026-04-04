import SpriteKit

class Ladybug: SKSpriteNode {

    private let walkTexture: SKTexture
    private let blinkTexture: SKTexture
    private let flyFrames: [SKTexture]

    private(set) var isFlying = false
    private(set) var isOnGround = true
    var isInsideLog = false
    var velocityY: CGFloat = 0
    var targetY: CGFloat?
    private var invincibleTimer: TimeInterval = 0
    private var walkBobTime: CGFloat = 0
    private var walkLegTime: CGFloat = 0

    let gravity: CGFloat = -450
    let followStrength: CGFloat = 1.6
    let damping: CGFloat = 0.96
    let maxVelocityY: CGFloat = 220

    var isInvincible: Bool { invincibleTimer > 0 }
    var isSheltered: Bool { isInsideLog && isOnGround }

    init(walkTexture: SKTexture, blinkTexture: SKTexture, flyFrames: [SKTexture]) {
        self.walkTexture = walkTexture
        self.blinkTexture = blinkTexture
        self.flyFrames = flyFrames
        super.init(texture: walkTexture, color: .clear, size: walkTexture.size())
        zPosition = 10
        startBlinking()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func startBlinking() {
        let wait = SKAction.wait(forDuration: 3.0, withRange: 3.0)
        let close = SKAction.run { [weak self] in
            guard let self = self, self.isOnGround else { return }
            self.texture = self.blinkTexture
        }
        let holdClosed = SKAction.wait(forDuration: 0.12)
        let open = SKAction.run { [weak self] in
            guard let self = self, self.isOnGround else { return }
            self.texture = self.walkTexture
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, close, holdClosed, open])), withKey: "blink")
    }

    private func startFlapAnimation() {
        guard flyFrames.count >= 2 else { return }
        removeAction(forKey: "flap")
        let flap = SKAction.animate(with: flyFrames, timePerFrame: 0.08)
        run(SKAction.repeatForever(flap), withKey: "flap")
    }

    private func stopFlapAnimation() {
        removeAction(forKey: "flap")
        texture = walkTexture
    }

    func updatePhysics(dt: TimeInterval, groundY: CGFloat, ceilingY: CGFloat) {
        if invincibleTimer > 0 { invincibleTimer -= dt }

        if let ty = targetY, !isInsideLog {
            if isOnGround && ty > groundY + 10 {
                isOnGround = false
                isFlying = true
                velocityY = 0
                startFlapAnimation()
                SoundManager.shared.play("jump")
            }

            if !isOnGround {
                isFlying = true
                let diff = ty - position.y
                velocityY += diff * followStrength
                velocityY *= damping
                velocityY = max(-maxVelocityY, min(maxVelocityY, velocityY))

                // Dramatic tilt — up to ~25 degrees
                let tilt = max(-0.45, min(0.45, velocityY * 0.002))
                zRotation = -tilt
            }
        } else if !isOnGround {
            isFlying = false
            velocityY += gravity * CGFloat(dt)

            // Nose-dive tilt when falling
            let tilt = max(-0.5, min(0, velocityY * 0.0015))
            zRotation = -tilt
        }

        // Walking animation on ground
        if isOnGround {
            walkBobTime += CGFloat(dt) * 9
            walkLegTime += CGFloat(dt) * 14

            // Bob up and down (bigger bounce)
            let bob = sin(walkBobTime) * 3.5
            position.y = groundY + bob

            // Body rock while walking
            zRotation = sin(walkLegTime) * 0.06

            // Squash/stretch for walking feel (more pronounced)
            let squash = 1.0 + sin(walkLegTime * 2) * 0.06
            yScale = squash
            xScale = 2.0 - squash

            return
        }

        // Reset scale in air
        xScale = 1.0
        yScale = 1.0

        position.y += velocityY * CGFloat(dt)

        if position.y > ceilingY {
            position.y = ceilingY
            velocityY = min(velocityY, 0)
        }

        if position.y <= groundY {
            position.y = groundY
            velocityY = 0
            isOnGround = true
            isFlying = false
            zRotation = 0
            walkBobTime = 0
            walkLegTime = 0
            xScale = 1.0
            yScale = 1.0
            stopFlapAnimation()
            SoundManager.shared.play("land")
        }
    }

    func makeInvincible(duration: TimeInterval = 1.5) { invincibleTimer = duration }

    func pulse() {
        run(SKAction.sequence([SKAction.scale(to: 1.15, duration: 0.06), SKAction.scale(to: 1.0, duration: 0.06)]))
    }

    func flash() {
        let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.08), SKAction.fadeAlpha(to: 1.0, duration: 0.08)])
        run(SKAction.repeat(blink, count: 4))
    }

    func playDeathAnimation(groundY: CGFloat, deadTexture: SKTexture) {
        removeAllActions()
        texture = deadTexture
        isFlying = false
        isOnGround = false
        physicsBody = nil

        // Flip upside down
        let flipOver = SKAction.rotate(byAngle: .pi, duration: 0.3)
        flipOver.timingMode = .easeOut

        // Fall to ground
        let fallDist = position.y - groundY
        let fallDuration = max(0.3, Double(fallDist / 300))
        let fall = SKAction.moveTo(y: groundY, duration: fallDuration)
        fall.timingMode = .easeIn

        // Small bounce on impact
        let bounceUp = SKAction.moveBy(x: 0, y: 8, duration: 0.1)
        let bounceDown = SKAction.moveBy(x: 0, y: -8, duration: 0.1)

        run(SKAction.sequence([
            flipOver,
            fall,
            bounceUp,
            bounceDown
        ]))
    }
}
