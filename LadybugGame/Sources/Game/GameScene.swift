import SpriteKit
import UIKit

class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {

    struct PhysicsCategory {
        static let none: UInt32       = 0
        static let ladybug: UInt32    = 0b00001
        static let aphid: UInt32      = 0b00010
        static let bird: UInt32       = 0b00100
        static let log: UInt32        = 0b01000
        static let fruitfly: UInt32   = 0b10000
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

    private var isGameOver = false
    private var isTouching = false
    private var touchY: CGFloat?
    private var lastUpdateTime: TimeInterval = 0

    private var aphidTimer: TimeInterval = 0
    private var flyTimer: TimeInterval = 0
    private var logTimer: TimeInterval = 0
    private var birdTimer: TimeInterval = 0
    private var envTimer: TimeInterval = 0

    // Cached textures
    private var birdTextures: [SKTexture] = []
    private var fruitFlyFrames: [SKTexture] = []
    private var aphidFrames: [TextureGenerator.AphidColor: [SKTexture]] = [:]
    private var logTexture: SKTexture!
    private var groundTiles: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.80, blue: 0.95, alpha: 1.0)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        groundY = size.height * 0.28

        // Cache textures
        birdTextures = TextureGenerator.generateBirdTextures(size: CGSize(width: 50, height: 36))
        logTexture = TextureGenerator.generateLogTexture(size: CGSize(width: 60, height: 50))
        fruitFlyFrames = TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 22, height: 22))
        for color in [TextureGenerator.AphidColor.green, .yellow, .red] {
            aphidFrames[color] = TextureGenerator.generateAphidWalkFrames(size: CGSize(width: 22, height: 22), color: color)
        }

        _ = SoundManager.shared // Init sounds

        setupSky()
        setupGround()
        setupHUD()
        spawnLadybug()
    }

    // MARK: - Setup

    private func setupSky() {
        // Gradient sky using layered rects
        let skyColors: [(y: CGFloat, h: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat)] = [
            (0.95, 0.10, 0.40, 0.68, 0.92),
            (0.85, 0.10, 0.48, 0.75, 0.94),
            (0.75, 0.10, 0.55, 0.80, 0.95),
        ]
        for sc in skyColors {
            let band = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height * sc.h))
            band.fillColor = SKColor(red: sc.r, green: sc.g, blue: sc.b, alpha: 1.0)
            band.strokeColor = .clear
            band.position = CGPoint(x: size.width / 2, y: size.height * sc.y)
            band.zPosition = -10
            addChild(band)
        }

        // Fluffy clouds (layered circles)
        for i in 0..<5 {
            let cloudGroup = SKNode()
            let numPuffs = Int.random(in: 3...5)
            for j in 0..<numPuffs {
                let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 12...25))
                puff.fillColor = SKColor(white: 1.0, alpha: CGFloat.random(in: 0.5...0.8))
                puff.strokeColor = .clear
                puff.position = CGPoint(x: CGFloat(j) * CGFloat.random(in: 14...22), y: CGFloat.random(in: -5...5))
                cloudGroup.addChild(puff)
            }
            let x = CGFloat(i) * size.width * 0.22 + CGFloat.random(in: 0...80)
            cloudGroup.position = CGPoint(x: x, y: size.height * CGFloat.random(in: 0.68...0.92))
            cloudGroup.zPosition = -6
            cloudGroup.name = "cloud"
            addChild(cloudGroup)
        }

        // Distant hills
        for i in 0..<4 {
            let hill = SKShapeNode()
            let path = UIBezierPath()
            let hillW = CGFloat.random(in: 180...300)
            let hillH = CGFloat.random(in: 25...50)
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: hillW, y: 0), controlPoint: CGPoint(x: hillW / 2, y: hillH))
            path.close()
            hill.path = path.cgPath
            hill.fillColor = SKColor(red: 0.38, green: 0.62, blue: 0.28, alpha: 0.35)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: CGFloat(i) * size.width * 0.3, y: groundY)
            hill.zPosition = -4
            hill.name = "hill"
            addChild(hill)
        }
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

            // Dirt
            let dirt = SKShapeNode(rectOf: CGSize(width: tileWidth, height: groundY * 0.45))
            dirt.fillColor = SKColor(red: 0.50, green: 0.35, blue: 0.18, alpha: 1.0)
            dirt.strokeColor = .clear
            dirt.position = CGPoint(x: tileWidth / 2, y: groundY * 0.225)
            tile.addChild(dirt)

            // Grass line
            let grass = SKShapeNode(rectOf: CGSize(width: tileWidth, height: 4))
            grass.fillColor = SKColor(red: 0.32, green: 0.55, blue: 0.20, alpha: 1.0)
            grass.strokeColor = .clear
            grass.position = CGPoint(x: tileWidth / 2, y: groundY)
            tile.addChild(grass)

            // Grass tufts
            for _ in 0..<10 {
                let tuft = SKShapeNode()
                let tp = UIBezierPath()
                let tw = CGFloat.random(in: 3...6)
                let th = CGFloat.random(in: 5...14)
                tp.move(to: CGPoint(x: 0, y: 0))
                tp.addQuadCurve(to: CGPoint(x: tw, y: 0), controlPoint: CGPoint(x: tw / 2, y: th))
                tp.close()
                tuft.path = tp.cgPath
                tuft.fillColor = SKColor(red: CGFloat.random(in: 0.35...0.50),
                                         green: CGFloat.random(in: 0.60...0.78),
                                         blue: CGFloat.random(in: 0.18...0.30), alpha: 0.7)
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
    }

    private func updateLivesDisplay() {
        var h = ""
        for i in 0..<3 { h += i < lives ? "♥" : "♡"; if i < 2 { h += " " } }
        livesLabel.text = h
    }

    private func spawnLadybug() {
        let bugSize = CGSize(width: 48, height: 48)
        let walkTex = TextureGenerator.generateLadybugTexture(size: bugSize)
        let glideTex = TextureGenerator.generateLadybugGlideTexture(size: bugSize)
        let blinkTex = TextureGenerator.generateLadybugBlinkTexture(size: bugSize)
        ladybug = Ladybug(walkTexture: walkTex, glideTexture: glideTex, blinkTexture: blinkTex)
        ladybug.position = CGPoint(x: size.width * 0.18, y: groundY + bugSize.height / 2)

        let body = SKPhysicsBody(circleOfRadius: bugSize.width / 2 * 0.6)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.ladybug
        body.contactTestBitMask = PhysicsCategory.aphid | PhysicsCategory.bird | PhysicsCategory.log | PhysicsCategory.fruitfly
        body.collisionBitMask = PhysicsCategory.none
        body.allowsRotation = false
        body.affectedByGravity = false
        ladybug.physicsBody = body
        addChild(ladybug)
    }

    // MARK: - Touch

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

        if lastUpdateTime == 0 { lastUpdateTime = currentTime; return }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        guard dt > 0, dt < 0.5 else { return }

        ladybug.targetY = isTouching ? touchY : nil

        let bugGroundY = groundY + ladybug.size.height / 2
        let ceilingY = size.height - ladybug.size.height / 2 - 10
        ladybug.updatePhysics(dt: dt, groundY: bugGroundY, ceilingY: ceilingY)

        // Log collision (on ground only)
        checkLogCollisions()

        // Scrolling
        distanceTraveled += scrollSpeed * CGFloat(dt)
        scrollSpeed = min(300, 160 + distanceTraveled * 0.002)
        let sd = scrollSpeed * CGFloat(dt)

        scrollGround(delta: sd)
        scrollParallax(delta: sd)
        scrollWorldObjects(delta: sd)

        // Spawns
        aphidTimer += dt
        if aphidTimer >= 1.2 { aphidTimer = 0; spawnAphid() }

        flyTimer += dt
        if flyTimer >= 1.5 { flyTimer = 0; spawnFruitFly() }

        logTimer += dt
        let li = max(2.5, 5.0 - Double(distanceTraveled) * 0.0003)
        if logTimer >= li { logTimer = 0; spawnLog() }

        birdTimer += dt
        let bi = max(2.0, 5.0 - Double(distanceTraveled) * 0.0004)
        if birdTimer >= bi { birdTimer = 0; spawnBird() }

        envTimer += dt
        if envTimer >= 1.5 { envTimer = 0; spawnEnvironment() }
    }

    private func checkLogCollisions() {
        guard ladybug.isOnGround, !ladybug.isInvincible else { return }
        for child in children {
            guard let log = child as? Log else { continue }
            let logLeft = log.position.x - log.size.width * 0.4
            let logRight = log.position.x + log.size.width * 0.4
            let bugRight = ladybug.position.x + ladybug.size.width * 0.3
            if bugRight > logLeft && ladybug.position.x < logRight {
                takeDamage()
                break
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
            node.position.x -= delta * 0.1
            if node.position.x < -150 {
                node.position.x = self.size.width + CGFloat.random(in: 50...150)
                node.position.y = self.size.height * CGFloat.random(in: 0.68...0.92)
            }
        }
        enumerateChildNodes(withName: "hill") { node, _ in
            node.position.x -= delta * 0.25
            if node.position.x < -350 { node.position.x = self.size.width + CGFloat.random(in: 50...200) }
        }
        enumerateChildNodes(withName: "envDecor") { node, _ in
            node.position.x -= delta
            if node.position.x < -50 { node.removeFromParent() }
        }
    }

    private func scrollWorldObjects(delta: CGFloat) {
        for child in children {
            if child is Aphid || child is FruitFly || child is Log || child is Bird {
                child.position.x -= delta
                if child.position.x < -120 { child.removeFromParent() }
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

        guard let frames = aphidFrames[color] else { return }
        let aphid = Aphid(walkFrames: frames, colorType: color)
        aphid.position = CGPoint(x: size.width + 30, y: groundY + aphid.size.height / 2)
        aphid.setupPhysics()
        aphid.startMoving()
        addChild(aphid)
    }

    private func spawnFruitFly() {
        let pts = [15, 20, 30].randomElement() ?? 15
        let fly = FruitFly(textures: fruitFlyFrames, points: pts)
        let y = groundY + CGFloat.random(in: 50...size.height * 0.55)
        fly.position = CGPoint(x: size.width + 30, y: y)
        fly.setupPhysics()
        fly.startMoving()
        addChild(fly)
    }

    private func spawnLog() {
        let log = Log(texture: logTexture)
        // Log sits ON the ground (bottom touching ground line)
        log.position = CGPoint(x: size.width + 50, y: groundY + log.size.height / 2)
        log.setupPhysics()
        addChild(log)
    }

    private func spawnBird() {
        let bird = Bird(textures: birdTextures)
        bird.position = CGPoint(x: size.width + 60, y: size.height * CGFloat.random(in: 0.55...0.85))
        bird.xScale = -1 // Face left
        bird.setupPhysics()
        addChild(bird)

        let targetY = ladybug.position.y
        bird.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                         targetY: targetY, duration: 2.0 + Double.random(in: 0...0.8))
    }

    private func spawnEnvironment() {
        let roll = Int.random(in: 0...3)
        let x = size.width + 30
        let node: SKShapeNode

        switch roll {
        case 0:
            node = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...5))
            node.fillColor = [SKColor.yellow, SKColor.magenta, SKColor.orange, SKColor.white].randomElement()!
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + CGFloat.random(in: 3...10))
        case 1:
            node = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 6...14), height: CGFloat.random(in: 4...8)), cornerRadius: 2)
            node.fillColor = SKColor(red: 0.55, green: 0.50, blue: 0.45, alpha: 0.6)
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + 2)
        case 2:
            node = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...14))
            node.fillColor = SKColor(red: 0.30, green: CGFloat.random(in: 0.55...0.70), blue: 0.20, alpha: 0.65)
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + CGFloat.random(in: 5...12))
        default:
            node = SKShapeNode(circleOfRadius: 4)
            node.fillColor = SKColor(red: 0.85, green: 0.25, blue: 0.20, alpha: 0.7)
            node.strokeColor = .clear
            node.position = CGPoint(x: x, y: groundY + 7)
        }
        node.zPosition = 1
        node.name = "envDecor"
        addChild(node)
    }

    // MARK: - Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.ladybug | PhysicsCategory.aphid {
            if let aphid = (contact.bodyA.node as? Aphid) ?? (contact.bodyB.node as? Aphid) {
                score += aphid.points
                showFloatingScore(aphid.points, at: aphid.position, color: aphid.colorType == .red ? .red : (aphid.colorType == .yellow ? .yellow : .green))
                aphid.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("eat")
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.fruitfly {
            if let fly = (contact.bodyA.node as? FruitFly) ?? (contact.bodyB.node as? FruitFly) {
                score += fly.points
                showFloatingScore(fly.points, at: fly.position, color: .cyan)
                fly.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("eatRare")
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.bird {
            if !ladybug.isInvincible {
                let birdNode = (contact.bodyA.categoryBitMask == PhysicsCategory.bird) ? contact.bodyA.node : contact.bodyB.node
                birdNode?.removeFromParent()
                takeDamage()
            }
        }
    }

    private func showFloatingScore(_ pts: Int, at pos: CGPoint, color: SKColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "+\(pts)"
        label.fontSize = 14
        label.fontColor = color
        label.position = pos
        label.zPosition = 50
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([SKAction.moveBy(x: 0, y: 30, duration: 0.5), SKAction.fadeOut(withDuration: 0.5)]),
            SKAction.removeFromParent()
        ]))
    }

    private func takeDamage() {
        guard !ladybug.isInvincible else { return }
        lives -= 1
        updateLivesDisplay()
        ladybug.flash()
        ladybug.makeInvincible()
        SoundManager.shared.play("hit")
        if lives <= 0 { gameOver() }
    }

    // MARK: - Game Over

    private func gameOver() {
        isGameOver = true
        SoundManager.shared.play("gameOver")

        if score > MenuScene.highScore { MenuScene.highScore = score }

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
            let nh = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nh.text = "New High Score!"
            nh.fontSize = 18
            nh.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            nh.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
            nh.zPosition = 200
            addChild(nh)
        }

        let tap = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tap.text = "Tap for menu"
        tap.fontSize = 16
        tap.fontColor = SKColor(white: 1.0, alpha: 0.6)
        tap.position = CGPoint(x: size.width / 2, y: size.height / 2 - 55)
        tap.zPosition = 200
        addChild(tap)
    }
}
