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
    private var walkBobTime: CGFloat = 0

    let gravity: CGFloat = -900
    let followSpeed: CGFloat = 12.0

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
        guard !isInsideLog else { return } // Can't fly out of log
        if isOnGround {
            isOnGround = false
            velocityY = 350
            SoundManager.shared.play("jump")
        }
        isFlying = true
        texture = glideTexture
        run(SKAction.scale(to: 1.1, duration: 0.08), withKey: "flyScale")
    }

    func stopFlying() {
        isFlying = false
    }

    func updatePhysics(dt: TimeInterval, groundY: CGFloat, ceilingY: CGFloat) {
        if invincibleTimer > 0 { invincibleTimer -= dt }

        // Walk bob when on ground
        if isOnGround {
            walkBobTime += CGFloat(dt) * 8
            let bob = sin(walkBobTime) * 1.5
            // Apply small Y offset for walk bob (relative to groundY)
            position.y = groundY + bob
            zRotation = sin(walkBobTime * 0.5) * 0.02 // Tiny tilt
            return
        }

        if isFlying, let ty = targetY {
            let diff = ty - position.y
            velocityY += diff * followSpeed * CGFloat(dt) * 60
            velocityY *= 0.88

            let tilt = max(-0.3, min(0.3, velocityY * 0.0008))
            zRotation = -tilt
        } else {
            velocityY += gravity * CGFloat(dt)
            let tilt = max(-0.4, min(0, velocityY * 0.0005))
            zRotation = -tilt
        }

        position.y += velocityY * CGFloat(dt)

        // Ceiling clamp (also clamped by log top in GameScene)
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
        run(SKAction.scale(to: 1.0, duration: 0.06), withKey: "flyScale")
        SoundManager.shared.play("land")
    }

    func makeInvincible(duration: TimeInterval = 1.5) {
        invincibleTimer = duration
    }

    func pulse() {
        run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.05), SKAction.scale(to: 1.0, duration: 0.05)]))
    }

    func flash() {
        let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.08), SKAction.fadeAlpha(to: 1.0, duration: 0.08)])
        run(SKAction.repeat(blink, count: 4))
    }
}
