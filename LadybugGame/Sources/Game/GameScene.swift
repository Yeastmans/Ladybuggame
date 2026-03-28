import SpriteKit

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {

    // MARK: - Physics Categories
    struct PhysicsCategory {
        static let none: UInt32      = 0
        static let ladybug: UInt32   = 0b0001
        static let aphid: UInt32     = 0b0010
        static let bird: UInt32      = 0b0100
        static let boundary: UInt32  = 0b1000
    }

    // MARK: - High Score
    private static let highScoreKey = "LadybugGameHighScore"

    private static var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    // MARK: - Cached Textures
    private var aphidTextures: [SKTexture] = []
    private var birdTextures: [SKTexture] = []

    // MARK: - Properties
    private var ladybug: Ladybug!
    private var logs: [Log] = []
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var jumpButton: SKShapeNode!

    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            if score > GameScene.highScore {
                GameScene.highScore = score
                highScoreLabel.text = "Best: \(score)"
            }
        }
    }
    private var lives: Int = 3 {
        didSet { livesLabel.text = "Lives: \(lives)" }
    }

    private var isGameOver = false
    private var isHiding = false
    private var aphidSpawnTimer: TimeInterval = 0
    private var birdSwoopTimer: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var targetPosition: CGPoint?

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1.0)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Pre-generate animated textures
        aphidTextures = TextureGenerator.generateAphidTextures(size: CGSize(width: 24, height: 24))
        birdTextures = TextureGenerator.generateBirdTextures(size: CGSize(width: 56, height: 40))

        setupBoundary()
        setupHUD()
        setupJumpButton()
        spawnLogs()
        spawnLadybug()
        spawnInitialAphids()
    }

    // MARK: - Setup

    private func setupBoundary() {
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
        borderBody.categoryBitMask = PhysicsCategory.boundary
        borderBody.friction = 0
        physicsBody = borderBody
    }

    private func setupHUD() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: size.height - 50)
        scoreLabel.zPosition = 100
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.fontSize = 20
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 16, y: size.height - 50)
        livesLabel.zPosition = 100
        livesLabel.text = "Lives: 3"
        addChild(livesLabel)

        highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = SKColor(white: 1.0, alpha: 0.7)
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.position = CGPoint(x: 16, y: size.height - 74)
        highScoreLabel.zPosition = 100
        highScoreLabel.text = "Best: \(GameScene.highScore)"
        addChild(highScoreLabel)
    }

    private func setupJumpButton() {
        let radius: CGFloat = 30
        jumpButton = SKShapeNode(circleOfRadius: radius)
        jumpButton.fillColor = SKColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 0.6)
        jumpButton.strokeColor = SKColor(white: 1.0, alpha: 0.5)
        jumpButton.lineWidth = 2
        jumpButton.position = CGPoint(x: size.width - 50, y: 80)
        jumpButton.zPosition = 150
        jumpButton.name = "jumpButton"
        addChild(jumpButton)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "FLY"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        jumpButton.addChild(label)
    }

    private func spawnLogs() {
        let hLogTexture = TextureGenerator.generateLogTexture(size: CGSize(width: 100, height: 36))
        let vLogTexture = TextureGenerator.generateVerticalLogTexture(size: CGSize(width: 36, height: 100))

        let margin: CGFloat = 80
        let logCount = 4

        for i in 0..<logCount {
            let isVertical = (i % 2 == 1) // alternate horizontal/vertical
            let texture = isVertical ? vLogTexture : hLogTexture
            let log = Log(texture: texture)

            let sectionHeight = (size.height - margin * 2) / CGFloat(logCount)
            let x = CGFloat.random(in: margin...(size.width - margin))
            let y = margin + sectionHeight * CGFloat(i) + CGFloat.random(in: 20...sectionHeight - 20)
            log.position = CGPoint(x: x, y: y)
            log.setupPhysics()
            addChild(log)
            logs.append(log)
        }
    }

    private func spawnLadybug() {
        let ladybugSize = CGSize(width: 48, height: 48)
        let walkTex = TextureGenerator.generateLadybugTexture(size: ladybugSize)
        let glideTex = TextureGenerator.generateLadybugGlideTexture(size: CGSize(width: 64, height: 48))
        let blinkTex = TextureGenerator.generateLadybugBlinkTexture(size: ladybugSize)
        ladybug = Ladybug(walkTexture: walkTex, glideTexture: glideTex, blinkTexture: blinkTex)
        ladybug.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ladybug.setupPhysics(category: PhysicsCategory.ladybug,
                             contact: PhysicsCategory.aphid | PhysicsCategory.bird,
                             collision: PhysicsCategory.boundary)
        addChild(ladybug)
    }

    private func spawnInitialAphids() {
        for _ in 0..<5 {
            spawnAphid()
        }
    }

    // MARK: - Spawning

    private func spawnAphid() {
        let aphid = Aphid(textures: aphidTextures)
        aphid.position = randomPosition(margin: 40)
        aphid.setupPhysics(category: PhysicsCategory.aphid,
                           contact: PhysicsCategory.ladybug,
                           collision: PhysicsCategory.none)
        addChild(aphid)
        aphid.startWandering(in: frame)
    }

    private func spawnSwoopingBird() {
        let bird = Bird(textures: birdTextures)

        let side = Int.random(in: 0...3)
        let startPos: CGPoint
        switch side {
        case 0: startPos = CGPoint(x: -60, y: CGFloat.random(in: 100...size.height - 100))
        case 1: startPos = CGPoint(x: size.width + 60, y: CGFloat.random(in: 100...size.height - 100))
        case 2: startPos = CGPoint(x: CGFloat.random(in: 100...size.width - 100), y: size.height + 60)
        default: startPos = CGPoint(x: CGFloat.random(in: 100...size.width - 100), y: -60)
        }

        bird.position = startPos
        bird.setupPhysics(category: PhysicsCategory.bird,
                          contact: PhysicsCategory.ladybug,
                          collision: PhysicsCategory.none)
        bird.zPosition = 10
        addChild(bird)

        // Swoop at the ladybug's position with overshoot
        let targetPos = ladybug.position
        let dx = targetPos.x - startPos.x
        let dy = targetPos.y - startPos.y
        let dist = hypot(dx, dy)
        let endPos = CGPoint(
            x: targetPos.x + (dx / dist) * 200,
            y: targetPos.y + (dy / dist) * 200
        )

        bird.swoop(to: endPos, duration: 1.8 + Double.random(in: 0...1.0))
    }

    private func randomPosition(margin: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: margin...(size.width - margin)),
            y: CGFloat.random(in: margin...(size.height - margin))
        )
    }

    // MARK: - Hiding Mechanic

    private func checkHiding() {
        var nowHiding = false
        for log in logs {
            let logFrame = CGRect(
                x: log.position.x - log.size.width / 2,
                y: log.position.y - log.size.height / 2,
                width: log.size.width,
                height: log.size.height
            )
            if logFrame.contains(ladybug.position) {
                nowHiding = true
                log.showShieldEffect()
            } else {
                log.hideShieldEffect()
            }
        }

        if nowHiding != isHiding {
            isHiding = nowHiding
            if isHiding {
                ladybug.alpha = 0.5
                ladybug.zPosition = 2
            } else {
                ladybug.alpha = 1.0
                ladybug.zPosition = 5
            }
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check jump button
        if jumpButton.contains(location) {
            ladybug.jump()
            return
        }

        targetPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver, let touch = touches.first else { return }
        let location = touch.location(in: self)
        // Don't update target if dragging on the jump button
        if !jumpButton.contains(location) {
            targetPosition = location
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Keep moving to last target
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        let dt: TimeInterval
        if lastUpdateTime == 0 {
            dt = 0
        } else {
            dt = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime

        // Move ladybug toward touch
        if let target = targetPosition {
            ladybug.moveToward(target, speed: 200, dt: dt)
        }

        // Update jump/glide physics
        ladybug.updateJump(dt: dt)

        // Check if hiding under a log (only when not airborne)
        if !ladybug.isGliding {
            checkHiding()
        }

        // Spawn aphids
        aphidSpawnTimer += dt
        if aphidSpawnTimer >= 2.0 {
            aphidSpawnTimer = 0
            let aphidCount = children.filter { $0 is Aphid }.count
            if aphidCount < 8 {
                spawnAphid()
            }
        }

        // Birds swoop periodically
        birdSwoopTimer += dt
        let swoopInterval = max(2.0, 5.0 - Double(score) * 0.03)
        if birdSwoopTimer >= swoopInterval {
            birdSwoopTimer = 0
            spawnSwoopingBird()
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.ladybug | PhysicsCategory.aphid {
            let aphidNode = (contact.bodyA.categoryBitMask == PhysicsCategory.aphid)
                ? contact.bodyA.node : contact.bodyB.node
            aphidNode?.removeFromParent()
            score += 10
            ladybug.pulse()
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.bird {
            // Safe if hiding under a log or gliding in the air
            if isHiding || ladybug.isGliding {
                return
            }

            lives -= 1
            ladybug.flash()

            let birdNode = (contact.bodyA.categoryBitMask == PhysicsCategory.bird)
                ? contact.bodyA.node : contact.bodyB.node
            birdNode?.removeFromParent()

            if lives <= 0 {
                gameOver()
            }
        }
    }

    // MARK: - Game Over

    private func gameOver() {
        isGameOver = true
        ladybug.removeAllActions()

        let isNewHighScore = score >= GameScene.highScore && score > 0

        // Dim overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = SKColor(white: 0.0, alpha: 0.4)
        overlay.strokeColor = .clear
        overlay.zPosition = 150
        addChild(overlay)

        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 44
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        gameOverLabel.zPosition = 200
        addChild(gameOverLabel)

        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        finalScoreLabel.text = "Score: \(score)"
        finalScoreLabel.fontSize = 28
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        finalScoreLabel.zPosition = 200
        addChild(finalScoreLabel)

        if isNewHighScore {
            let newHighLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            newHighLabel.text = "New High Score!"
            newHighLabel.fontSize = 22
            newHighLabel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            newHighLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 35)
            newHighLabel.zPosition = 200
            addChild(newHighLabel)

            let scaleUp = SKAction.scale(to: 1.15, duration: 0.3)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
            newHighLabel.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
        }

        let bestLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        bestLabel.text = "Best: \(GameScene.highScore)"
        bestLabel.fontSize = 20
        bestLabel.fontColor = SKColor(white: 1.0, alpha: 0.8)
        bestLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 65)
        bestLabel.zPosition = 200
        addChild(bestLabel)

        let tapLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tapLabel.text = "Tap to play again"
        tapLabel.fontSize = 18
        tapLabel.fontColor = SKColor(white: 1.0, alpha: 0.6)
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        tapLabel.zPosition = 200
        addChild(tapLabel)

        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        tapLabel.run(SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut])))
    }

    private func restartGame() {
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        view?.presentScene(newScene, transition: .fade(withDuration: 0.5))
    }
}
