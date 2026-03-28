import SpriteKit

class Ladybug: SKSpriteNode {

    private let walkTexture: SKTexture
    private let blinkTexture: SKTexture

    private(set) var isFlying = false
    private(set) var isOnGround = true
    var isInsideLog = false
    var velocityY: CGFloat = 0
    var targetY: CGFloat?
    private var invincibleTimer: TimeInterval = 0
    private var walkBobTime: CGFloat = 0

    let gravity: CGFloat = -500
    let followStrength: CGFloat = 2.2   // Gentle pull toward finger
    let damping: CGFloat = 0.95         // Heavy damping — very smooth, no bounce

    var isInvincible: Bool { invincibleTimer > 0 }
    var isSheltered: Bool { isInsideLog && isOnGround }

    init(walkTexture: SKTexture, blinkTexture: SKTexture) {
        self.walkTexture = walkTexture
        self.blinkTexture = blinkTexture
        super.init(texture: walkTexture, color: .clear, size: walkTexture.size())
        zPosition = 10
        startBlinking()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Blinking

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

    // MARK: - Physics

    func updatePhysics(dt: TimeInterval, groundY: CGFloat, ceilingY: CGFloat) {
        if invincibleTimer > 0 { invincibleTimer -= dt }

        if let ty = targetY, !isInsideLog {
            // Finger is on screen — follow it smoothly
            if isOnGround && ty > groundY + 10 {
                // Lift off — finger is above ground
                isOnGround = false
                isFlying = true
                velocityY = 0
                texture = walkTexture
                SoundManager.shared.play("jump")
            }

            if !isOnGround {
                isFlying = true
                let diff = ty - position.y
                velocityY += diff * followStrength
                velocityY *= damping

                // Gentle tilt
                let tilt = max(-0.15, min(0.15, velocityY * 0.0003))
                zRotation = -tilt
            }
        } else if !isOnGround {
            // No finger — fall with gravity
            isFlying = false
            velocityY += gravity * CGFloat(dt)
            let tilt = max(-0.2, min(0, velocityY * 0.0004))
            zRotation = -tilt
        }

        // Walk bob when on ground
        if isOnGround {
            walkBobTime += CGFloat(dt) * 6
            let bob = sin(walkBobTime) * 1.2
            position.y = groundY + bob
            zRotation = sin(walkBobTime * 0.5) * 0.015
            return
        }

        position.y += velocityY * CGFloat(dt)

        // Ceiling clamp
        if position.y > ceilingY {
            position.y = ceilingY
            velocityY = min(velocityY, 0)
        }

        // Hit ground
        if position.y <= groundY {
            position.y = groundY
            velocityY = 0
            isOnGround = true
            isFlying = false
            zRotation = 0
            walkBobTime = 0
            texture = walkTexture
            SoundManager.shared.play("land")
        }
    }

    func makeInvincible(duration: TimeInterval = 1.5) {
        invincibleTimer = duration
    }

    func pulse() {
        run(SKAction.sequence([SKAction.scale(to: 1.15, duration: 0.06), SKAction.scale(to: 1.0, duration: 0.06)]))
    }

    func flash() {
        let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.08), SKAction.fadeAlpha(to: 1.0, duration: 0.08)])
        run(SKAction.repeat(blink, count: 4))
    }
}
