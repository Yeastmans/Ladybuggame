import SpriteKit

/// Generic ground enemy used across biomes (scorpion, rattlesnake, ice spider, etc.)
class BiomeEnemy: SKSpriteNode {

    let biomeName: String
    private var hasLunged = false
    private var baseY: CGFloat = 0

    init(texture: SKTexture, biomeName: String) {
        self.biomeName = biomeName
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.6)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        physicsBody = body
    }

    func startPatrolling() {
        baseY = position.y

        let dist = CGFloat.random(in: 12...30)
        let right = SKAction.sequence([
            SKAction.run { [weak self] in self?.xScale = abs(self?.xScale ?? 1) },
            SKAction.moveBy(x: dist, y: 0, duration: Double.random(in: 0.6...1.2))
        ])
        let left = SKAction.sequence([
            SKAction.run { [weak self] in self?.xScale = -(abs(self?.xScale ?? 1)) },
            SKAction.moveBy(x: -dist, y: 0, duration: Double.random(in: 0.6...1.2))
        ])
        let pause = SKAction.wait(forDuration: Double.random(in: 0.4...1.0))
        run(SKAction.repeatForever(SKAction.sequence([right, pause, left, pause])), withKey: "patrol")

        // Idle breathing animation
        let breathe = SKAction.sequence([
            SKAction.scaleY(to: 1.06, duration: 0.6),
            SKAction.scaleY(to: 0.96, duration: 0.6),
        ])
        run(SKAction.repeatForever(breathe), withKey: "breathe")
    }

    /// Lunge toward player when close.  Snakes strike horizontally, the house cat
    /// swipes its paw, the guard dog charges from far away; others jump.
    func lungeIfNear(playerX: CGFloat) {
        guard !hasLunged else { return }
        let dist = playerX - position.x
        let isSnake = biomeName == "Rattlesnake" || biomeName == "Garden Snake"
            || biomeName == "Swamp Snake" || biomeName == "Sand Viper"
            || biomeName == "Cosmic Serpent"
        let isCharger = biomeName == "Guard Dog" || biomeName == "Komodo Dragon"
        let minDist: CGFloat = isCharger ? -20 : -15
        let maxDist: CGFloat = isCharger ? 240 : 70
        if dist > minDist && dist < maxDist {
            hasLunged = true
            baseY = position.y
            SoundManager.shared.play("hiss")

            if biomeName == "House Cat" {
                // Quick paw swipe: rear back, then slash forward — no jump
                let dir: CGFloat = dist >= 0 ? 1.0 : -1.0
                xScale = dist >= 0 ? -abs(xScale) : abs(xScale)
                let rear = SKAction.group([
                    SKAction.moveBy(x: -12 * dir, y: 0, duration: 0.10),
                    SKAction.rotate(toAngle: 0.10 * dir, duration: 0.10),
                ])
                let swipe = SKAction.group([
                    SKAction.moveBy(x: 55 * dir, y: 6, duration: 0.09),
                    SKAction.rotate(toAngle: -0.18 * dir, duration: 0.09),
                ])
                swipe.timingMode = .easeIn
                let recover = SKAction.group([
                    SKAction.moveBy(x: -43 * dir, y: -6, duration: 0.22),
                    SKAction.rotate(toAngle: 0, duration: 0.22),
                ])
                recover.timingMode = .easeOut
                run(SKAction.sequence([rear, swipe, recover]))
            } else if isCharger {
                // Full-speed charge across the ground (guard dog is quicker,
                // the komodo dragon is a heavier runner)
                let dir: CGFloat = dist >= 0 ? 1.0 : -1.0
                xScale = dist >= 0 ? -abs(xScale) : abs(xScale)
                removeAction(forKey: "patrol")
                let crouch = SKAction.group([
                    SKAction.scaleX(to: 1.15 * (dist >= 0 ? -1 : 1), duration: 0.12),
                    SKAction.scaleY(to: 0.88, duration: 0.12),
                ])
                let dashDur = biomeName == "Guard Dog" ? 0.38 : 0.55
                let dash = SKAction.moveBy(x: (abs(dist) + 60) * dir, y: 0, duration: dashDur)
                dash.timingMode = .easeIn
                let skid = SKAction.group([
                    SKAction.scaleX(to: 1.0 * (dist >= 0 ? -1 : 1), duration: 0.15),
                    SKAction.scaleY(to: 1.0, duration: 0.15),
                    SKAction.moveBy(x: 14 * dir, y: 0, duration: 0.15),
                ])
                skid.timingMode = .easeOut
                run(SKAction.sequence([crouch, dash, skid]))
            } else if isSnake {
                // Horizontal strike toward player direction
                let dir: CGFloat = dist >= 0 ? 1.0 : -1.0
                // Face the player
                xScale = dist >= 0 ? -abs(xScale) : abs(xScale)
                let coilBack = SKAction.group([
                    SKAction.scaleX(to: 0.82 * (dist >= 0 ? -1 : 1), duration: 0.08),
                    SKAction.scaleY(to: 1.1, duration: 0.08),
                    SKAction.moveBy(x: -10 * dir, y: 0, duration: 0.08),
                ])
                let strike = SKAction.group([
                    SKAction.scaleX(to: 1.35 * (dist >= 0 ? -1 : 1), duration: 0.10),
                    SKAction.scaleY(to: 0.88, duration: 0.10),
                    SKAction.moveBy(x: 80 * dir, y: 0, duration: 0.10),
                ])
                strike.timingMode = .easeIn
                let holdStrike = SKAction.wait(forDuration: 0.05)
                let recoil = SKAction.group([
                    SKAction.scaleX(to: 1.0 * (dist >= 0 ? -1 : 1), duration: 0.18),
                    SKAction.scaleY(to: 1.0, duration: 0.18),
                    SKAction.moveBy(x: -70 * dir, y: 0, duration: 0.18),
                ])
                recoil.timingMode = .easeOut
                run(SKAction.sequence([coilBack, strike, holdStrike, recoil]))
            } else {
                // Scorpion/ice spider: high jump
                let jumpH: CGFloat = 130
                let jumpX: CGFloat = 55
                let squash = SKAction.group([
                    SKAction.scaleX(to: 1.2, duration: 0.08),
                    SKAction.scaleY(to: 0.8, duration: 0.08),
                ])
                let jumpUp = SKAction.group([
                    SKAction.moveBy(x: jumpX * 0.6, y: jumpH, duration: 0.22),
                    SKAction.scaleX(to: 0.9, duration: 0.22),
                    SKAction.scaleY(to: 1.15, duration: 0.22),
                ])
                jumpUp.timingMode = .easeOut
                let apex = SKAction.wait(forDuration: 0.06)
                let fallDown = SKAction.group([
                    SKAction.moveBy(x: jumpX * 0.4, y: -jumpH, duration: 0.2),
                    SKAction.scaleX(to: 1.0, duration: 0.2),
                    SKAction.scaleY(to: 1.0, duration: 0.2),
                ])
                fallDown.timingMode = .easeIn
                let landSquash = SKAction.group([
                    SKAction.scaleX(to: 1.25, duration: 0.05),
                    SKAction.scaleY(to: 0.75, duration: 0.05),
                ])
                let landRecover = SKAction.group([
                    SKAction.scaleX(to: 1.0, duration: 0.12),
                    SKAction.scaleY(to: 1.0, duration: 0.12),
                ])
                run(SKAction.sequence([squash, jumpUp, apex, fallDown, landSquash, landRecover]))
            }
        }
    }
}
