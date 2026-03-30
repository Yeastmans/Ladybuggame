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
    private var currentBiome: Biome = .meadowDay
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
            if score >= 500 && !hasShownRainbow {
                hasShownRainbow = true
                showRainbow()
            }
            // Biome transitions + checkpoint save
            let newBiome = Biome.biome(for: score)
            if newBiome != currentBiome {
                transitionToBiome(newBiome)
                currentBiome = newBiome
                // Save checkpoint at every biome transition
                GameScene.hasNightCheckpoint = true
                GameScene.checkpointScore = newBiome.scoreThreshold
                GameScene.unlockBiome(newBiome)
            }
        }
    }
    private var lives: Int = 3
    private var livesLabel: SKLabelNode!

    private static let nightCheckpointKey = "NightCheckpointReached"
    static var hasNightCheckpoint: Bool {
        get { UserDefaults.standard.bool(forKey: nightCheckpointKey) }
        set { UserDefaults.standard.set(newValue, forKey: nightCheckpointKey) }
    }
    private static let checkpointScoreKey = "CheckpointScore"
    static var checkpointScore: Int {
        get { UserDefaults.standard.integer(forKey: checkpointScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: checkpointScoreKey) }
    }
    private static let unlockedBiomesKey = "UnlockedBiomes"
    static var unlockedBiomes: [Int] {
        get { UserDefaults.standard.array(forKey: unlockedBiomesKey) as? [Int] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: unlockedBiomesKey) }
    }
    static func unlockBiome(_ biome: Biome) {
        var biomes = unlockedBiomes
        if !biomes.contains(biome.rawValue) {
            biomes.append(biome.rawValue)
            unlockedBiomes = biomes
        }
    }
    var startFromCheckpoint = false

    private var isGameOver = false
    private var isPaused_ = false
    private var isNight = false
    private var hasTransitionedToNight = false
    private var isTouching = false
    private var gnatTimer: TimeInterval = 0
    private var touchY: CGFloat?
    private var lastUpdateTime: TimeInterval = 0

    private var aphidTimer: TimeInterval = 0
    private var flyTimer: TimeInterval = 0
    private var logTimer: TimeInterval = 0
    private var birdTimer: TimeInterval = 0
    private var envTimer: TimeInterval = 0

    private var birdTextures: [SKTexture] = []
    private var batFrames: [SKTexture] = []
    private var vultureFrames: [SKTexture] = []
    private var hawkFrames: [SKTexture] = []
    private var owlFrames: [SKTexture] = []
    private var toucanFrames: [SKTexture] = []
    private var flyFrames: [TextureGenerator.FlyColor: [SKTexture]] = [:]
    private var dragonflyFrames: [SKTexture] = []
    private var fireflyFrames: [SKTexture] = []
    private var heartBugFrames: [SKTexture] = []
    private var antFrames: [SKTexture] = []
    private var spiderFrames: [SKTexture] = []
    private var jungleSpiderFrames: [SKTexture] = []
    private var aphidFrames: [TextureGenerator.AphidColor: [SKTexture]] = [:]
    private var logTexture: SKTexture!
    private var frogTexture: SKTexture!
    private var toadTexture: SKTexture!
    private var poisonDartFrogTexture: SKTexture!
    private var deadTexture: SKTexture!
    private var frogTimer: TimeInterval = 0
    private var dragonflyTimer: TimeInterval = 0
    private var fireflyTimer: TimeInterval = 0
    private var antTimer: TimeInterval = 0
    private var spiderTimer: TimeInterval = 0
    private var heartBugTimer: TimeInterval = 0
    private var groundTiles: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.80, blue: 0.95, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        groundY = size.height * 0.28

        birdTextures = TextureGenerator.generateBirdTextures(size: CGSize(width: 50, height: 36))
        vultureFrames = TextureGenerator.generateVultureFrames(size: CGSize(width: 56, height: 40))
        batFrames = TextureGenerator.generateBatFrames(size: CGSize(width: 50, height: 36))
        hawkFrames = TextureGenerator.generateHawkFrames(size: CGSize(width: 54, height: 38))
        owlFrames = TextureGenerator.generateOwlFrames(size: CGSize(width: 50, height: 38))
        toucanFrames = TextureGenerator.generateToucanFrames(size: CGSize(width: 54, height: 36))
        logTexture = TextureGenerator.generateLogTexture(size: CGSize(width: 70, height: 45))
        frogTexture = TextureGenerator.generateFrogTexture(size: CGSize(width: 36, height: 32))
        toadTexture = TextureGenerator.generateToadTexture(size: CGSize(width: 36, height: 32))
        poisonDartFrogTexture = TextureGenerator.generatePoisonDartFrogTexture(size: CGSize(width: 36, height: 32))
        deadTexture = TextureGenerator.generateLadybugDeadTexture(size: CGSize(width: 48, height: 48))
        dragonflyFrames = TextureGenerator.generateDragonflyFrames(size: CGSize(width: 48, height: 28))
        fireflyFrames = TextureGenerator.generateFireflyFrames(size: CGSize(width: 24, height: 24))
        heartBugFrames = TextureGenerator.generateHeartBugFrames(size: CGSize(width: 36, height: 36))
        antFrames = TextureGenerator.generateAntFrames(size: CGSize(width: 20, height: 18))
        spiderFrames = TextureGenerator.generateSpiderFrames(size: CGSize(width: 48, height: 40))
        jungleSpiderFrames = TextureGenerator.generateJungleSpiderFrames(size: CGSize(width: 48, height: 40))
        for fc in [TextureGenerator.FlyColor.brown, .blue, .purple] {
            flyFrames[fc] = TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 22, height: 22), color: fc)
        }
        for color in [TextureGenerator.AphidColor.green, .yellow, .red] {
            aphidFrames[color] = TextureGenerator.generateAphidWalkFrames(size: CGSize(width: 22, height: 22), color: color)
        }
        _ = SoundManager.shared
        SoundManager.shared.startMusic()

        setupSky()
        setupGround()
        setupHUD()
        spawnLadybug()

        if startFromCheckpoint {
            let cpScore = GameScene.checkpointScore
            let biome = Biome.biome(for: cpScore)
            hasShownRainbow = true // Don't show rainbow on resume
            hasTransitionedToNight = true // Don't re-trigger night transition
            currentBiome = biome
            score = biome.scoreThreshold
            if biome != .meadowDay {
                transitionToBiome(biome)
            }
        }
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
        let tileWidth = size.width + 10 // Extra width to guarantee overlap
        for i in 0..<3 {
            let tile = SKSpriteNode(color: SKColor(red: 0.42, green: 0.68, blue: 0.28, alpha: 1.0),
                                    size: CGSize(width: tileWidth, height: groundY + 2))
            tile.anchorPoint = CGPoint(x: 0, y: 0)
            tile.position = CGPoint(x: CGFloat(i) * (tileWidth - 10), y: 0)
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

        // Pause button
        let pauseBtn = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pauseBtn.text = "❚❚"
        pauseBtn.fontSize = 20
        pauseBtn.fontColor = SKColor(white: 1.0, alpha: 0.7)
        pauseBtn.horizontalAlignmentMode = .center
        pauseBtn.verticalAlignmentMode = .center
        pauseBtn.position = CGPoint(x: size.width / 2, y: size.height - 28)
        pauseBtn.zPosition = 100
        pauseBtn.name = "pauseButton"
        addChild(pauseBtn)
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
        let loc = touch.location(in: self)

        // Check pause button tap
        let tappedNodes = nodes(at: loc)
        for node in tappedNodes {
            if node.name == "pauseButton" || node.name == "pauseOverlay" || node.name == "resumeLabel" {
                togglePause()
                return
            }
        }

        if isPaused_ { return }
        isTouching = true
        touchY = loc.y
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused_ { return }
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
        guard !isGameOver, !isPaused_ else { return }
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

        pushEntitiesFromLogs()
        checkPondSplash()
        checkSpiderJumps()

        // Scrolling
        distanceTraveled += scrollSpeed * CGFloat(dt)
        scrollSpeed = min(300, 160 + distanceTraveled * 0.002)
        let sd = scrollSpeed * CGFloat(dt)

        scrollGround(delta: sd)
        scrollParallax(delta: sd)
        scrollWorldObjects(delta: sd)

        // Biome-aware spawning
        spawnForBiome(dt: dt)
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

    private var lastSplashTime: TimeInterval = 0
    private func checkPondSplash() {
        guard ladybug.isOnGround else { return }
        enumerateChildNodes(withName: "pond") { [weak self] node, stop in
            guard let self = self else { return }
            let pondHalfW = node.frame.width / 2
            if abs(node.position.x - self.ladybug.position.x) < pondHalfW {
                // Cosmetic splash only — no damage
                if self.lastUpdateTime - self.lastSplashTime > 1.0 {
                    self.lastSplashTime = self.lastUpdateTime
                    SoundManager.shared.play("splash")
                }
                stop.pointee = true
            }
        }
    }



    private func checkSpiderJumps() {
        for child in children {
            if let spider = child as? Spider {
                spider.jumpIfPlayerNear(playerX: ladybug.position.x)
            }
            if let enemy = child as? BiomeEnemy {
                enemy.lungeIfNear(playerX: ladybug.position.x)
            }
        }
    }

    private func pushEntitiesFromLogs() {
        for child in children {
            guard let log = child as? Log else { continue }
            let logLeft = log.position.x - log.size.width * 0.5
            let logRight = log.position.x + log.size.width * 0.5
            let logTop = log.position.y + log.size.height

            for entity in children {
                let isFlyer = entity is FruitFly || entity is Dragonfly || entity is Firefly || entity is HeartBug || entity is Bird
                guard isFlyer else { continue }
                let ex = entity.position.x
                let ey = entity.position.y

                // If entity is inside the log's X range and below log top, push up
                if ex > logLeft && ex < logRight && ey < logTop && ey > log.position.y {
                    entity.position.y = logTop + 5
                }
            }
        }
    }

    // MARK: - Scrolling

    private func scrollGround(delta: CGFloat) {
        let tileStride = (groundTiles.first?.size.width ?? size.width) - 10
        for tile in groundTiles {
            tile.position.x -= delta
            if tile.position.x + tile.size.width < 0 {
                let maxX = groundTiles.map { $0.position.x }.max() ?? 0
                tile.position.x = round(maxX + tileStride)
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
        enumerateChildNodes(withName: "pond") { node, _ in
            node.position.x -= delta
            if node.position.x < -80 { node.removeFromParent() }
        }
    }

    private func scrollWorldObjects(delta: CGFloat) {
        for child in children {
            if child is Aphid || child is FruitFly || child is Log || child is Bird || child is Frog || child is Dragonfly || child is Firefly || child is HeartBug || child is Ant || child is Spider || child is GnatSwarm || child is BiomeFood || child is BiomeEnemy || child is BiomeSwooper {
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
        if isInsideAnyLog(x: spawnX) || isNearGroundObject(x: spawnX, range: 60) { return }

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

    private func spawnHeartBug() {
        let hb = HeartBug(textures: heartBugFrames)
        let y = groundY + CGFloat.random(in: 40...size.height * 0.45)
        hb.position = CGPoint(x: size.width + 30, y: y)
        hb.minY = groundY
        hb.setupPhysics()
        hb.startMoving { [weak self] in self?.ladybug.position }
        addChild(hb)
    }

    private func spawnDragonfly() {
        let df = Dragonfly(textures: dragonflyFrames)
        let y = groundY + CGFloat.random(in: 60...size.height * 0.55)
        df.position = CGPoint(x: size.width + 50, y: y)
        df.setupPhysics()
        df.startHovering(minY: groundY + 50, maxY: size.height * 0.70, playerX: ladybug.position.x)
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
        let logWidth = CGFloat.random(in: 60...110)
        let log = Log(texture: logTexture, width: logWidth)
        log.position = CGPoint(x: spawnX, y: groundY - 3)
        log.setupPhysics()
        addChild(log)
    }

    private func isNearGroundObject(x: CGFloat, range: CGFloat) -> Bool {
        for child in children {
            if child is Log || child is Frog || child is Ant || child is Spider || child.name == "pond" {
                if abs(child.position.x - x) < range { return true }
            }
        }
        return false
    }

    private func spawnBird() {
        let bird = Bird(textures: birdTextures)
        bird.position = CGPoint(x: size.width + 60, y: size.height * CGFloat.random(in: 0.70...0.95))
        bird.xScale = -1
        bird.setupPhysics()

        // At night: bat coloring (dark purple/black)
        if isNight {
            bird.colorBlendFactor = 0.6
            bird.color = SKColor(red: 0.15, green: 0.08, blue: 0.25, alpha: 1.0)
        }

        addChild(bird)

        let targetY = groundY + ladybug.size.height / 2 + CGFloat.random(in: 0...15)
        SoundManager.shared.play("caw")
        bird.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                         targetY: targetY, groundY: groundY,
                         duration: isNight ? 1.4 + Double.random(in: 0...0.4) : 1.6 + Double.random(in: 0...0.5))
        bird.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.run {
            SoundManager.shared.play("whoosh")
        }]))
    }

    /// Spawns a pond with either a frog or dragonfly (never both)
    private func spawnPondCreature() {
        let spawnX = size.width + 50
        if isNearGroundObject(x: spawnX, range: 120) { return }

        // Pond
        let pondW = CGFloat.random(in: 70...120)
        let pond = SKShapeNode(ellipseOf: CGSize(width: pondW, height: 14))
        pond.fillColor = isNight
            ? SKColor(red: 0.15, green: 0.30, blue: 0.50, alpha: 0.5)
            : SKColor(red: 0.25, green: 0.50, blue: 0.70, alpha: 0.6)
        pond.strokeColor = SKColor(red: 0.20, green: 0.40, blue: 0.55, alpha: 0.5)
        pond.lineWidth = 1
        pond.position = CGPoint(x: spawnX, y: groundY + 2)
        pond.zPosition = 2
        pond.name = "pond"
        addChild(pond)

        for i in 0..<Int.random(in: 1...3) {
            let pad = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...8))
            pad.fillColor = SKColor(red: 0.30, green: 0.68, blue: 0.25, alpha: 0.7)
            pad.strokeColor = .clear
            pad.position = CGPoint(x: spawnX + CGFloat(i - 1) * CGFloat.random(in: 10...18),
                                    y: groundY + CGFloat.random(in: 1...5))
            pad.zPosition = 3
            pad.name = "envDecor"
            addChild(pad)
        }

        // At night: always toad, no dragonfly
        // Jungle: always poison dart frog, no dragonfly
        // Day: 60% frog, 40% dragonfly
        let spawnFrogHere = isNight || currentBiome == .jungle || Int.random(in: 0..<10) < 6
        if spawnFrogHere {
            let tex: SKTexture
            if currentBiome == .jungle {
                tex = poisonDartFrogTexture
            } else if isNight || currentBiome == .meadowNight {
                tex = toadTexture
            } else {
                tex = frogTexture
            }
            let frog = Frog(texture: tex)
            frog.position = CGPoint(x: spawnX + pondW * 0.3, y: groundY + frog.size.height / 2)
            addChild(frog)

            let checkDistance = SKAction.run { [weak self, weak frog] in
                guard let self = self, let frog = frog else { return }
                if self.ladybug.position.x < frog.position.x {
                    frog.xScale = -abs(frog.xScale)
                } else {
                    frog.xScale = abs(frog.xScale)
                }
                let dist = abs(frog.position.x - self.ladybug.position.x)
                if dist < 130 {
                    SoundManager.shared.play("ribbit")
                    frog.attackToward(playerPos: self.ladybug.position)
                }
            }
            frog.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.3), checkDistance])), withKey: "checkAttack")
        } else {
            // Dragonfly hovering above the pond
            let df = Dragonfly(textures: dragonflyFrames)
            df.position = CGPoint(x: spawnX, y: groundY + CGFloat.random(in: 80...size.height * 0.55))
            df.setupPhysics()
            df.startHovering(minY: groundY + 60, maxY: size.height * 0.65, playerX: ladybug.position.x)
            addChild(df)
        }
    }

    private func spawnAnt() {
        let spawnX = size.width + 30
        if isNearGroundObject(x: spawnX, range: 100) { return } // Wide range to avoid ponds
        let ant = Ant(walkFrames: antFrames)
        ant.position = CGPoint(x: spawnX, y: groundY + ant.size.height / 2)
        ant.setupPhysics()
        ant.startPatrolling()
        addChild(ant)
    }

    private func spawnSpider() {
        let spawnX = size.width + 40
        if isNearGroundObject(x: spawnX, range: 80) { return }
        let spider = Spider(walkFrames: spiderFrames)
        spider.position = CGPoint(x: spawnX, y: groundY + spider.size.height / 2)
        spider.setupPhysics()
        spider.startCrawling()
        addChild(spider)
    }

    private func spawnEnvironment() {
        let x = size.width + 30

        switch currentBiome {
        case .meadowDay:
            spawnMeadowDecor(x: x)
        case .meadowNight:
            spawnNightDecor(x: x)
        case .desert:
            spawnDesertDecor(x: x)
        case .snow:
            spawnSnowDecor(x: x)
        case .jungle:
            spawnJungleDecor(x: x)
        }
    }

    private func addDecor(_ node: SKShapeNode, x: CGFloat, y: CGFloat) {
        node.strokeColor = .clear
        node.position = CGPoint(x: x, y: y)
        node.zPosition = 1
        node.name = "envDecor"
        addChild(node)
    }

    private func spawnMeadowDecor(x: CGFloat) {
        let roll = Int.random(in: 0...4)
        switch roll {
        case 0: // Flower
            let stem = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 8...16)))
            stem.fillColor = SKColor(red: 0.30, green: 0.55, blue: 0.22, alpha: 0.7)
            addDecor(stem, x: x, y: groundY + stem.frame.height / 2)
            let petal = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            petal.fillColor = [.yellow, .magenta, .orange, .white].randomElement()!
            addDecor(petal, x: x, y: groundY + stem.frame.height + 2)
        case 1: // Rock
            let rock = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 6...14), height: CGFloat.random(in: 4...8)), cornerRadius: 3)
            rock.fillColor = SKColor(red: 0.52, green: 0.48, blue: 0.44, alpha: 0.7)
            addDecor(rock, x: x, y: groundY + 2)
        case 2: // Bush
            let bush = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...14))
            bush.fillColor = SKColor(red: 0.28, green: CGFloat.random(in: 0.55...0.70), blue: 0.18, alpha: 0.65)
            addDecor(bush, x: x, y: groundY + CGFloat.random(in: 5...10))
        case 3: // Mushroom
            let cap = SKShapeNode(circleOfRadius: 5)
            cap.fillColor = SKColor(red: 0.85, green: 0.22, blue: 0.18, alpha: 0.8)
            addDecor(cap, x: x, y: groundY + 8)
        default: // Grass
            for j in 0..<3 {
                let blade = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 10...18)))
                blade.fillColor = SKColor(red: 0.35, green: CGFloat.random(in: 0.60...0.75), blue: 0.22, alpha: 0.6)
                addDecor(blade, x: x + CGFloat(j) * 3, y: groundY + blade.frame.height / 2)
            }
        }
    }

    private func spawnNightDecor(x: CGFloat) {
        let roll = Int.random(in: 0...3)
        switch roll {
        case 0: // Dark bush
            let bush = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...14))
            bush.fillColor = SKColor(red: 0.12, green: CGFloat.random(in: 0.22...0.35), blue: 0.10, alpha: 0.7)
            addDecor(bush, x: x, y: groundY + CGFloat.random(in: 4...10))
        case 1: // Dead grass
            for j in 0..<2 {
                let blade = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 8...14)))
                blade.fillColor = SKColor(red: 0.25, green: 0.30, blue: 0.15, alpha: 0.5)
                addDecor(blade, x: x + CGFloat(j) * 3, y: groundY + blade.frame.height / 2)
            }
        case 2: // Rock
            let rock = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 4...7)), cornerRadius: 2)
            rock.fillColor = SKColor(white: 0.25, alpha: 0.6)
            addDecor(rock, x: x, y: groundY + 2)
        default: // Glowing mushroom
            let cap = SKShapeNode(circleOfRadius: 4)
            cap.fillColor = SKColor(red: 0.30, green: 0.80, blue: 0.50, alpha: 0.6)
            addDecor(cap, x: x, y: groundY + 7)
        }
    }

    private func spawnDesertDecor(x: CGFloat) {
        let roll = Int.random(in: 0...4)
        switch roll {
        case 0: // Cactus
            let trunk = SKShapeNode(rectOf: CGSize(width: 6, height: CGFloat.random(in: 16...28)), cornerRadius: 2)
            trunk.fillColor = SKColor(red: 0.30, green: 0.55, blue: 0.22, alpha: 0.9)
            let th = trunk.frame.height
            addDecor(trunk, x: x, y: groundY + th / 2)
            // Arms
            let arm = SKShapeNode(rectOf: CGSize(width: 4, height: 10), cornerRadius: 2)
            arm.fillColor = SKColor(red: 0.28, green: 0.52, blue: 0.20, alpha: 0.9)
            addDecor(arm, x: x - 6, y: groundY + th * 0.6)
        case 1: // Dead bush (brown, spiky)
            let bush = SKShapeNode(circleOfRadius: CGFloat.random(in: 6...12))
            bush.fillColor = SKColor(red: 0.55, green: 0.40, blue: 0.22, alpha: 0.6)
            addDecor(bush, x: x, y: groundY + CGFloat.random(in: 4...8))
        case 2: // Skull/bone (small)
            let bone = SKShapeNode(circleOfRadius: 3)
            bone.fillColor = SKColor(white: 0.85, alpha: 0.6)
            addDecor(bone, x: x, y: groundY + 2)
        case 3: // Sand dune
            let dune = SKShapeNode()
            let dp = UIBezierPath()
            let dw = CGFloat.random(in: 20...40)
            dp.move(to: .zero)
            dp.addQuadCurve(to: CGPoint(x: dw, y: 0), controlPoint: CGPoint(x: dw / 2, y: CGFloat.random(in: 5...10)))
            dp.close()
            dune.path = dp.cgPath
            dune.fillColor = SKColor(red: 0.82, green: 0.70, blue: 0.42, alpha: 0.5)
            addDecor(dune, x: x, y: groundY)
        default: // Tumbleweed (small brown circle)
            let tw = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...9))
            tw.fillColor = SKColor(red: 0.60, green: 0.48, blue: 0.28, alpha: 0.5)
            addDecor(tw, x: x, y: groundY + CGFloat.random(in: 4...8))
        }
    }

    private func spawnSnowDecor(x: CGFloat) {
        let roll = Int.random(in: 0...4)
        switch roll {
        case 0: // Tall pine tree with snow
            let trunkH: CGFloat = CGFloat.random(in: 70...100)
            let trunk = SKShapeNode(rectOf: CGSize(width: 10, height: trunkH))
            trunk.fillColor = SKColor(red: 0.40, green: 0.25, blue: 0.12, alpha: 0.9)
            addDecor(trunk, x: x, y: groundY + trunkH / 2)
            // 4 tiers of branches, widest at bottom
            let tiers: [(w: CGFloat, h: CGFloat, yOff: CGFloat, g: CGFloat)] = [
                (40, 35, trunkH * 0.30, 0.30),
                (34, 30, trunkH * 0.50, 0.35),
                (26, 26, trunkH * 0.70, 0.40),
                (18, 22, trunkH * 0.90, 0.45),
            ]
            for tier in tiers {
                let t = SKShapeNode()
                let p = UIBezierPath()
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: -tier.w, y: -tier.h))
                p.addLine(to: CGPoint(x: tier.w, y: -tier.h))
                p.close()
                t.path = p.cgPath
                t.fillColor = SKColor(red: 0.10, green: tier.g, blue: 0.16, alpha: 0.9)
                t.strokeColor = .clear
                addDecor(t, x: x, y: groundY + tier.yOff + tier.h)
                // Snow on each tier
                let snow = SKShapeNode(ellipseOf: CGSize(width: tier.w * 1.1, height: 5))
                snow.fillColor = SKColor(white: 0.97, alpha: 0.75)
                snow.strokeColor = .clear
                addDecor(snow, x: x, y: groundY + tier.yOff + tier.h - 2)
            }
            // Snow cap on top
            let cap = SKShapeNode(circleOfRadius: 6)
            cap.fillColor = SKColor(white: 0.98, alpha: 0.8)
            cap.strokeColor = .clear
            addDecor(cap, x: x, y: groundY + trunkH + 8)
        case 1: // Snowdrift
            let drift = SKShapeNode()
            let dp = UIBezierPath()
            let dw = CGFloat.random(in: 15...30)
            dp.move(to: .zero)
            dp.addQuadCurve(to: CGPoint(x: dw, y: 0), controlPoint: CGPoint(x: dw / 2, y: CGFloat.random(in: 4...8)))
            dp.close()
            drift.path = dp.cgPath
            drift.fillColor = SKColor(white: 0.95, alpha: 0.7)
            addDecor(drift, x: x, y: groundY)
        case 2: // Icicle
            let ice = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 8...15)))
            ice.fillColor = SKColor(red: 0.70, green: 0.85, blue: 1.0, alpha: 0.6)
            addDecor(ice, x: x, y: groundY + ice.frame.height / 2)
        case 3: // Snow rock
            let rock = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 8...14), height: CGFloat.random(in: 5...8)), cornerRadius: 3)
            rock.fillColor = SKColor(red: 0.60, green: 0.62, blue: 0.65, alpha: 0.7)
            addDecor(rock, x: x, y: groundY + 2)
        default: // Frozen plant
            let stem = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 8...14)))
            stem.fillColor = SKColor(red: 0.55, green: 0.65, blue: 0.75, alpha: 0.5)
            addDecor(stem, x: x, y: groundY + stem.frame.height / 2)
        }
    }

    private func spawnJungleDecor(x: CGFloat) {
        let roll = Int.random(in: 0...4)
        switch roll {
        case 0: // Massive jungle tree with canopy and vines
            let trunkH: CGFloat = CGFloat.random(in: 80...120)
            let trunk = SKShapeNode(rectOf: CGSize(width: 14, height: trunkH))
            trunk.fillColor = SKColor(red: 0.32, green: 0.20, blue: 0.08, alpha: 0.9)
            addDecor(trunk, x: x, y: groundY + trunkH / 2)
            // Exposed roots at base
            for r in [-12, -6, 6, 10] as [CGFloat] {
                let root = SKShapeNode(rectOf: CGSize(width: 3, height: CGFloat.random(in: 8...14)))
                root.fillColor = SKColor(red: 0.30, green: 0.18, blue: 0.08, alpha: 0.7)
                root.zRotation = r > 0 ? -0.3 : 0.3
                addDecor(root, x: x + r, y: groundY + 4)
            }
            // Big layered canopy (5 overlapping circles)
            let canopyBase = groundY + trunkH
            let canopyPuffs: [(dx: CGFloat, dy: CGFloat, r: CGFloat, g: CGFloat)] = [
                (-22, 5, 28, 0.48), (20, 8, 26, 0.52), (0, 18, 30, 0.55),
                (-14, 22, 24, 0.58), (12, 25, 22, 0.62),
            ]
            for puff in canopyPuffs {
                let c = SKShapeNode(circleOfRadius: puff.r)
                c.fillColor = SKColor(red: 0.12, green: puff.g, blue: 0.10, alpha: 0.85)
                c.strokeColor = .clear
                addDecor(c, x: x + puff.dx, y: canopyBase + puff.dy)
            }
            // Hanging vines from canopy
            for vx in [CGFloat(-18), -5, 8, 20] {
                let vineH = CGFloat.random(in: 30...60)
                let vine = SKShapeNode(rectOf: CGSize(width: 2, height: vineH))
                vine.fillColor = SKColor(red: 0.15, green: CGFloat.random(in: 0.42...0.55), blue: 0.10, alpha: 0.6)
                vine.strokeColor = .clear
                addDecor(vine, x: x + vx, y: canopyBase - vineH / 2 + 5)
            }
            // Orchid on trunk
            let orchid = SKShapeNode(circleOfRadius: 3)
            orchid.fillColor = [SKColor.magenta, SKColor.orange, SKColor.yellow].randomElement()!
            orchid.strokeColor = .clear
            addDecor(orchid, x: x + 8, y: groundY + trunkH * 0.4)
        case 1: // Giant leaf
            let leaf = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 12...22), height: CGFloat.random(in: 6...10)))
            leaf.fillColor = SKColor(red: 0.18, green: CGFloat.random(in: 0.55...0.72), blue: 0.15, alpha: 0.7)
            addDecor(leaf, x: x, y: groundY + CGFloat.random(in: 4...12))
        case 2: // Tropical flower
            let flower = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...7))
            flower.fillColor = [SKColor.red, SKColor.orange, SKColor(red: 1, green: 0.2, blue: 0.6, alpha: 1), SKColor.yellow].randomElement()!
            addDecor(flower, x: x, y: groundY + CGFloat.random(in: 6...14))
        case 3: // Fern
            for j in 0..<4 {
                let frond = SKShapeNode(rectOf: CGSize(width: 1.5, height: CGFloat.random(in: 10...20)))
                frond.fillColor = SKColor(red: 0.15, green: CGFloat.random(in: 0.50...0.68), blue: 0.12, alpha: 0.6)
                frond.zRotation = CGFloat.random(in: -0.3...0.3)
                addDecor(frond, x: x + CGFloat(j) * 3, y: groundY + frond.frame.height / 2)
            }
        default: // Jungle mushroom
            let cap = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...7))
            cap.fillColor = SKColor(red: 0.85, green: 0.55, blue: 0.15, alpha: 0.7)
            addDecor(cap, x: x, y: groundY + 7)
        }
    }

    // MARK: - Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.ladybug | PhysicsCategory.aphid {
            // BiomeFood
            if let food = (contact.bodyA.node as? BiomeFood) ?? (contact.bodyB.node as? BiomeFood) {
                score += food.points
                showFloatingScore(food.points, at: food.position, color: .cyan)
                showEatParticles(at: food.position)
                food.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("pop")
                switch food.biomeName {
                case "Desert Beetle", "Jungle Beetle": SoundManager.shared.play("skitter")
                case "Sand Fly", "Ice Moth", "Butterfly": SoundManager.shared.play("flutter")
                default: break
                }
                return
            }
            if let aphid = (contact.bodyA.node as? Aphid) ?? (contact.bodyB.node as? Aphid) {
                score += aphid.points
                showFloatingScore(aphid.points, at: aphid.position,
                    color: aphid.colorType == .red ? .red : (aphid.colorType == .yellow ? .yellow : .green))
                showEatParticles(at: aphid.position)
                aphid.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("pop")
                switch aphid.colorType {
                case .green: unlockBug(.greenAphid)
                case .yellow: unlockBug(.yellowAphid)
                case .red: unlockBug(.redAphid)
                }
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.fruitfly {
            // Gnat swarm
            if let gs = (contact.bodyA.node as? GnatSwarm) ?? (contact.bodyB.node as? GnatSwarm) {
                score += 20
                showFloatingScore(20, at: gs.position, color: SKColor(white: 0.9, alpha: 1))
                showEatParticles(at: gs.position)
                gs.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("pop")
                return
            }
            // HeartBug — restore a life
            if let hb = (contact.bodyA.node as? HeartBug) ?? (contact.bodyB.node as? HeartBug) {
                if lives < 3 { lives += 1; updateLivesDisplay() }
                score += 50
                showFloatingScore(50, at: hb.position, color: SKColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0))
                showEatParticles(at: hb.position)
                hb.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("powerup")
                unlockBug(.heartBug)
                return
            }
            // Check firefly
            if let ff = (contact.bodyA.node as? Firefly) ?? (contact.bodyB.node as? Firefly) {
                score += 100
                showFloatingScore(100, at: ff.position, color: SKColor(red: 1.0, green: 0.95, blue: 0.3, alpha: 1.0))
                showEatParticles(at: ff.position)
                ff.removeFromParent()
                ladybug.makeInvincible(duration: 10.0)
                ladybug.pulse()
                SoundManager.shared.play("powerup")
                unlockBug(.firefly)

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
                showEatParticles(at: fly.position)
                fly.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("pop")
                switch fly.colorType {
                case .brown: unlockBug(.brownFly)
                case .blue: unlockBug(.blueFly)
                case .purple: unlockBug(.purpleFly)
                }
            }
        }

        if collision == PhysicsCategory.ladybug | PhysicsCategory.bird {
            if ladybug.isSheltered { return }
            if !ladybug.isInvincible {
                let enemyNode = (contact.bodyA.categoryBitMask == PhysicsCategory.bird) ? contact.bodyA.node : contact.bodyB.node
                if enemyNode is Bird { unlockBug(.bird) }
                else if let df = enemyNode as? Dragonfly {
                    if df.name == "vulture" { unlockBug(.vulture) }
                    else { unlockBug(.dragonfly) }
                }
                else if enemyNode is Ant { unlockBug(.ant) }
                else if enemyNode is Spider {
                    if currentBiome == .jungle { unlockBug(.jungleSpider) }
                    else { unlockBug(.spider) }
                }
                else if enemyNode?.parent is Frog {
                    switch currentBiome {
                    case .meadowNight: unlockBug(.toad)
                    case .jungle: unlockBug(.poisonDartFrog)
                    default: unlockBug(.frog)
                    }
                }
                else if let swooper = enemyNode as? BiomeSwooper {
                    switch swooper.biomeName {
                    case "Bat": unlockBug(.bat)
                    case "Hawk": unlockBug(.hawk)
                    case "Snow Owl": unlockBug(.snowOwl)
                    case "Toucan": unlockBug(.toucan)
                    default: break
                    }
                }
                else if let enemy = enemyNode as? BiomeEnemy {
                    switch enemy.biomeName {
                    case "Scorpion": unlockBug(.scorpion)
                    case "Rattlesnake": unlockBug(.rattlesnake)
                    case "Ice Spider": unlockBug(.iceSpider)
                    case "Jungle Spider": unlockBug(.jungleSpider)
                    default: break
                    }
                }
                enemyNode?.removeFromParent()
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

    private func showEatParticles(at pos: CGPoint) {
        for _ in 0..<6 {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
            p.fillColor = [SKColor.white, SKColor.yellow, SKColor.green].randomElement()!
            p.strokeColor = .clear
            p.position = pos
            p.zPosition = 55
            addChild(p)
            let dx = CGFloat.random(in: -20...20)
            let dy = CGFloat.random(in: 5...25)
            p.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.scale(to: 0.2, duration: 0.3),
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func unlockBug(_ bug: BugTracker.BugType) {
        let wasNew = !BugTracker.shared.isUnlocked(bug)
        BugTracker.shared.unlock(bug)
        if wasNew {
            SoundManager.shared.play("newBug")
            let banner = SKLabelNode(fontNamed: "AvenirNext-Bold")
            banner.text = "New Discovery: \(bug.rawValue)!"
            banner.fontSize = 14
            banner.fontColor = SKColor(red: 1.0, green: 0.90, blue: 0.30, alpha: 1.0)
            banner.position = CGPoint(x: size.width / 2, y: size.height - 55)
            banner.zPosition = 120
            addChild(banner)
            banner.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
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

    // MARK: - Biome Spawning

    private func spawnForBiome(dt: TimeInterval) {
        // Bushes only in meadow biomes
        if currentBiome == .meadowDay || currentBiome == .meadowNight {
            logTimer += dt
            let li = max(2.5, 5.0 - Double(distanceTraveled) * 0.0003)
            if logTimer >= li { logTimer = 0; spawnLog() }
        }

        heartBugTimer += dt
        if heartBugTimer >= 20.0 && lives < 3 { heartBugTimer = 0; spawnHeartBug() }

        envTimer += dt
        if envTimer >= 0.6 { envTimer = 0; spawnEnvironment() }

        switch currentBiome {
        case .meadowDay:
            aphidTimer += dt
            if aphidTimer >= 1.2 { aphidTimer = 0; spawnAphid() }
            flyTimer += dt
            if flyTimer >= 1.5 { flyTimer = 0; spawnFruitFly() }
            antTimer += dt
            if antTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { antTimer = 0; spawnAnt() }
            birdTimer += dt
            if birdTimer >= max(2.5, 5.5 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBird() }
            frogTimer += dt
            if frogTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnPondCreature() }

        case .meadowNight:
            gnatTimer += dt
            if gnatTimer >= 1.0 { gnatTimer = 0; spawnGnatSwarm() }
            fireflyTimer += dt
            if fireflyTimer >= 12.0 { fireflyTimer = 0; spawnFirefly() }
            spiderTimer += dt
            if spiderTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnSpider() }
            birdTimer += dt
            if birdTimer >= max(2.5, 5.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Bat") }
            frogTimer += dt
            if frogTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnPondCreature() }

        case .desert:
            aphidTimer += dt // Desert beetles
            if aphidTimer >= 1.4 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateDesertBeetleTexture(size: CGSize(width: 28, height: 24)), pts: 15, flying: false, name: "Desert Beetle") }
            flyTimer += dt // Desert flies (with wings via FruitFly frames)
            if flyTimer >= 1.8 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 18, height: 18), color: .brown).first!, pts: 20, flying: true, name: "Sand Fly") }
            dragonflyTimer += dt // Scorpions
            if dragonflyTimer >= max(3.5, 7.0 - Double(distanceTraveled) * 0.0003) { dragonflyTimer = 0; spawnBiomeGroundEnemy(texture: TextureGenerator.generateScorpionTexture(size: CGSize(width: 44, height: 34)), name: "Scorpion") }
            spiderTimer += dt // Rattlesnake
            if spiderTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnBiomeGroundEnemy(texture: TextureGenerator.generateRattlesnakeTexture(size: CGSize(width: 52, height: 34)), name: "Rattlesnake") }
            birdTimer += dt // Hawks
            if birdTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Hawk") }
            frogTimer += dt // Vultures
            if frogTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnVulture() }

        case .snow:
            aphidTimer += dt // Snow fleas
            if aphidTimer >= 1.3 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateSnowFleaTexture(size: CGSize(width: 24, height: 20)), pts: 15, flying: false, name: "Snow Flea") }
            flyTimer += dt // Ice moths
            if flyTimer >= 1.6 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 20, height: 20), color: .blue).first!, pts: 25, flying: true, name: "Ice Moth") }
            spiderTimer += dt // Ice spiders
            if spiderTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnBiomeGroundEnemy(texture: TextureGenerator.generateIceSpiderTexture(size: CGSize(width: 44, height: 36)), name: "Ice Spider") }
            birdTimer += dt // Snow owls
            if birdTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Snow Owl") }
            fireflyTimer += dt // Hot cocoa (rare power-up)
            if fireflyTimer >= 15.0 { fireflyTimer = 0; spawnFirefly() }

        case .jungle:
            aphidTimer += dt // Jungle beetles
            if aphidTimer >= 1.2 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateJungleBeetleTexture(size: CGSize(width: 28, height: 24)), pts: 30, flying: false, name: "Jungle Beetle") }
            flyTimer += dt // Tropical butterflies
            if flyTimer >= 1.5 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 22, height: 22), color: .purple).first!, pts: 20, flying: true, name: "Butterfly") }
            dragonflyTimer += dt // Poison dart frogs at ponds
            if dragonflyTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { dragonflyTimer = 0; spawnPondCreature() }
            spiderTimer += dt // Jungle spiders
            if spiderTimer >= max(3.5, 7.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnJungleSpider() }
            birdTimer += dt // Toucans
            if birdTimer >= max(2.5, 5.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Toucan") }
        }
    }

    private func spawnBiomeFood(texture: SKTexture, pts: Int, flying: Bool, name: String) {
        let spawnX = size.width + 30
        if !flying && isNearGroundObject(x: spawnX, range: 60) { return }
        let food = BiomeFood(texture: texture, points: pts, biomeName: name, isFlying: flying)
        let y: CGFloat = flying ? groundY + CGFloat.random(in: 40...size.height * 0.45) : groundY + food.size.height / 2
        food.position = CGPoint(x: spawnX, y: y)
        food.minY = groundY
        food.setupPhysics()
        food.startMoving()
        addChild(food)
    }

    private func spawnBiomeGroundEnemy(texture: SKTexture, name: String) {
        let spawnX = size.width + 40
        if isNearGroundObject(x: spawnX, range: 80) { return }
        let enemy = BiomeEnemy(texture: texture, biomeName: name)
        enemy.position = CGPoint(x: spawnX, y: groundY + enemy.size.height / 2)
        enemy.setupPhysics()
        enemy.startPatrolling()
        addChild(enemy)
    }

    private func spawnBiomeSwooper(name: String) {
        let frames: [SKTexture]
        switch name {
        case "Bat": frames = batFrames
        case "Hawk": frames = hawkFrames
        case "Snow Owl": frames = owlFrames
        case "Toucan": frames = toucanFrames
        default: frames = birdTextures
        }
        let swooper = BiomeSwooper(textures: frames, biomeName: name)
        swooper.position = CGPoint(x: size.width + 60, y: size.height * CGFloat.random(in: 0.70...0.95))
        swooper.xScale = -1
        swooper.setupPhysics()
        addChild(swooper)
        // Biome-specific swooper sound
        switch name {
        case "Bat": SoundManager.shared.play("screech")
        case "Hawk": SoundManager.shared.play("screech")
        case "Snow Owl": SoundManager.shared.play("hoot")
        case "Toucan": SoundManager.shared.play("squawk")
        default: SoundManager.shared.play("caw")
        }
        // Delayed whoosh as it dives
        swooper.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            SoundManager.shared.play("whoosh")
        }]))
        let targetY = groundY + ladybug.size.height / 2 + CGFloat.random(in: 0...15)
        swooper.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                            targetY: targetY, groundY: groundY,
                            duration: 1.5 + Double.random(in: 0...0.5))
    }

    private func spawnVulture() {
        let vulture = Dragonfly(textures: vultureFrames)
        vulture.position = CGPoint(x: size.width + 60, y: groundY + CGFloat.random(in: 60...size.height * 0.55))
        vulture.name = "vulture"
        vulture.setupPhysics()
        vulture.startHovering(minY: groundY + 50, maxY: size.height * 0.65, playerX: ladybug.position.x)
        addChild(vulture)
        SoundManager.shared.play("screech")
    }

    private func spawnJungleSpider() {
        let spawnX = size.width + 40
        if isNearGroundObject(x: spawnX, range: 80) { return }
        let spider = Spider(walkFrames: jungleSpiderFrames)
        spider.position = CGPoint(x: spawnX, y: groundY + spider.size.height / 2)
        spider.baseY = groundY + spider.size.height / 2
        spider.setupPhysics()
        spider.startCrawling()
        addChild(spider)
        unlockBug(.jungleSpider)
    }

    // MARK: - Biome Transitions

    private func transitionToBiome(_ biome: Biome) {
        // Stop previous biome effects
        removeAction(forKey: "snowfall")
        removeAction(forKey: "shootingStars")

        // Notification
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = biome.name
        label.fontSize = 30
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        label.zPosition = 80
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([SKAction.moveBy(x: 0, y: 20, duration: 2.0), SKAction.fadeOut(withDuration: 2.0)]),
            SKAction.removeFromParent()
        ]))

        // Transition ground color
        for tile in groundTiles {
            tile.run(SKAction.colorize(with: biome.groundColor, colorBlendFactor: 0.8, duration: 2.0))
        }

        // Sky color transition
        let skyOverlay = SKShapeNode(rectOf: CGSize(width: size.width + 20, height: size.height))
        skyOverlay.fillColor = biome.skyColor
        skyOverlay.strokeColor = .clear
        skyOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        skyOverlay.zPosition = -1
        skyOverlay.alpha = 0
        addChild(skyOverlay)
        skyOverlay.run(SKAction.fadeAlpha(to: 0.7, duration: 2.5))

        // Night-specific effects
        if biome == .meadowNight {
            isNight = true
            hasTransitionedToNight = true
            transitionToNight()
        }

        // Snow: falling snowflakes
        if biome == .snow {
            let snowfall = SKAction.run { [weak self] in
                guard let self = self else { return }
                let flake = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                flake.fillColor = .white
                flake.strokeColor = .clear
                flake.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: self.size.height + 5)
                flake.zPosition = 50
                flake.alpha = CGFloat.random(in: 0.4...0.8)
                self.addChild(flake)
                let fall = SKAction.moveTo(y: -5, duration: Double.random(in: 2...4))
                let drift = SKAction.moveBy(x: CGFloat.random(in: -30...10), y: 0, duration: Double.random(in: 2...4))
                flake.run(SKAction.sequence([SKAction.group([fall, drift]), SKAction.removeFromParent()]))
            }
            run(SKAction.repeatForever(SKAction.sequence([snowfall, SKAction.wait(forDuration: 0.15)])), withKey: "snowfall")
        }

        // Desert: warm orange gradient sky
        if biome == .desert {
            let bands: [(y: CGFloat, h: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)] = [
                (0.95, 0.15, 0.85, 0.40, 0.10, 0.7),  // Top — deep orange
                (0.80, 0.15, 0.90, 0.48, 0.12, 0.6),  // Upper — orange
                (0.65, 0.15, 0.95, 0.55, 0.15, 0.5),  // Mid — warm orange
                (0.50, 0.15, 0.98, 0.65, 0.18, 0.4),  // Lower — light orange
                (0.38, 0.10, 1.00, 0.75, 0.25, 0.3),  // Horizon — golden
            ]
            for band in bands {
                let stripe = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height * band.h))
                stripe.fillColor = SKColor(red: band.r, green: band.g, blue: band.b, alpha: band.a)
                stripe.strokeColor = .clear
                stripe.position = CGPoint(x: size.width / 2, y: size.height * band.y)
                stripe.zPosition = -0.5
                stripe.alpha = 0
                addChild(stripe)
                stripe.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5))
            }
        }

        // Jungle: mist
        if biome == .jungle {
            let mist = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.2))
            mist.fillColor = SKColor(red: 0.30, green: 0.60, blue: 0.35, alpha: 0.12)
            mist.strokeColor = .clear
            mist.position = CGPoint(x: size.width / 2, y: groundY + size.height * 0.1)
            mist.zPosition = 48
            addChild(mist)
        }
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
                SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                SKAction.wait(forDuration: 5.0),
                SKAction.moveBy(x: -size.width * 1.5, y: 0, duration: 3.0),
                SKAction.removeFromParent()
            ]))
        }

        // Flash notification
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "500 Points!"
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

    // MARK: - Night Mode

    private func transitionToNight() {
        isNight = true
        GameScene.hasNightCheckpoint = true

        // Darken sky
        let nightOverlay = SKShapeNode(rectOf: CGSize(width: size.width + 20, height: size.height))
        nightOverlay.fillColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.0)
        nightOverlay.strokeColor = .clear
        nightOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        nightOverlay.zPosition = -1
        nightOverlay.name = "nightOverlay"
        addChild(nightOverlay)
        nightOverlay.run(SKAction.customAction(withDuration: 3.0) { node, elapsed in
            let p = min(1.0, elapsed / 3.0)
            (node as? SKShapeNode)?.fillColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 0.65 * p)
        })

        // Darken ground
        for tile in groundTiles {
            tile.run(SKAction.colorize(with: SKColor(red: 0.15, green: 0.30, blue: 0.10, alpha: 1), colorBlendFactor: 0.5, duration: 3.0))
        }

        // Moon (fixed position, top-right)
        let moon = SKShapeNode(circleOfRadius: 20)
        moon.fillColor = SKColor(red: 0.95, green: 0.93, blue: 0.80, alpha: 0.9)
        moon.strokeColor = .clear
        moon.position = CGPoint(x: size.width * 0.82, y: size.height * 0.88)
        moon.zPosition = -0.5
        moon.alpha = 0
        addChild(moon)
        moon.run(SKAction.fadeAlpha(to: 1.0, duration: 3.0))
        // Moon crater
        let crater = SKShapeNode(circleOfRadius: 4)
        crater.fillColor = SKColor(red: 0.85, green: 0.83, blue: 0.70, alpha: 0.5)
        crater.strokeColor = .clear
        crater.position = CGPoint(x: 5, y: -3)
        moon.addChild(crater)

        // Stars
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                     y: CGFloat.random(in: size.height * 0.45...size.height * 0.98))
            star.zPosition = -0.8
            star.alpha = 0
            addChild(star)
            star.run(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...2)),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.4...1.0), duration: 1.5)
            ]))
            // Twinkle
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1...3)),
                SKAction.fadeAlpha(to: 0.9, duration: Double.random(in: 1...3))
            ])
            star.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.repeatForever(twinkle)]))
        }

        // Shooting star timer
        let shootingStar = SKAction.run { [weak self] in
            guard let self = self else { return }
            if Bool.random() && Bool.random() { // ~25% chance
                let ss = SKShapeNode(rectOf: CGSize(width: 2, height: 2))
                ss.fillColor = .white
                ss.strokeColor = .clear
                ss.position = CGPoint(x: self.size.width * CGFloat.random(in: 0.3...0.9),
                                       y: self.size.height * CGFloat.random(in: 0.70...0.95))
                ss.zPosition = -0.6
                self.addChild(ss)
                let trail = CGFloat.random(in: 80...150)
                ss.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.moveBy(x: -trail, y: -trail * 0.5, duration: 0.4),
                        SKAction.fadeOut(withDuration: 0.4)
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 3, withRange: 4),
            shootingStar
        ])), withKey: "shootingStars")

        // Notification
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Night Falls..."
        label.fontSize = 26
        label.fontColor = SKColor(red: 0.70, green: 0.75, blue: 1.0, alpha: 1.0)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        label.zPosition = 80
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([SKAction.moveBy(x: 0, y: 20, duration: 2.0), SKAction.fadeOut(withDuration: 2.0)]),
            SKAction.removeFromParent()
        ]))
    }

    private func spawnGnatSwarm() {
        let swarm = GnatSwarm()
        let y = groundY + CGFloat.random(in: 30...size.height * 0.40)
        swarm.position = CGPoint(x: size.width + 20, y: y)
        swarm.minY = groundY
        swarm.setupPhysics()
        swarm.startMoving()
        addChild(swarm)
    }

    private func togglePause() {
        isPaused_ = !isPaused_
        self.isPaused = isPaused_

        if isPaused_ {
            isTouching = false
            touchY = nil
            ladybug.targetY = nil

            let overlay = SKShapeNode(rectOf: size)
            overlay.fillColor = SKColor(white: 0.0, alpha: 0.5)
            overlay.strokeColor = .clear
            overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
            overlay.zPosition = 140
            overlay.name = "pauseOverlay"
            addChild(overlay)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "PAUSED"
            label.fontSize = 36
            label.fontColor = .white
            label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
            label.zPosition = 141
            label.name = "pauseOverlay"
            addChild(label)

            let resume = SKLabelNode(fontNamed: "AvenirNext-Medium")
            resume.text = "Tap to Resume"
            resume.fontSize = 18
            resume.fontColor = SKColor(white: 1.0, alpha: 0.6)
            resume.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
            resume.zPosition = 141
            resume.name = "resumeLabel"
            addChild(resume)
        } else {
            enumerateChildNodes(withName: "pauseOverlay") { node, _ in node.removeFromParent() }
            enumerateChildNodes(withName: "resumeLabel") { node, _ in node.removeFromParent() }
            lastUpdateTime = 0 // Reset to avoid big dt jump
        }
    }

    private func gameOver() {
        isGameOver = true
        SoundManager.shared.stopMusic()
        SoundManager.shared.play("gameOver")
        if score > MenuScene.highScore { MenuScene.highScore = score }

        // Death animation — flip over with X eyes, fall to ground
        let bugGroundY = groundY + ladybug.size.height / 2
        ladybug.playDeathAnimation(groundY: bugGroundY, deadTexture: deadTexture)

        // Delay game over UI to let death animation play
        run(SKAction.sequence([SKAction.wait(forDuration: 1.2), SKAction.run { [weak self] in
            self?.showGameOverUI()
        }]))
    }

    private func showGameOverUI() {
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
