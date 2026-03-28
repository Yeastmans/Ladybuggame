import SpriteKit

class Ladybug: SKSpriteNode {

    private let walkTexture: SKTexture
    private let glideTexture: SKTexture
    private let blinkTexture: SKTexture

    private(set) var isGliding = false
    private(set) var isOnGround = true
    var velocityY: CGFloat = 0
    private var flightTime: CGFloat = 0
    let maxFlightTime: CGFloat = 2.0
    var targetY: CGFloat?
    private var invincibleTimer: TimeInterval = 0

    let jumpStrength: CGFloat = 380
    let gravity: CGFloat = -800
    let glideGravity: CGFloat = -150
    let flyUpForce: CGFloat = 600

    var isInvincible: Bool { invincibleTimer > 0 }

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
        guard flightTime < maxFlightTime else { return }
        if isOnGround {
            isOnGround = false
            velocityY = jumpStrength
        }
        isGliding = true
        texture = glideTexture
        run(SKAction.scale(to: 1.12, duration: 0.1), withKey: "jumpScale")
    }

    func stopFlying() {
        isGliding = false
    }

    func updatePhysics(dt: TimeInterval, groundY: CGFloat, ceilingY: CGFloat) {
        // Invincibility cooldown
        if invincibleTimer > 0 {
            invincibleTimer -= dt
        }

        guard !isOnGround else {
            flightTime = 0
            return
        }

        // Track flight time
        flightTime += CGFloat(dt)

        // Force landing if max flight exceeded
        if flightTime >= maxFlightTime {
            isGliding = false
        }

        // Apply gravity or fly force
        if isGliding && flightTime < maxFlightTime {
            // Follow finger Y — apply force toward target
            if let ty = targetY {
                let diff = ty - position.y
                velocityY += diff * 8.0 * CGFloat(dt)
                velocityY *= 0.92 // damping
            } else {
                velocityY += glideGravity * CGFloat(dt)
            }
        } else {
            velocityY += gravity * CGFloat(dt)
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
            isGliding = false
            flightTime = 0
            texture = walkTexture
            run(SKAction.scale(to: 1.0, duration: 0.08), withKey: "jumpScale")
        }
    }

    func makeInvincible(duration: TimeInterval = 1.5) {
        invincibleTimer = duration
    }

    func pulse() {
        run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.06), SKAction.scale(to: 1.0, duration: 0.06)]))
    }

    func flash() {
        let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.08), SKAction.fadeAlpha(to: 1.0, duration: 0.08)])
        run(SKAction.repeat(blink, count: 4))
    }

    /// Flight fuel ratio (0 = empty, 1 = full)
    var flightFuelRatio: CGFloat {
        return max(0, 1.0 - flightTime / maxFlightTime)
    }
}
