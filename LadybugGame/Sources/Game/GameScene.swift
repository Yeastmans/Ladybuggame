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
    private var scrollSpeed: CGFloat = 160
    private var distanceTraveled: CGFloat = 0

    private var scoreLabel: SKLabelNode!
    private var score: Int = 0 {
        didSet { scoreLabel.text = "\(score)" }
    }
    private var lives: Int = 3
    private var livesLabel: SKLabelNode!
    private var fuelBar: SKShapeNode!
    private var fuelFill: SKShapeNode!

    private var isGameOver = false
    private var isTouching = false
    private var touchY: CGFloat?
    private var lastUpdateTime: TimeInterval = 0

    // Spawn timers
    private var aphidTimer: TimeInterval = 0
    private var logTimer: TimeInterval = 0
    private var birdTimer: TimeInterval = 0
    private var envTimer: TimeInterval = 0

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

        groundY = size.height * 0.30

        birdTextures = TextureGenerator.generateBirdTextures(size: CGSize(width: 50, height: 36))
        logTexture = TextureGenerator.generateLogTexture(size: CGSize(width: 65, height: 55))
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
        for i in 0..<5 {
            addCloud(x: CGFloat(i) * size.width * 0.25 + CGFloat.random(in: 0...60))
        }

        // Distant hills
        for i in 0..<4 {
            let hill = SKShapeNode()
            let path = UIBezierPath()
            let hillW = CGFloat.random(in: 180...300)
            let hillH = CGFloat.random(in: 30...60)
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: hillW, y: 0), controlPoint: CGPoint(x: hillW / 2, y: hillH))
            path.close()
            hill.path = path.cgPath
            hill.fillColor = SKColor(red: 0.38, green: 0.65, blue: 0.28, alpha: 0.4)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: CGFloat(i) * size.width * 0.3, y: groundY)
            hill.zPosition = -3
            hill.name = "hill"
            addChild(hill)
        }
    }

    private func addCloud(x: CGFloat) {
        let cloud = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 50...110), height: CGFloat.random(in: 18...30)), cornerRadius: 12)
        cloud.fillColor = SKColor(white: 1.0, alpha: CGFloat.random(in: 0.3...0.6))
        cloud.strokeColor = .clear
        cloud.position = CGPoint(x: x, y: size.height * CGFloat.random(in: 0.70...0.92))
        cloud.zPosition = -5
        cloud.name = "cloud"
        addChild(cloud)
    }

    private func setupGround() {
        let tileWidth = size.width
        for i in 0..<3 {
            let tile = SKSpriteNode(color: SKColor(red: 0.42, green: 0.68, blue: 0.28, alpha: 1.0),
                                    size: CGSize(width: tileWidth, height: groundY))
            tile.anchorPoint = CGPoint(x: 0, y: 0)
            tile.position = CGPoint(x: CGFloat(i) * tileWidth, y: 0)
            tile.zPosition = -2
            tile.name = "groundTile"
            addChild(tile)
            groundTiles.append(tile)

            // Dirt layer at bottom
            let dirt = SKShapeNode(rectOf: CGSize(width: tileWidth, height: groundY * 0.4))
            dirt.fillColor = SKColor(red: 0.50, green: 0.35, blue: 0.18, alpha: 1.0)
            dirt.strokeColor = .clear
            dirt.position = CGPoint(x: tileWidth / 2, y: groundY * 0.2)
            tile.addChild(dirt)

            // Grass line
            let grassLine = SKShapeNode(rectOf: CGSize(width: tileWidth, height: 4))
            grassLine.fillColor = SKColor(red: 0.32, green: 0.55, blue: 0.20, alpha: 1.0)
            grassLine.strokeColor = .clear
            grassLine.position = CGPoint(x: tileWidth / 2, y: groundY)
            tile.addChild(grassLine)

            // Grass tufts
            for _ in 0..<12 {
                let tuft = SKShapeNode()
                let tp = UIBezierPath()
                let tw: CGFloat = CGFloat.random(in: 3...6)
                let th: CGFloat = CGFloat.random(in: 5...14)
                tp.move(to: CGPoint(x: 0, y: 0))
                tp.addQuadCurve(to: CGPoint(x: tw, y: 0), controlPoint: CGPoint(x: tw / 2, y: th))
                tp.close()
                tuft.path = tp.cgPath
                tuft.fillColor = SKColor(red: CGFloat.random(in: 0.35...0.50),
                                         green: CGFloat.random(in: 0.60...0.78),
                                         blue: CGFloat.random(in: 0.18...0.30),
                                         alpha: 0.7)
                tuft.strokeColor = .clear
                tuft.position = CGPoint(x: CGFloat.random(in: 5...tileWidth - 5), y: groundY - 1)
                tile.addChild(tuft)
            }
        }
    }

    private func setupHUD() {
        let scoreIcon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreIcon.text = "Score:"
        scoreIcon.fontSize = 18
        scoreIcon.fontColor = .white
        scoreIcon.horizontalAlignmentMode = .left
        scoreIcon.position = CGPoint(x: 50, y: size.height - 30)
        scoreIcon.zPosition = 100
        addChild(scoreIcon)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 114, y: size.height - 30)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 50, y: size.height - 30)
        livesLabel.zPosition = 100
        updateLivesDisplay()
        addChild(livesLabel)

        // Flight fuel bar
        let barW: CGFloat = 60
        let barH: CGFloat = 8
        fuelBar = SKShapeNode(rectOf: CGSize(width: barW, height: barH), cornerRadius: 3)
        fuelBar.fillColor = SKColor(white: 0.0, alpha: 0.3)
        fuelBar.strokeColor = SKColor(white: 1.0, alpha: 0.5)
        fuelBar.lineWidth = 1
        fuelBar.position = CGPoint(x: 80, y: size.height - 48)
        fuelBar.zPosition = 100
        addChild(fuelBar)

        fuelFill = SKShapeNode(rectOf: CGSize(width: barW - 4, height: barH - 4), cornerRadius: 2)
        fuelFill.fillColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
        fuelFill.strokeColor = .clear
        fuelFill.zPosition = 101
        fuelBar.addChild(fuelFill)

        let fuelLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        fuelLabel.text = "FLY"
        fuelLabel.fontSize = 10
        fuelLabel.fontColor = SKColor(white: 1.0, alpha: 0.6)
        fuelLabel.position = CGPoint(x: 0, y: -3)
        fuelLabel.zPosition = 102
        fuelBar.addChild(fuelLabel)
    }

    private func updateLivesDisplay() {
        var hearts = ""
        for i in 0..<3 {
            hearts += i < lives ? "♥" : "♡"
            if i < 2 { hearts += " " }
        }
        livesLabel.text = hearts
    }

    private func spawnLadybug() {
        let bugSize = CGSize(width: 44, height: 44)
        let walkTex = TextureGenerator.generateLadybugTexture(size: bugSize)
        let glideTex = TextureGenerator.generateLadybugGlideTexture(size: CGSize(width: 58, height: 44))
        let blinkTex = TextureGenerator.generateLadybugBlinkTexture(size: bugSize)
        ladybug = Ladybug(walkTexture: walkTex, glideTexture: glideTex, blinkTexture: blinkTex)
        ladybug.position = CGPoint(x: size.width * 0.18, y: groundY + bugSize.height / 2)
        // No zRotation — sprites are drawn facing right as side-view

        let body = SKPhysicsBody(circleOfRadius: bugSize.width / 2 * 0.65)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.ladybug
        body.contactTestBitMask = PhysicsCategory.aphid | PhysicsCategory.bird | PhysicsCategory.log
        body.collisionBitMask = PhysicsCategory.none
        body.allowsRotation = false
        body.affectedByGravity = false
        ladybug.physicsBody = body

        addChild(ladybug)
    }

    // MARK: - Touch Controls

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            let menu = MenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu, transition: .fade(withDuration: 0.4))
            return
        }
        guard let touch = touches.first else { return }
        isTouching = true
        touchY = touch.location(in: self).y
        ladybug.startFlying()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchY = touch.location(in: self).y
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        touchY = nil
        ladybug.stopFlying()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        touchY = nil
        ladybug.stopFlying()
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

        // Pass finger Y to ladybug
        ladybug.targetY = isTouching ? touchY : nil

        // Ladybug physics
        let bugGroundY = groundY + ladybug.size.height / 2
        let ceilingY = size.height - ladybug.size.height / 2 - 10
        ladybug.updatePhysics(dt: dt, groundY: bugGroundY, ceilingY: ceilingY)

        // Update fuel bar
        let fuel = ladybug.flightFuelRatio
        fuelFill.xScale = fuel
        fuelFill.fillColor = fuel > 0.3
            ? SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
            : SKColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 0.8)

        // Check log collisions manually (block the ladybug)
        checkLogCollisions()

        // Scroll
        distanceTraveled += scrollSpeed * CGFloat(dt)
        scrollSpeed = min(300, 160 + distanceTraveled * 0.002)
        let scrollDelta = scrollSpeed * CGFloat(dt)

        scrollGround(delta: scrollDelta)
        scrollParallax(delta: scrollDelta)
        scrollWorldObjects(delta: scrollDelta)

        // Spawns
        aphidTimer += dt
        if aphidTimer >= 1.0 {
            aphidTimer = 0
            spawnAphid()
        }

        logTimer += dt
        let logInterval = max(2.5, 5.0 - Double(distanceTraveled) * 0.0003)
        if logTimer >= logInterval {
            logTimer = 0
            spawnLog()
        }

        birdTimer += dt
        let birdInterval = max(2.0, 5.0 - Double(distanceTraveled) * 0.0004)
        if birdTimer >= birdInterval {
            birdTimer = 0
            spawnBird()
        }

        envTimer += dt
        if envTimer >= 1.5 {
            envTimer = 0
            spawnEnvironment()
        }
    }

    // MARK: - Log Collision (impassable)

    private func checkLogCollisions() {
        guard ladybug.isOnGround else { return }
        for child in children {
            guard let log = child as? Log else { continue }
            let logLeft = log.position.x - log.size.width * 0.4
            let logRight = log.position.x + log.size.width * 0.4
            let bugRight = ladybug.position.x + ladybug.size.width * 0.3

            // If ladybug would overlap the log on the ground, push back / take damage
            if bugRight > logLeft && ladybug.position.x < logRight {
                let logTop = log.position.y + log.size.height * 0.3
                if ladybug.position.y - ladybug.size.height * 0.3 < logTop {
                    // Hit the log — game over style damage
                    if !ladybug.isInvincible {
                        takeDamage()
                    }
                }
            }
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

    private func scrollParallax(delta: CGFloat) {
        enumerateChildNodes(withName: "cloud") { node, _ in
            node.position.x -= delta * 0.15
            if node.position.x < -130 {
                node.position.x = self.size.width + CGFloat.random(in: 30...120)
                node.position.y = self.size.height * CGFloat.random(in: 0.70...0.92)
            }
        }
        enumerateChildNodes(withName: "hill") { node, _ in
            node.position.x -= delta * 0.3
            if node.position.x < -350 {
                node.position.x = self.size.width + CGFloat.random(in: 50...200)
            }
        }
        enumerateChildNodes(withName: "envDecor") { node, _ in
            node.position.x -= delta
            if node.position.x < -50 {
                node.removeFromParent()
            }
        }
    }

    private func scrollWorldObjects(delta: CGFloat) {
        for child in children {
            if child is Aphid || child is Log || child is Bird {
                child.position.x -= delta
                if child.position.x < -120 {
                    child.removeFromParent()
                }
            }
        }
    }

    // MARK: - Spawning

    private func spawnAphid() {
        let roll = Int.random(in: 0..<100)
        let color: TextureGenerator.AphidColor
        if roll < 55 { color = .green }
        else if roll < 82 { color = .yellow }
        else { color = .red }

        guard let tex = aphidTextures[color] else { return }
        let isFlying = Bool.random()
        let aphid = Aphid(texture: tex, colorType: color, isFlying: isFlying)

        let x = size.width + 30
        let y: CGFloat
        if isFlying {
            y = groundY + CGFloat.random(in: 50...size.height * 0.50)
        } else {
            y = groundY + aphid.size.height / 2
        }
        aphid.position = CGPoint(x: x, y: y)
        aphid.setupPhysics()
        aphid.startMoving()
        addChild(aphid)
    }

    private func spawnLog() {
        let log = Log(texture: logTexture)
        log.position = CGPoint(x: size.width + 50, y: groundY + log.size.height / 2 - 3)
        log.setupPhysics()
        addChild(log)
    }

    private func spawnBird() {
        let bird = Bird(textures: birdTextures)
        let startY = size.height * CGFloat.random(in: 0.60...0.88)
        bird.position = CGPoint(x: size.width + 60, y: startY)
        bird.setupPhysics()
        addChild(bird)

        // Swoop across screen, diving toward ladybug's current Y
        let targetY = ladybug.position.y
        bird.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                         targetY: targetY, duration: 2.0 + Double.random(in: 0...0.8))
    }

    private func spawnEnvironment() {
        let roll = Int.random(in: 0...3)
        let node: SKShapeNode
        let x = size.width + 30

        switch roll {
        case 0:
            // Flower
            node = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...5))
            node.fillColor = [SKColor.yellow, SKColor.magenta, SKColor.orange, SKColor.white].randomElement()!
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + CGFloat.random(in: 3...10))
        case 1:
            // Small rock
            node = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 6...14), height: CGFloat.random(in: 4...8)), cornerRadius: 2)
            node.fillColor = SKColor(red: 0.55, green: 0.50, blue: 0.45, alpha: 0.7)
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + 2)
        case 2:
            // Bush
            node = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...15))
            node.fillColor = SKColor(red: 0.30, green: CGFloat.random(in: 0.55...0.70), blue: 0.20, alpha: 0.7)
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + CGFloat.random(in: 5...12))
        default:
            // Mushroom
            let cap = SKShapeNode(circleOfRadius: 5)
            cap.fillColor = SKColor(red: 0.85, green: 0.25, blue: 0.20, alpha: 0.8)
            cap.strokeColor = .clear
            cap.position = CGPoint(x: x, y: groundY + 8)
            cap.zPosition = 1
            cap.name = "envDecor"
            addChild(cap)
            // Stem
            node = SKShapeNode(rectOf: CGSize(width: 3, height: 6))
            node.fillColor = SKColor(white: 0.9, alpha: 0.8)
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + 3)
        }

        node.zPosition = 1
        node.name = "envDecor"
        addChild(node)
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

                // Show floating score
                let floater = SKLabelNode(fontNamed: "AvenirNext-Bold")
                floater.text = "+\(aphid.points)"
                floater.fontSize = 14
                floater.fontColor = aphid.colorType == .red ? .red : (aphid.colorType == .yellow ? .yellow : .green)
                floater.position = aphid.position
                floater.zPosition = 50
                addChild(floater)
                let rise = SKAction.moveBy(x: 0, y: 30, duration: 0.5)
                let fade = SKAction.fadeOut(withDuration: 0.5)
                floater.run(SKAction.sequence([SKAction.group([rise, fade]), SKAction.removeFromParent()]))

                aphid.removeFromParent()
                ladybug.pulse()
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.bird {
            if !ladybug.isInvincible {
                takeDamage()
                // Remove the bird that hit
                let birdNode = (contact.bodyA.categoryBitMask == PhysicsCategory.bird)
                    ? contact.bodyA.node : contact.bodyB.node
                birdNode?.removeFromParent()
            }
        }
    }

    private func takeDamage() {
        guard !ladybug.isInvincible else { return }
        lives -= 1
        updateLivesDisplay()
        ladybug.flash()
        ladybug.makeInvincible(duration: 1.5)

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

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor(white: 0.0, alpha: 0.5)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 150
        addChild(overlay)

        let goLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goLabel.text = "Game Over"
        goLabel.fontSize = 40
        goLabel.fontColor = .white
        goLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        goLabel.zPosition = 200
        addChild(goLabel)

        let scoreText = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreText.text = "Score: \(score)"
        scoreText.fontSize = 24
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: size.width / 2, y: size.height / 2 - 5)
        scoreText.zPosition = 200
        addChild(scoreText)

        if score >= MenuScene.highScore && score > 0 {
            let newHigh = SKLabelNode(fontNamed: "AvenirNext-Bold")
            newHigh.text = "New High Score!"
            newHigh.fontSize = 18
            newHigh.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            newHigh.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
            newHigh.zPosition = 200
            addChild(newHigh)
        }

        let tapLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tapLabel.text = "Tap for menu"
        tapLabel.fontSize = 16
        tapLabel.fontColor = SKColor(white: 1.0, alpha: 0.6)
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 55)
        tapLabel.zPosition = 200
        addChild(tapLabel)
    }
}
