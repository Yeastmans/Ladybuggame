import SpriteKit

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {

    // MARK: - Physics Categories
    struct PhysicsCategory {
        static let none: UInt32      = 0
        static let ladybug: UInt32   = 0b0001
        static let aphid: UInt32     = 0b0010
        static let bird: UInt32      = 0b0100
        static let log: UInt32       = 0b1000
    }

    // MARK: - Properties
    private var ladybug: Ladybug!
    private var groundY: CGFloat = 0
    private var scrollSpeed: CGFloat = 180
    private var distanceTraveled: CGFloat = 0

    private var scoreLabel: SKLabelNode!
    private var score: Int = 0 {
        didSet { scoreLabel.text = "\(score)" }
    }
    private var lives: Int = 3
    private var livesLabel: SKLabelNode!

    private var isGameOver = false
    private var isTouching = false
    private var lastUpdateTime: TimeInterval = 0

    // Spawn timers
    private var aphidTimer: TimeInterval = 0
    private var logTimer: TimeInterval = 0
    private var birdTimer: TimeInterval = 0

    // Cached textures
    private var birdTextures: [SKTexture] = []
    private var aphidTextures: [TextureGenerator.AphidColor: SKTexture] = [:]
    private var logTexture: SKTexture!

    // Scrolling ground
    private var groundTiles: [SKSpriteNode] = []

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.50, green: 0.78, blue: 0.95, alpha: 1.0)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        groundY = size.height * 0.35

        // Pre-generate textures
        birdTextures = TextureGenerator.generateBirdTextures(size: CGSize(width: 50, height: 36))
        logTexture = TextureGenerator.generateLogTexture(size: CGSize(width: 70, height: 50))
        for color in [TextureGenerator.AphidColor.green, .yellow, .red] {
            aphidTextures[color] = TextureGenerator.generateAphidTexture(size: CGSize(width: 22, height: 22), color: color)
        }

        setupBackground()
        setupGround()
        setupHUD()
        spawnLadybug()
    }

    // MARK: - Setup

    private func setupBackground() {
        // Clouds
        for i in 0..<4 {
            let cloud = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 60...120), height: CGFloat.random(in: 20...35)), cornerRadius: 15)
            cloud.fillColor = SKColor(white: 1.0, alpha: CGFloat.random(in: 0.3...0.6))
            cloud.strokeColor = .clear
            let x = CGFloat(i) * size.width * 0.28 + CGFloat.random(in: 0...60)
            let y = size.height * CGFloat.random(in: 0.72...0.92)
            cloud.position = CGPoint(x: x, y: y)
            cloud.zPosition = -5
            cloud.name = "cloud"
            addChild(cloud)
        }
    }

    private func setupGround() {
        // Scrolling ground tiles
        let tileWidth = size.width
        for i in 0..<3 {
            let tile = SKSpriteNode(color: SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1.0),
                                    size: CGSize(width: tileWidth, height: groundY))
            tile.anchorPoint = CGPoint(x: 0, y: 0)
            tile.position = CGPoint(x: CGFloat(i) * tileWidth, y: 0)
            tile.zPosition = -2
            tile.name = "groundTile"
            addChild(tile)
            groundTiles.append(tile)

            // Dark grass line at top
            let grassLine = SKShapeNode(rectOf: CGSize(width: tileWidth, height: 3))
            grassLine.fillColor = SKColor(red: 0.35, green: 0.58, blue: 0.22, alpha: 1.0)
            grassLine.strokeColor = .clear
            grassLine.position = CGPoint(x: tileWidth / 2, y: groundY)
            tile.addChild(grassLine)

            // Some grass tufts
            for _ in 0..<8 {
                let tuft = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 4...10)))
                tuft.fillColor = SKColor(red: 0.38, green: 0.65, blue: 0.25, alpha: 0.6)
                tuft.strokeColor = .clear
                tuft.position = CGPoint(x: CGFloat.random(in: 10...tileWidth - 10),
                                        y: groundY + CGFloat.random(in: 2...5))
                tile.addChild(tuft)
            }
        }
    }

    private func setupHUD() {
        // Score (top left)
        let scoreIcon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreIcon.text = "Score:"
        scoreIcon.fontSize = 18
        scoreIcon.fontColor = .white
        scoreIcon.horizontalAlignmentMode = .left
        scoreIcon.position = CGPoint(x: 16, y: size.height - 35)
        scoreIcon.zPosition = 100
        addChild(scoreIcon)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 80, y: size.height - 35)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // Lives (top right)
        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 16, y: size.height - 35)
        livesLabel.zPosition = 100
        updateLivesDisplay()
        addChild(livesLabel)
    }

    private func updateLivesDisplay() {
        livesLabel.text = String(repeating: "❤️", count: max(0, lives))
    }

    private func spawnLadybug() {
        let bugSize = CGSize(width: 44, height: 44)
        let walkTex = TextureGenerator.generateLadybugTexture(size: bugSize)
        let glideTex = TextureGenerator.generateLadybugGlideTexture(size: CGSize(width: 58, height: 44))
        let blinkTex = TextureGenerator.generateLadybugBlinkTexture(size: bugSize)
        ladybug = Ladybug(walkTexture: walkTex, glideTexture: glideTex, blinkTexture: blinkTex)
        ladybug.position = CGPoint(x: size.width * 0.18, y: groundY + bugSize.height / 2)
        ladybug.zRotation = -.pi / 2 // Face right

        let body = SKPhysicsBody(circleOfRadius: bugSize.width / 2 * 0.7)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.ladybug
        body.contactTestBitMask = PhysicsCategory.aphid | PhysicsCategory.bird | PhysicsCategory.log
        body.collisionBitMask = PhysicsCategory.none
        body.allowsRotation = false
        ladybug.physicsBody = body

        addChild(ladybug)
    }

    // MARK: - Touch (tap = jump, hold = glide)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            let menu = MenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu, transition: .fade(withDuration: 0.4))
            return
        }
        isTouching = true
        ladybug.jump()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        ladybug.stopGlide()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        ladybug.stopGlide()
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        guard dt > 0, dt < 0.5 else { return }

        // Hold to glide
        if isTouching && !ladybug.isOnGround && !ladybug.isGliding {
            ladybug.startGlide()
        }

        // Ladybug physics
        let ladybugGroundY = groundY + ladybug.size.height / 2
        ladybug.updatePhysics(dt: dt, groundY: ladybugGroundY)

        // Scroll speed increases over time
        distanceTraveled += scrollSpeed * CGFloat(dt)
        scrollSpeed = min(350, 180 + distanceTraveled * 0.003)

        let scrollDelta = scrollSpeed * CGFloat(dt)

        // Scroll ground tiles
        scrollGround(delta: scrollDelta)

        // Scroll clouds (parallax)
        enumerateChildNodes(withName: "cloud") { node, _ in
            node.position.x -= scrollDelta * 0.2
            if node.position.x < -150 {
                node.position.x = self.size.width + CGFloat.random(in: 50...150)
                node.position.y = self.size.height * CGFloat.random(in: 0.72...0.92)
            }
        }

        // Scroll world objects
        scrollWorldObjects(delta: scrollDelta)

        // Spawn timers
        aphidTimer += dt
        if aphidTimer >= 0.8 {
            aphidTimer = 0
            spawnAphid()
        }

        logTimer += dt
        let logInterval = max(2.0, 4.5 - Double(distanceTraveled) * 0.0003)
        if logTimer >= logInterval {
            logTimer = 0
            spawnLog()
        }

        birdTimer += dt
        let birdInterval = max(2.5, 6.0 - Double(distanceTraveled) * 0.0004)
        if birdTimer >= birdInterval {
            birdTimer = 0
            spawnBird()
        }
    }

    // MARK: - Scrolling

    private func scrollGround(delta: CGFloat) {
        for tile in groundTiles {
            tile.position.x -= delta
            if tile.position.x + tile.size.width < 0 {
                let maxX = groundTiles.map { $0.position.x }.max() ?? 0
                tile.position.x = maxX + tile.size.width
            }
        }
    }

    private func scrollWorldObjects(delta: CGFloat) {
        for child in children {
            if child is Aphid || child is Log || child is Bird {
                child.position.x -= delta
                if child.position.x < -100 {
                    child.removeFromParent()
                }
            }
        }
    }

    // MARK: - Spawning

    private func spawnAphid() {
        // Pick color by rarity
        let roll = Int.random(in: 0..<100)
        let color: TextureGenerator.AphidColor
        if roll < 60 { color = .green }
        else if roll < 85 { color = .yellow }
        else { color = .red }

        guard let tex = aphidTextures[color] else { return }
        let aphid = Aphid(texture: tex, colorType: color)

        // Ground or air placement
        let onGround = Bool.random()
        let x = size.width + 40
        let y: CGFloat
        if onGround {
            y = groundY + aphid.size.height / 2
        } else {
            y = groundY + CGFloat.random(in: 40...size.height * 0.45)
        }
        aphid.position = CGPoint(x: x, y: y)
        aphid.setupPhysics()
        addChild(aphid)
    }

    private func spawnLog() {
        let log = Log(texture: logTexture)
        log.position = CGPoint(x: size.width + 50, y: groundY + log.size.height / 2 - 5)
        log.setupPhysics()
        addChild(log)
    }

    private func spawnBird() {
        let bird = Bird(textures: birdTextures)
        let startX = size.width + 60
        let startY = size.height * CGFloat.random(in: 0.55...0.90)
        bird.position = CGPoint(x: startX, y: startY)
        bird.zRotation = .pi / 2 // Face left
        bird.setupPhysics()
        addChild(bird)

        // Swoop down toward ladybug's height then back up
        let midY = groundY + ladybug.size.height / 2 + 10
        let swoopDown = SKAction.moveTo(y: midY, duration: 0.6)
        swoopDown.timingMode = .easeIn
        let swoopUp = SKAction.moveTo(y: size.height * CGFloat.random(in: 0.5...0.8), duration: 0.8)
        swoopUp.timingMode = .easeOut
        bird.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            swoopDown,
            swoopUp
        ]))
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.ladybug | PhysicsCategory.aphid {
            let aphidNode = (contact.bodyA.categoryBitMask == PhysicsCategory.aphid)
                ? contact.bodyA.node as? Aphid : contact.bodyB.node as? Aphid
            if let aphid = aphidNode {
                score += aphid.points
                aphid.removeFromParent()
                ladybug.pulse()
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.bird {
            if ladybug.isGliding { return } // Safe while gliding
            takeDamage()
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.log {
            if !ladybug.isOnGround { return } // Jumped over it
            takeDamage()
        }
    }

    private func takeDamage() {
        lives -= 1
        updateLivesDisplay()
        ladybug.flash()

        if lives <= 0 {
            gameOver()
        }
    }

    // MARK: - Game Over

    private func gameOver() {
        isGameOver = true

        if score > MenuScene.highScore {
            MenuScene.highScore = score
        }

        // Dim overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0.0, alpha: 0.5)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 150
        addChild(overlay)

        let goLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goLabel.text = "Game Over"
        goLabel.fontSize = 42
        goLabel.fontColor = .white
        goLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 35)
        goLabel.zPosition = 200
        addChild(goLabel)

        let scoreText = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreText.text = "Score: \(score)"
        scoreText.fontSize = 26
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: size.width / 2, y: size.height / 2 - 5)
        scoreText.zPosition = 200
        addChild(scoreText)

        if score >= MenuScene.highScore && score > 0 {
            let newHigh = SKLabelNode(fontNamed: "AvenirNext-Bold")
            newHigh.text = "New High Score!"
            newHigh.fontSize = 20
            newHigh.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            newHigh.position = CGPoint(x: size.width / 2, y: size.height / 2 - 35)
            newHigh.zPosition = 200
            addChild(newHigh)
        }

        let tapLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tapLabel.text = "Tap for menu"
        tapLabel.fontSize = 16
        tapLabel.fontColor = SKColor(white: 1.0, alpha: 0.6)
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 65)
        tapLabel.zPosition = 200
        addChild(tapLabel)
    }
}
