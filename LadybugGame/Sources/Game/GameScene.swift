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

    private var ladybug: Ladybug!
    private var groundY: CGFloat = 0
    private var scrollSpeed: CGFloat = 160
    private var distanceTraveled: CGFloat = 0

    private var scoreLabel: SKLabelNode!
    private var hasShownRainbow = false
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
            if score >= 1000 && !hasShownRainbow {
                hasShownRainbow = true
                showRainbow()
            }
        }
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

    private var birdTextures: [SKTexture] = []
    private var flyFrames: [TextureGenerator.FlyColor: [SKTexture]] = [:]
    private var dragonflyFrames: [SKTexture] = []
    private var fireflyFrames: [SKTexture] = []
    private var aphidFrames: [TextureGenerator.AphidColor: [SKTexture]] = [:]
    private var logTexture: SKTexture!
    private var frogTexture: SKTexture!
    private var frogTimer: TimeInterval = 0
    private var dragonflyTimer: TimeInterval = 0
    private var fireflyTimer: TimeInterval = 0
    private var groundTiles: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.80, blue: 0.95, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        groundY = size.height * 0.28

        birdTextures = TextureGenerator.generateBirdTextures(size: CGSize(width: 50, height: 36))
        logTexture = TextureGenerator.generateLogTexture(size: CGSize(width: 100, height: 55))
        frogTexture = TextureGenerator.generateFrogTexture(size: CGSize(width: 36, height: 32))
        dragonflyFrames = TextureGenerator.generateDragonflyFrames(size: CGSize(width: 48, height: 28))
        fireflyFrames = TextureGenerator.generateFireflyFrames(size: CGSize(width: 24, height: 24))
        for fc in [TextureGenerator.FlyColor.brown, .blue, .purple] {
            flyFrames[fc] = TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 22, height: 22), color: fc)
        }
        for color in [TextureGenerator.AphidColor.green, .yellow, .red] {
            aphidFrames[color] = TextureGenerator.generateAphidWalkFrames(size: CGSize(width: 22, height: 22), color: color)
        }
        _ = SoundManager.shared

        setupSky()
        setupGround()
        setupHUD()
        spawnLadybug()
    }

    // MARK: - Setup

    private func setupSky() {
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

        // Sunshine rays from top-right
        let sunX = size.width * 0.85
        let sunY = size.height * 0.95
        for i in 0..<6 {
            let ray = SKShapeNode()
            let rp = UIBezierPath()
            let angle = CGFloat(i) * 0.18 + 0.3
            let len = size.height * 0.7
            let width: CGFloat = 25 + CGFloat(i) * 8
            rp.move(to: .zero)
            rp.addLine(to: CGPoint(x: -cos(angle) * len - width / 2, y: -sin(angle) * len))
            rp.addLine(to: CGPoint(x: -cos(angle) * len + width / 2, y: -sin(angle) * len))
            rp.close()
            ray.path = rp.cgPath
            ray.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.70, alpha: CGFloat(0.06 - Double(i) * 0.005))
            ray.strokeColor = .clear
            ray.position = CGPoint(x: sunX, y: sunY)
            ray.zPosition = -7
            addChild(ray)
        }

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
            cloudGroup.position = CGPoint(x: CGFloat(i) * size.width * 0.22 + CGFloat.random(in: 0...80),
                                          y: size.height * CGFloat.random(in: 0.68...0.92))
            cloudGroup.zPosition = -6
            cloudGroup.name = "cloud"
            addChild(cloudGroup)
        }

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

            let dirt = SKShapeNode(rectOf: CGSize(width: tileWidth, height: groundY * 0.45))
            dirt.fillColor = SKColor(red: 0.50, green: 0.35, blue: 0.18, alpha: 1.0)
            dirt.strokeColor = .clear
            dirt.position = CGPoint(x: tileWidth / 2, y: groundY * 0.225)
            tile.addChild(dirt)

            let grass = SKShapeNode(rectOf: CGSize(width: tileWidth, height: 4))
            grass.fillColor = SKColor(red: 0.32, green: 0.55, blue: 0.20, alpha: 1.0)
            grass.strokeColor = .clear
            grass.position = CGPoint(x: tileWidth / 2, y: groundY)
            tile.addChild(grass)

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
        let blinkTex = TextureGenerator.generateLadybugBlinkTexture(size: bugSize)
        let flyFrames = TextureGenerator.generateLadybugFlyFrames(size: bugSize)
        ladybug = Ladybug(walkTexture: walkTex, blinkTexture: blinkTex, flyFrames: flyFrames)
        ladybug.position = CGPoint(x: size.width * 0.18, y: groundY + bugSize.height / 2)

        let body = SKPhysicsBody(circleOfRadius: bugSize.width / 2 * 0.6)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.ladybug
        body.contactTestBitMask = PhysicsCategory.aphid | PhysicsCategory.bird | PhysicsCategory.fruitfly
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
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchY = touch.location(in: self).y
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        touchY = nil
        ladybug.targetY = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        touchY = nil
        ladybug.targetY = nil
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
        var ceilingY = size.height - ladybug.size.height / 2 - 10

        // Check if inside a log — clamp ceiling to log top
        checkLogTube(bugGroundY: bugGroundY, ceilingY: &ceilingY)

        ladybug.updatePhysics(dt: dt, groundY: bugGroundY, ceilingY: ceilingY)

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
        let bi = max(2.5, 5.5 - Double(distanceTraveled) * 0.0003)
        if birdTimer >= bi { birdTimer = 0; spawnBird() }
        frogTimer += dt
        let fi = max(4.0, 8.0 - Double(distanceTraveled) * 0.0003)
        if frogTimer >= fi { frogTimer = 0; spawnFrog() }

        envTimer += dt
        dragonflyTimer += dt
        let dfi = max(5.0, 10.0 - Double(distanceTraveled) * 0.0003)
        if dragonflyTimer >= dfi { dragonflyTimer = 0; spawnDragonfly() }

        fireflyTimer += dt
        if fireflyTimer >= 15.0 { fireflyTimer = 0; spawnFirefly() }

        if envTimer >= 0.6 { envTimer = 0; spawnEnvironment() }
    }

    // MARK: - Log Tube Mechanic

    private func checkLogTube(bugGroundY: CGFloat, ceilingY: inout CGFloat) {
        var insideAny = false

        for child in children {
            guard let log = child as? Log else { continue }
            let tube = log.tubeRect
            let bugCenter = ladybug.position

            // Check if ladybug X overlaps the log
            let bugHalfW = ladybug.size.width * 0.3
            let bugRight = bugCenter.x + bugHalfW
            let bugLeft = bugCenter.x - bugHalfW

            if bugRight > tube.minX && bugLeft < tube.maxX {
                let logTopY = log.position.y + log.size.height
                if ladybug.isOnGround || bugCenter.y < logTopY {
                    insideAny = true
                    log.showSeeThrough()
                    ceilingY = min(ceilingY, logTopY)
                } else {
                    log.showOpaque()
                }
            } else {
                log.showOpaque()
            }
        }

        ladybug.isInsideLog = insideAny
    }

    // MARK: - Scrolling

    private func scrollGround(delta: CGFloat) {
        for tile in groundTiles {
            tile.position.x -= delta
            if tile.position.x + tile.size.width < 0 {
                let maxX = groundTiles.map { $0.position.x }.max() ?? 0
                tile.position.x = maxX + tile.size.width - 1 // 1px overlap to prevent gaps
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
            if child is Aphid || child is FruitFly || child is Log || child is Bird || child is Frog || child is Dragonfly || child is Firefly {
                child.position.x -= delta
                if child.position.x < -120 { child.removeFromParent() }
            }
        }
    }

    // MARK: - Spawning

    private func isInsideAnyLog(x: CGFloat) -> Bool {
        for child in children {
            guard let log = child as? Log else { continue }
            let logLeft = log.position.x - log.size.width * 0.5
            let logRight = log.position.x + log.size.width * 0.5
            if x > logLeft && x < logRight { return true }
        }
        return false
    }

    private func spawnAphid() {
        let spawnX = size.width + 30
        // Don't spawn inside a log
        if isInsideAnyLog(x: spawnX) { return }

        let roll = Int.random(in: 0..<100)
        let color: TextureGenerator.AphidColor
        if roll < 55 { color = .green }
        else if roll < 82 { color = .yellow }
        else { color = .red }

        guard let frames = aphidFrames[color] else { return }
        let aphid = Aphid(walkFrames: frames, colorType: color)
        aphid.position = CGPoint(x: spawnX, y: groundY + aphid.size.height / 2)
        aphid.setupPhysics()
        aphid.startMoving()
        addChild(aphid)
    }

    private func spawnFruitFly() {
        let roll = Int.random(in: 0..<100)
        let fc: TextureGenerator.FlyColor
        if roll < 50 { fc = .brown }
        else if roll < 80 { fc = .blue }
        else { fc = .purple }

        guard let frames = flyFrames[fc] else { return }
        let fly = FruitFly(textures: frames, colorType: fc)
        let y = groundY + CGFloat.random(in: 50...size.height * 0.50)
        fly.position = CGPoint(x: size.width + 30, y: y)
        fly.minY = groundY
        fly.setupPhysics()
        fly.startMoving()
        addChild(fly)
    }

    private func spawnDragonfly() {
        let df = Dragonfly(textures: dragonflyFrames)
        let y = groundY + CGFloat.random(in: 60...size.height * 0.55)
        df.position = CGPoint(x: size.width + 50, y: y)
        df.setupPhysics()
        df.startHovering(minY: groundY + 40, maxY: size.height * 0.70)
        addChild(df)
    }

    private func spawnFirefly() {
        let ff = Firefly(textures: fireflyFrames)
        let y = groundY + CGFloat.random(in: 40...size.height * 0.50)
        ff.position = CGPoint(x: size.width + 30, y: y)
        ff.setupPhysics()
        ff.startMoving(minY: groundY + 30, maxY: size.height * 0.65)
        addChild(ff)
    }

    private func spawnLog() {
        let spawnX = size.width + 80
        if isNearGroundObject(x: spawnX, range: 100) { return }
        let logWidth = CGFloat.random(in: 80...160)
        let log = Log(texture: logTexture, width: logWidth)
        log.position = CGPoint(x: spawnX, y: groundY - 1)
        log.setupPhysics()
        addChild(log)
    }

    private func isNearGroundObject(x: CGFloat, range: CGFloat) -> Bool {
        for child in children {
            if child is Log || child is Frog {
                if abs(child.position.x - x) < range { return true }
            }
        }
        return false
    }

    private func spawnBird() {
        let bird = Bird(textures: birdTextures)
        bird.position = CGPoint(x: size.width + 60, y: size.height * CGFloat.random(in: 0.50...0.88))
        bird.xScale = -1
        bird.setupPhysics()
        addChild(bird)

        // Faster, more aggressive swoop — targets ladybug directly
        let targetY = ladybug.position.y
        SoundManager.shared.play("caw")
        bird.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                         targetY: targetY, duration: 1.4 + Double.random(in: 0...0.6))

        // Sometimes send a second bird right after
        if distanceTraveled > 2000 && Bool.random() {
            let bird2 = Bird(textures: birdTextures)
            bird2.position = CGPoint(x: size.width + 120, y: size.height * CGFloat.random(in: 0.50...0.85))
            bird2.xScale = -1
            bird2.setupPhysics()
            addChild(bird2)
            bird2.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                             targetY: ladybug.position.y + CGFloat.random(in: -30...30),
                             duration: 1.6 + Double.random(in: 0...0.5))
        }
    }

    private func spawnFrog() {
        let spawnX = size.width + 50
        if isNearGroundObject(x: spawnX, range: 120) { return }

        // Pond behind the frog
        let pondW = CGFloat.random(in: 70...120)
        let pond = SKShapeNode(ellipseOf: CGSize(width: pondW, height: 14))
        pond.fillColor = SKColor(red: 0.25, green: 0.50, blue: 0.70, alpha: 0.6)
        pond.strokeColor = SKColor(red: 0.20, green: 0.40, blue: 0.55, alpha: 0.5)
        pond.lineWidth = 1
        pond.position = CGPoint(x: spawnX, y: groundY + 2)
        pond.zPosition = 2
        pond.name = "envDecor"
        addChild(pond)

        // Lily pads on pond
        for i in 0..<Int.random(in: 1...3) {
            let pad = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...8))
            pad.fillColor = SKColor(red: 0.30, green: 0.68, blue: 0.25, alpha: 0.7)
            pad.strokeColor = SKColor(red: 0.22, green: 0.50, blue: 0.18, alpha: 0.5)
            pad.lineWidth = 0.5
            let padX = CGFloat(i - 1) * CGFloat.random(in: 10...18)
            pad.position = CGPoint(x: spawnX + padX, y: groundY + CGFloat.random(in: 1...5))
            pad.zPosition = 3
            pad.name = "envDecor"
            addChild(pad)
        }

        let frog = Frog(texture: frogTexture)
        frog.position = CGPoint(x: spawnX + pondW * 0.3, y: groundY + frog.size.height / 2)
        addChild(frog)

        let checkDistance = SKAction.run { [weak self, weak frog] in
            guard let self = self, let frog = frog else { return }
            // Face toward player
            if self.ladybug.position.x < frog.position.x {
                frog.xScale = -abs(frog.xScale) // Face left
            } else {
                frog.xScale = abs(frog.xScale) // Face right
            }

            let dist = abs(frog.position.x - self.ladybug.position.x)
            if dist < 130 {
                SoundManager.shared.play("ribbit")
                frog.attackToward(sceneTarget: self.ladybug.position, groundY: self.groundY)
            }
        }
        let wait = SKAction.wait(forDuration: 0.3)
        frog.run(SKAction.repeatForever(SKAction.sequence([wait, checkDistance])), withKey: "checkAttack")
    }

    private func spawnEnvironment() {
        let roll = Int.random(in: 0...6)
        let x = size.width + 30

        switch roll {
        case 0: // Flower
            let stem = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 8...16)))
            stem.fillColor = SKColor(red: 0.30, green: 0.55, blue: 0.22, alpha: 0.7)
            stem.strokeColor = .clear
            let sh = stem.frame.height
            stem.position = CGPoint(x: x, y: groundY + sh / 2)
            stem.zPosition = 1
            stem.name = "envDecor"
            addChild(stem)
            let petal = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            petal.fillColor = [SKColor.yellow, SKColor.magenta, SKColor.orange, SKColor.white, SKColor.systemPink].randomElement()!
            petal.strokeColor = .clear
            petal.position = CGPoint(x: x, y: groundY + sh + 2)
            petal.zPosition = 1
            petal.name = "envDecor"
            addChild(petal)
        case 1: // Rock
            let rock = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 6...16), height: CGFloat.random(in: 4...9)), cornerRadius: 3)
            rock.fillColor = SKColor(red: CGFloat.random(in: 0.45...0.60), green: CGFloat.random(in: 0.42...0.55), blue: CGFloat.random(in: 0.38...0.50), alpha: 0.7)
            rock.strokeColor = .clear
            rock.position = CGPoint(x: x, y: groundY + 2)
            rock.zPosition = 1
            rock.name = "envDecor"
            addChild(rock)
        case 2: // Bush
            let bush = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...16))
            bush.fillColor = SKColor(red: 0.28, green: CGFloat.random(in: 0.52...0.70), blue: 0.18, alpha: 0.65)
            bush.strokeColor = .clear
            bush.position = CGPoint(x: x, y: groundY + CGFloat.random(in: 5...12))
            bush.zPosition = 1
            bush.name = "envDecor"
            addChild(bush)
        case 3: // Mushroom
            let mStem = SKShapeNode(rectOf: CGSize(width: 3, height: 6))
            mStem.fillColor = SKColor(white: 0.88, alpha: 0.8)
            mStem.strokeColor = .clear
            mStem.position = CGPoint(x: x, y: groundY + 3)
            mStem.zPosition = 1
            mStem.name = "envDecor"
            addChild(mStem)
            let cap = SKShapeNode(circleOfRadius: 5)
            cap.fillColor = SKColor(red: 0.85, green: 0.22, blue: 0.18, alpha: 0.8)
            cap.strokeColor = .clear
            cap.position = CGPoint(x: x, y: groundY + 8)
            cap.zPosition = 1
            cap.name = "envDecor"
            addChild(cap)
        case 4: // Tall grass clump
            for j in 0..<3 {
                let blade = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 12...22)))
                blade.fillColor = SKColor(red: 0.35, green: CGFloat.random(in: 0.60...0.75), blue: 0.22, alpha: 0.6)
                blade.strokeColor = .clear
                blade.position = CGPoint(x: x + CGFloat(j) * 3, y: groundY + blade.frame.height / 2)
                blade.zRotation = CGFloat.random(in: -0.15...0.15)
                blade.zPosition = 1
                blade.name = "envDecor"
                addChild(blade)
            }
        case 5: // Small dirt mound
            let mound = SKShapeNode()
            let mp = UIBezierPath()
            let mw = CGFloat.random(in: 15...30)
            let mh = CGFloat.random(in: 4...8)
            mp.move(to: CGPoint(x: 0, y: 0))
            mp.addQuadCurve(to: CGPoint(x: mw, y: 0), controlPoint: CGPoint(x: mw / 2, y: mh))
            mp.close()
            mound.path = mp.cgPath
            mound.fillColor = SKColor(red: 0.48, green: 0.35, blue: 0.18, alpha: 0.5)
            mound.strokeColor = .clear
            mound.position = CGPoint(x: x - mw / 2, y: groundY)
            mound.zPosition = 1
            mound.name = "envDecor"
            addChild(mound)
        default: // Dandelion
            let stem = SKShapeNode(rectOf: CGSize(width: 1, height: CGFloat.random(in: 10...18)))
            stem.fillColor = SKColor(red: 0.35, green: 0.55, blue: 0.25, alpha: 0.5)
            stem.strokeColor = .clear
            let sh = stem.frame.height
            stem.position = CGPoint(x: x, y: groundY + sh / 2)
            stem.zPosition = 1
            stem.name = "envDecor"
            addChild(stem)
            let puff = SKShapeNode(circleOfRadius: 4)
            puff.fillColor = SKColor(white: 1.0, alpha: 0.5)
            puff.strokeColor = .clear
            puff.position = CGPoint(x: x, y: groundY + sh + 3)
            puff.zPosition = 1
            puff.name = "envDecor"
            addChild(puff)
        }
    }

    // MARK: - Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.ladybug | PhysicsCategory.aphid {
            if let aphid = (contact.bodyA.node as? Aphid) ?? (contact.bodyB.node as? Aphid) {
                score += aphid.points
                showFloatingScore(aphid.points, at: aphid.position,
                    color: aphid.colorType == .red ? .red : (aphid.colorType == .yellow ? .yellow : .green))
                aphid.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("munch")
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.fruitfly {
            // Check firefly first
            if let ff = (contact.bodyA.node as? Firefly) ?? (contact.bodyB.node as? Firefly) {
                score += 100
                showFloatingScore(100, at: ff.position, color: SKColor(red: 1.0, green: 0.95, blue: 0.3, alpha: 1.0))
                ff.removeFromParent()
                ladybug.makeInvincible(duration: 10.0)
                ladybug.pulse()
                SoundManager.shared.play("eatRare")

                // Visual: golden glow while invincible
                let glow = SKShapeNode(circleOfRadius: 30)
                glow.fillColor = SKColor(red: 1.0, green: 0.92, blue: 0.30, alpha: 0.2)
                glow.strokeColor = SKColor(red: 1.0, green: 0.90, blue: 0.20, alpha: 0.4)
                glow.lineWidth = 1.5
                glow.zPosition = -1
                glow.name = "fireflyGlow"
                ladybug.addChild(glow)
                glow.run(SKAction.sequence([
                    SKAction.wait(forDuration: 9.0),
                    SKAction.repeat(SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.1, duration: 0.2),
                        SKAction.fadeAlpha(to: 0.5, duration: 0.2)
                    ]), count: 5),
                    SKAction.removeFromParent()
                ]))
            } else if let fly = (contact.bodyA.node as? FruitFly) ?? (contact.bodyB.node as? FruitFly) {
                score += fly.points
                let c: SKColor = fly.colorType == .purple ? .purple : (fly.colorType == .blue ? .cyan : .orange)
                showFloatingScore(fly.points, at: fly.position, color: c)
                fly.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("eatRare")
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.bird {
            // Safe inside log!
            if ladybug.isSheltered { return }
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

    private func showRainbow() {
        let colors: [SKColor] = [
            SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25),
            SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.25),
            SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.25),
            SKColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 0.25),
            SKColor(red: 0.0, green: 0.4, blue: 1.0, alpha: 0.25),
            SKColor(red: 0.3, green: 0.0, blue: 0.8, alpha: 0.25),
        ]
        let arcCenterX = size.width * 0.5
        let arcCenterY = groundY
        let baseRadius = size.height * 0.55

        for (i, color) in colors.enumerated() {
            let radius = baseRadius - CGFloat(i) * 8
            let arc = SKShapeNode()
            let path = UIBezierPath(arcCenter: .zero, radius: radius,
                                     startAngle: 0, endAngle: .pi, clockwise: true)
            arc.path = path.cgPath
            arc.strokeColor = color
            arc.lineWidth = 6
            arc.fillColor = .clear
            arc.position = CGPoint(x: arcCenterX, y: arcCenterY)
            arc.zPosition = -3
            arc.alpha = 0
            arc.name = "rainbow"
            addChild(arc)

            arc.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.15),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ]))
        }

        // Flash notification
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "1000 Points!"
        label.fontSize = 28
        label.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        label.zPosition = 80
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([SKAction.moveBy(x: 0, y: 20, duration: 1.5), SKAction.fadeOut(withDuration: 1.5)]),
            SKAction.removeFromParent()
        ]))
    }

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
