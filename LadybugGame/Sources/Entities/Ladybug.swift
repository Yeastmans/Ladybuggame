import SpriteKit

class Ladybug: SKSpriteNode {

    private let walkTexture: SKTexture
    private let glideTexture: SKTexture
    private let blinkTexture: SKTexture

    private(set) var isGliding = false
    private(set) var isOnGround = true
    var velocityY: CGFloat = 0
    let jumpStrength: CGFloat = 420
    let gravity: CGFloat = -900
    let glideGravity: CGFloat = -180

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

    // MARK: - Jump / Glide

    func jump() {
        guard isOnGround else { return }
        isOnGround = false
        velocityY = jumpStrength
        texture = glideTexture
        let grow = SKAction.scale(to: 1.15, duration: 0.15)
        run(grow, withKey: "jumpScale")
    }

    func startGlide() {
        guard !isOnGround else { return }
        isGliding = true
        texture = glideTexture
    }

    func stopGlide() {
        isGliding = false
    }

    func updatePhysics(dt: TimeInterval, groundY: CGFloat) {
        guard !isOnGround else { return }

        let currentGravity = isGliding ? glideGravity : gravity
        velocityY += currentGravity * CGFloat(dt)
        position.y += velocityY * CGFloat(dt)

        // Hit ground
        if position.y <= groundY {
            position.y = groundY
            velocityY = 0
            isOnGround = true
            isGliding = false
            texture = walkTexture
            let shrink = SKAction.scale(to: 1.0, duration: 0.1)
            run(shrink, withKey: "jumpScale")
        }
    }

    func pulse() {
        let s = SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.08), SKAction.scale(to: 1.0, duration: 0.08)])
        run(s)
    }

    func flash() {
        let blink = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.1), SKAction.fadeAlpha(to: 1.0, duration: 0.1)])
        run(SKAction.repeat(blink, count: 3))
    }
}
