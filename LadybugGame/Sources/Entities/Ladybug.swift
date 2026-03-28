import SpriteKit

class Ladybug: SKSpriteNode {

    private let walkTexture: SKTexture
    private let glideTexture: SKTexture
    private let blinkTexture: SKTexture

    private(set) var isFlying = false
    private(set) var isOnGround = true
    var isInsideLog = false
    var velocityY: CGFloat = 0
    var targetY: CGFloat?
    private var invincibleTimer: TimeInterval = 0
    private var baseGroundY: CGFloat = 0
    private var walkBobTime: CGFloat = 0

    let gravity: CGFloat = -600
    let followStrength: CGFloat = 3.5  // Much gentler follow
    let damping: CGFloat = 0.93        // Heavier damping for smooth feel

    var isInvincible: Bool { invincibleTimer > 0 }
    var isSheltered: Bool { isInsideLog && isOnGround }

    init(walkTexture: SKTexture, glideTexture: SKTexture, blinkTexture: SKTexture) {
        self.walkTexture = walkTexture
        self.glideTexture = glideTexture
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

    // MARK: - Flight

    func startFlying() {
        guard !isInsideLog else { return }
        if isOnGround {
            isOnGround = false
            velocityY = 250 // Gentler initial jump
            SoundManager.shared.play("jump")
        }
        isFlying = true
        texture = glideTexture
        // No abrupt scale change — keep it subtle
        run(SKAction.scale(to: 1.05, duration: 0.15), withKey: "flyScale")
    }

    func stopFlying() {
        isFlying = false
    }

    func updatePhysics(dt: TimeInterval, groundY: CGFloat, ceilingY: CGFloat) {
        if invincibleTimer > 0 { invincibleTimer -= dt }
        baseGroundY = groundY

        // Walk bob when on ground (using action offset, not position override)
        if isOnGround {
            walkBobTime += CGFloat(dt) * 6
            let bob = sin(walkBobTime) * 1.2
            position.y = groundY + bob
            zRotation = sin(walkBobTime * 0.5) * 0.015
            return
        }

        if isFlying, let ty = targetY {
            // Smooth follow — spring-like with heavy damping
            let diff = ty - position.y
            velocityY += diff * followStrength
            velocityY *= damping
        } else {
            // Falling — gravity only
            velocityY += gravity * CGFloat(dt)
        }

        // Gentle tilt based on velocity
        let tiltAmount = max(-0.2, min(0.2, velocityY * 0.0004))
        zRotation = -tiltAmount

        position.y += velocityY * CGFloat(dt)

        // Ceiling clamp
        if position.y > ceilingY {
            position.y = ceilingY
            velocityY = min(velocityY, 0)
        }

        // Hit ground
        if position.y <= groundY {
            land(at: groundY)
        }
    }

    func land(at groundY: CGFloat) {
        position.y = groundY
        velocityY = 0
        isOnGround = true
        isFlying = false
        zRotation = 0
        walkBobTime = 0
        texture = walkTexture
        run(SKAction.scale(to: 1.0, duration: 0.1), withKey: "flyScale")
        SoundManager.shared.play("land")
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
