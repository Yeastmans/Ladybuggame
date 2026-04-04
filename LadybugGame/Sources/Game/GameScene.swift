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
    private var gemLabel: SKLabelNode!

    private static let gemCountKey = "GemstoneCount"
    static var gemCount: Int {
        get { UserDefaults.standard.integer(forKey: gemCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: gemCountKey) }
    }
    private var hasShownRainbow = false
    private var currentBiome: Biome = .meadowDay
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
            if score >= 6000 && !isBossFight && currentBiome == .cave { startBossFight() }
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
    private var touchX: CGFloat?
    private var lastUpdateTime: TimeInterval = 0

    // Bug discovery queue — shows one banner at a time
    private var discoveryQueue: [BugTracker.BugType] = []
    private var isShowingDiscovery = false

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
    private var waspFrames: [SKTexture] = []
    private var vampireBatFrames: [SKTexture] = []
    private var frostMothFrames: [SKTexture] = []

    // Cave terrain system
    private var caveTerrain: CaveTerrain?
    private var caveGroundTiles: [SKShapeNode] = []
    private var caveCeilingTiles: [SKShapeNode] = []
    private var isCaveBiome: Bool { currentBiome == .cave }
    private var caveSpiderTimer: TimeInterval = 0
    private var fallingRockTimer: TimeInterval = 0

    // Boss fight
    private var isBossFight = false
    private var bossNode: SKSpriteNode?
    private var bossHP = 5
    private var bossHPLabel: SKLabelNode?
    private var bossAttackTimer: TimeInterval = 0
    private var bossAttackPhase = 0
    private var isBubbleMode = false
    private var bubbleTimer: TimeInterval = 0
    private var bubbleDuration: TimeInterval = 0
    private var bossBerryTimer: TimeInterval = 0
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
    private var waspTimer: TimeInterval = 0
    private var heartBugTimer: TimeInterval = 0
    private var groundTiles: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.80, blue: 0.95, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        groundY = size.height * 0.20

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
        // Resolve equipped body color for dead texture too
        var equippedBodyColor: UIColor? = nil
        if let colorId = ShopScene.equippedColor,
           let item = ShopScene.allItems.first(where: { $0.id == colorId }),
           let c = item.color {
            equippedBodyColor = UIColor(cgColor: c.cgColor)
        }
        let hasHatForDead = ShopScene.equippedHat != nil
        deadTexture = TextureGenerator.generateLadybugDeadTexture(size: CGSize(width: 48, height: 48), bodyColor: equippedBodyColor, hideAntennae: hasHatForDead)
        dragonflyFrames = TextureGenerator.generateDragonflyFrames(size: CGSize(width: 48, height: 28))
        fireflyFrames = TextureGenerator.generateFireflyFrames(size: CGSize(width: 24, height: 24))
        heartBugFrames = TextureGenerator.generateHeartBugFrames(size: CGSize(width: 36, height: 36))
        antFrames = TextureGenerator.generateAntFrames(size: CGSize(width: 32, height: 28))
        spiderFrames = TextureGenerator.generateSpiderFrames(size: CGSize(width: 48, height: 40))
        jungleSpiderFrames = TextureGenerator.generateJungleSpiderFrames(size: CGSize(width: 48, height: 40))
        waspFrames = TextureGenerator.generateDesertWaspFrames(size: CGSize(width: 40, height: 28))
        vampireBatFrames = TextureGenerator.generateVampireBatFrames(size: CGSize(width: 50, height: 36))
        frostMothFrames = TextureGenerator.generateFrostMothFrames(size: CGSize(width: 44, height: 36))
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
            band.name = "skyBg"
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
            ray.name = "skyBg"
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
        let tileWidth = size.width + 10
        let groundHeight: CGFloat = 18 // Thin grass strip only
        for i in 0..<3 {
            let tile = SKSpriteNode(color: SKColor(red: 0.42, green: 0.68, blue: 0.28, alpha: 1.0),
                                    size: CGSize(width: tileWidth, height: groundHeight))
            tile.anchorPoint = CGPoint(x: 0, y: 0)
            tile.position = CGPoint(x: CGFloat(i) * (tileWidth - 10), y: groundY - groundHeight + 4)
            tile.zPosition = 0
            tile.name = "groundTile"
            addChild(tile)
            groundTiles.append(tile)

            // Grass line at top
            let grass = SKShapeNode(rectOf: CGSize(width: tileWidth, height: 3))
            grass.fillColor = SKColor(red: 0.32, green: 0.55, blue: 0.20, alpha: 1.0)
            grass.strokeColor = .clear
            grass.position = CGPoint(x: tileWidth / 2, y: groundHeight - 1)
            tile.addChild(grass)

            // Grass tufts
            for _ in 0..<8 {
                let tuft = SKShapeNode()
                let tp = UIBezierPath()
                let tw = CGFloat.random(in: 3...5)
                let th = CGFloat.random(in: 4...10)
                tp.move(to: CGPoint(x: 0, y: 0))
                tp.addQuadCurve(to: CGPoint(x: tw, y: 0), controlPoint: CGPoint(x: tw / 2, y: th))
                tp.close()
                tuft.path = tp.cgPath
                tuft.fillColor = SKColor(red: CGFloat.random(in: 0.35...0.50),
                                         green: CGFloat.random(in: 0.60...0.78),
                                         blue: CGFloat.random(in: 0.18...0.30), alpha: 0.7)
                tuft.strokeColor = .clear
                tuft.position = CGPoint(x: CGFloat.random(in: 5...tileWidth - 5), y: groundHeight - 2)
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

        // Gem counter (top-left, below score)
        let gemIcon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemIcon.text = "💎"
        gemIcon.fontSize = 13
        gemIcon.horizontalAlignmentMode = .left
        gemIcon.position = CGPoint(x: 50, y: size.height - 50)
        gemIcon.zPosition = 100
        addChild(gemIcon)

        gemLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemLabel.text = "\(GameScene.gemCount)"
        gemLabel.fontSize = 14
        gemLabel.fontColor = SKColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1.0)
        gemLabel.horizontalAlignmentMode = .left
        gemLabel.position = CGPoint(x: 70, y: size.height - 50)
        gemLabel.zPosition = 100
        addChild(gemLabel)

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
        for i in 0..<6 { h += i < lives ? "♥" : "♡"; if i < 5 { h += " " } }
        livesLabel.text = h
    }

    private func spawnLadybug() {
        let bugSize = CGSize(width: 48, height: 48)

        // Resolve equipped body color for texture generation
        var bodyColor: UIColor? = nil
        if let colorId = ShopScene.equippedColor,
           let item = ShopScene.allItems.first(where: { $0.id == colorId }),
           let c = item.color {
            bodyColor = UIColor(cgColor: c.cgColor)
        }

        let hasHat = ShopScene.equippedHat != nil
        let walkTex = TextureGenerator.generateLadybugTexture(size: bugSize, bodyColor: bodyColor, hideAntennae: hasHat)
        let blinkTex = TextureGenerator.generateLadybugBlinkTexture(size: bugSize, bodyColor: bodyColor, hideAntennae: hasHat)
        let flyFrames = TextureGenerator.generateLadybugFlyFrames(size: bugSize, bodyColor: bodyColor, hideAntennae: hasHat)
        ladybug = Ladybug(walkTexture: walkTex, blinkTexture: blinkTex, flyFrames: flyFrames)
        ladybug.position = CGPoint(x: size.width * 0.18, y: groundY + bugSize.height / 2)

        // Apply equipped cosmetics (hats, shoes, sparkle)
        applyLadybugCosmetics()

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

    private func applyLadybugCosmetics() {
        // Sparkly color effect (body color already baked into texture via spawnLadybug)
        if let colorId = ShopScene.equippedColor,
           let item = ShopScene.allItems.first(where: { $0.id == colorId }) {
            if item.isSparkly {
                let sparkle = SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...2.5))
                    dot.fillColor = [.white, .yellow, SKColor(red: 1, green: 0.8, blue: 1, alpha: 1)].randomElement()!
                    dot.strokeColor = .clear
                    dot.position = CGPoint(x: CGFloat.random(in: -16...16), y: CGFloat.random(in: -16...16))
                    dot.zPosition = 11
                    dot.alpha = 1.0
                    self.ladybug.addChild(dot)
                    dot.run(SKAction.sequence([
                        SKAction.group([SKAction.fadeOut(withDuration: 0.4), SKAction.scale(to: 0.1, duration: 0.4), SKAction.moveBy(x: 0, y: 8, duration: 0.4)]),
                        SKAction.removeFromParent()
                    ]))
                }
                ladybug.run(SKAction.repeatForever(SKAction.sequence([sparkle, SKAction.wait(forDuration: 0.08)])), withKey: "sparkle")
            }
        }

        // Hat
        if let hatId = ShopScene.equippedHat {
            let hatNode = SKSpriteNode()
            hatNode.zPosition = 2
            hatNode.position = CGPoint(x: 17, y: 8) // on top of head
            switch hatId {
            case "hat_tophat":
                let tex = TextureGenerator.generateTopHatTexture(size: CGSize(width: 16, height: 14))
                hatNode.texture = tex
                hatNode.size = tex.size()
            case "hat_cap":
                let tex = TextureGenerator.generateCapTexture(size: CGSize(width: 18, height: 12))
                hatNode.texture = tex
                hatNode.size = tex.size()
            case "hat_crown":
                let tex = TextureGenerator.generateCrownTexture(size: CGSize(width: 18, height: 12))
                hatNode.texture = tex
                hatNode.size = tex.size()
            case "hat_flower":
                let tex = TextureGenerator.generateFlowerHatTexture(size: CGSize(width: 14, height: 14))
                hatNode.texture = tex
                hatNode.size = tex.size()
            default: break
            }
            hatNode.name = "hat"
            ladybug.addChild(hatNode)
        }

        // Shoes — colored ovals at each leg tip
        if let shoeId = ShopScene.equippedShoes,
           let item = ShopScene.allItems.first(where: { $0.id == shoeId }),
           let shoeColor = item.color {
            for dx in [CGFloat(-10), -3, 5] {
                let shoe = SKShapeNode(ellipseOf: CGSize(width: 6, height: 4))
                shoe.fillColor = SKColor(cgColor: shoeColor.cgColor)
                shoe.strokeColor = SKColor(white: 0, alpha: 0.3)
                shoe.lineWidth = 0.5
                shoe.position = CGPoint(x: dx, y: -21)
                shoe.zPosition = -1
                shoe.name = "shoe"
                ladybug.addChild(shoe)
            }
        }
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
            if node.name == "pauseMenuBtn" {
                SoundManager.shared.stopMusic()
                let menu = MenuScene(size: size)
                menu.scaleMode = scaleMode
                view?.presentScene(menu, transition: .fade(withDuration: 0.4))
                return
            }
        }

        if isPaused_ { return }
        isTouching = true
        touchY = loc.y
        touchX = loc.x
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused_ { return }
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        touchY = loc.y
        touchX = loc.x
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

        let localGY = effectiveGroundY(atScreenX: ladybug.position.x)
        let bugGroundY = localGY + ladybug.size.height / 2
        var ceilingY = effectiveCeilingY(atScreenX: ladybug.position.x) - ladybug.size.height / 2

        // Check if inside a log — clamp ceiling to log top
        checkLogTube(bugGroundY: bugGroundY, ceilingY: &ceilingY)

        ladybug.updatePhysics(dt: dt, groundY: bugGroundY, ceilingY: ceilingY)

        pushEntitiesFromLogs()
        checkPondSplash()
        checkSpiderJumps()
        checkCaveEntities()

        // Scrolling (stops during boss fight)
        if !isBossFight {
            distanceTraveled += scrollSpeed * CGFloat(dt)
            scrollSpeed = min(300, 160 + distanceTraveled * 0.002)
        }
        let sd = isBossFight ? 0 : scrollSpeed * CGFloat(dt)

        scrollGround(delta: sd)
        scrollParallax(delta: sd)
        scrollWorldObjects(delta: sd)

        // Cave terrain advancement
        if isCaveBiome, let terrain = caveTerrain {
            terrain.update(scrollDelta: sd)
            let wasFull = terrain.transitionProgress >= 1.0
            terrain.advanceTransition(delta: sd, targetProgress: 1.0)
            // During transition ramp, regenerate all tile paths every frame so terrain visually matches
            if !wasFull && terrain.transitionProgress < 1.0 {
                regenerateAllCaveTilePaths()
            }
        }

        // Boss fight or normal spawning
        if isBossFight {
            updateBossFight(dt: dt)
        } else {
            spawnForBiome(dt: dt)
        }
        processDiscoveryQueue()
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

    private func checkCaveEntities() {
        guard isCaveBiome else { return }
        let dt = 1.0 / 60.0 // approximate frame dt
        for child in children {
            if let cs = child as? CaveSpider {
                cs.lungeIfPlayerNear(playerX: ladybug.position.x)
            }
            if let rock = child as? FallingRock {
                rock.update(dt: dt)
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
        // Cave tiles
        if isCaveBiome {
            for (i, tile) in caveGroundTiles.enumerated() {
                tile.position.x -= delta
                caveCeilingTiles[i].position.x -= delta
                if tile.position.x + tileStride < 0 {
                    let maxX = caveGroundTiles.map { $0.position.x }.max() ?? 0
                    tile.position.x = round(maxX + tileStride)
                    caveCeilingTiles[i].position.x = tile.position.x
                    regenerateCaveTilePath(index: i)
                }
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
        enumerateChildNodes(withName: "monkey") { node, _ in
            node.position.x -= delta
            if node.position.x < -60 { node.removeFromParent() }
        }
    }

    private func scrollWorldObjects(delta: CGFloat) {
        for child in children {
            if child is Aphid || child is FruitFly || child is Log || child is Bird || child is Frog || child is Dragonfly || child is Firefly || child is HeartBug || child is Ant || child is Spider || child is GnatSwarm || child is BiomeFood || child is BiomeEnemy || child is BiomeSwooper || child is CaveSpider || child is FallingRock {
                child.position.x -= delta
                // Cave ground tracking: snap ground entities to terrain
                if isCaveBiome, let terrain = caveTerrain {
                    let isGround = child is Aphid || child is Ant || child is BiomeEnemy ||
                        (child is BiomeFood && !(child as! BiomeFood).isFlying) ||
                        (child is Spider && !(child is CaveSpider))
                    if isGround {
                        let gY = terrain.groundY(atScreenX: child.position.x)
                        child.position.y = gY + child.frame.height / 2
                    }
                    if let cs = child as? CaveSpider {
                        cs.updateVisuals(currentCeilingY: terrain.ceilingY(atScreenX: child.position.x))
                    }
                }
                if child.position.x < -120 { child.removeFromParent() }
            }
        }
        // FallingRock shadows also need scrolling
        enumerateChildNodes(withName: "rockShadow") { node, _ in
            node.position.x -= delta
            if node.position.x < -80 { node.removeFromParent() }
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

        // 2% chance: gem bug replaces aphid
        if Int.random(in: 1...50) == 1 {
            let tex = TextureGenerator.generateAphidTexture(size: CGSize(width: 22, height: 22), color: [.green, .yellow].randomElement()!)
            let gem = BiomeFood(texture: tex, points: 10, biomeName: "GemBug", isFlying: false)
            gem.position = CGPoint(x: spawnX, y: groundY + gem.size.height / 2)
            gem.minY = groundY
            gem.setupPhysics()
            gem.startMoving()
            gem.makeGemBug()
            addChild(gem)
            return
        }

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
        // 2% chance: gem bug replaces fly
        if Int.random(in: 1...50) == 1 {
            let tex = TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 22, height: 22), color: .brown).first!
            let gem = BiomeFood(texture: tex, points: 15, biomeName: "GemBug", isFlying: true)
            let y = groundY + CGFloat.random(in: 50...size.height * 0.45)
            gem.position = CGPoint(x: size.width + 30, y: y)
            gem.minY = groundY
            gem.setupPhysics()
            gem.startMoving()
            gem.makeGemBug()
            addChild(gem)
            return
        }

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

        let targetY = ladybug.position.y
        SoundManager.shared.play("caw")
        bird.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                         targetY: targetY, groundY: groundY,
                         duration: isNight ? 2.2 + Double.random(in: 0...0.5) : 2.8 + Double.random(in: 0...0.7))
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
        case .cave:
            spawnCaveDecor(x: x)
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
        case 0: // Tall cactus with arms
            let trunkH = CGFloat.random(in: 45...75)
            let trunk = SKShapeNode(rectOf: CGSize(width: 12, height: trunkH), cornerRadius: 4)
            trunk.fillColor = SKColor(red: 0.28, green: 0.55, blue: 0.20, alpha: 0.9)
            addDecor(trunk, x: x, y: groundY + trunkH / 2)
            // Left arm
            let armH1 = CGFloat.random(in: 14...22)
            let arm1v = SKShapeNode(rectOf: CGSize(width: 8, height: armH1), cornerRadius: 3)
            arm1v.fillColor = SKColor(red: 0.26, green: 0.52, blue: 0.18, alpha: 0.9)
            arm1v.strokeColor = .clear
            addDecor(arm1v, x: x - 10, y: groundY + trunkH * 0.55 + armH1 / 2)
            let arm1h = SKShapeNode(rectOf: CGSize(width: 10, height: 8), cornerRadius: 3)
            arm1h.fillColor = SKColor(red: 0.26, green: 0.52, blue: 0.18, alpha: 0.9)
            arm1h.strokeColor = .clear
            addDecor(arm1h, x: x - 10, y: groundY + trunkH * 0.55)
            // Right arm (higher)
            let armH2 = CGFloat.random(in: 10...18)
            let arm2v = SKShapeNode(rectOf: CGSize(width: 8, height: armH2), cornerRadius: 3)
            arm2v.fillColor = SKColor(red: 0.30, green: 0.56, blue: 0.22, alpha: 0.9)
            arm2v.strokeColor = .clear
            addDecor(arm2v, x: x + 10, y: groundY + trunkH * 0.70 + armH2 / 2)
            let arm2h = SKShapeNode(rectOf: CGSize(width: 10, height: 8), cornerRadius: 3)
            arm2h.fillColor = SKColor(red: 0.30, green: 0.56, blue: 0.22, alpha: 0.9)
            arm2h.strokeColor = .clear
            addDecor(arm2h, x: x + 10, y: groundY + trunkH * 0.70)
            // Spines (tiny lines)
            for sy in stride(from: CGFloat(0.2), through: 0.9, by: 0.15) {
                let spine = SKShapeNode(rectOf: CGSize(width: 4, height: 1))
                spine.fillColor = SKColor(red: 0.22, green: 0.42, blue: 0.15, alpha: 0.5)
                spine.strokeColor = .clear
                addDecor(spine, x: x + 8, y: groundY + trunkH * sy)
            }
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

    private func spawnCaveDecor(x: CGFloat) {
        guard let terrain = caveTerrain else { return }
        let gY = terrain.groundY(atScreenX: x)
        let cY = terrain.ceilingY(atScreenX: x)
        let roll = Int.random(in: 0...5)
        switch roll {
        case 0: // Stalactite (from ceiling)
            let h = CGFloat.random(in: 15...38)
            let stalactite = SKShapeNode()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: -CGFloat.random(in: 4...8), y: 0))
            path.addLine(to: CGPoint(x: 0, y: -h))
            path.addLine(to: CGPoint(x: CGFloat.random(in: 4...8), y: 0))
            path.close()
            stalactite.path = path.cgPath
            stalactite.fillColor = SKColor(red: 0.32, green: 0.28, blue: 0.24, alpha: 0.85)
            addDecor(stalactite, x: x, y: cY - 1)
        case 1: // Stalagmite (from ground)
            let h = CGFloat.random(in: 12...32)
            let stalagmite = SKShapeNode()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: -CGFloat.random(in: 3...7), y: 0))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: CGFloat.random(in: 3...7), y: 0))
            path.close()
            stalagmite.path = path.cgPath
            stalagmite.fillColor = SKColor(red: 0.34, green: 0.30, blue: 0.25, alpha: 0.85)
            addDecor(stalagmite, x: x, y: gY + 1)
        case 2: // Glowing crystal cluster
            for _ in 0..<Int.random(in: 2...4) {
                let crystal = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 6...12)))
                crystal.fillColor = [SKColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 0.7),
                                     SKColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 0.7),
                                     SKColor(red: 0.6, green: 0.2, blue: 0.7, alpha: 0.7)].randomElement()!
                crystal.strokeColor = .clear
                crystal.zRotation = CGFloat.random(in: -0.4...0.4)
                addDecor(crystal, x: x + CGFloat.random(in: -5...5), y: gY + crystal.frame.height / 2)
            }
            let glow = SKShapeNode(circleOfRadius: 7)
            glow.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.8, alpha: 0.12)
            glow.strokeColor = .clear
            addDecor(glow, x: x, y: gY + 6)
        case 3: // Decorative gemstone (wall)
            let gem = SKShapeNode(rectOf: CGSize(width: 5, height: 5))
            gem.fillColor = [SKColor.purple, SKColor.cyan, SKColor.green].randomElement()!.withAlphaComponent(0.6)
            gem.strokeColor = .clear
            gem.zRotation = .pi / 4
            let wallY = CGFloat.random(in: gY + 20...cY - 20)
            addDecor(gem, x: x, y: wallY)
        case 4: // Cave moss
            let moss = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 8...16), height: 4))
            moss.fillColor = SKColor(red: 0.18, green: CGFloat.random(in: 0.30...0.38), blue: 0.14, alpha: 0.45)
            addDecor(moss, x: x, y: gY + 2)
        default: // Small rock
            let rock = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 5...11), height: CGFloat.random(in: 3...6)), cornerRadius: 2)
            rock.fillColor = SKColor(red: 0.38, green: 0.33, blue: 0.28, alpha: 0.7)
            addDecor(rock, x: x, y: gY + 2)
        }
    }

    private func spawnJungleDecor(x: CGFloat) {
        // Don't place big trees near ponds or other ground objects
        let nearWater = isNearGroundObject(x: x, range: 110)
        let roll = nearWater ? Int.random(in: 1...4) : Int.random(in: 0...4)
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
                // Gem bug — grants gemstone instead of normal points
                if food.isGemBug {
                    collectGemstone(at: food.position)
                    food.removeFromParent()
                    ladybug.pulse()
                    return
                }
                score += food.points
                showFloatingScore(food.points, at: food.position, color: .cyan)
                showEatParticles(at: food.position)
                food.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("pop")
                switch food.biomeName {
                case "Desert Beetle":    unlockBug(.desertBeetle);    SoundManager.shared.play("skitter")
                case "Sand Fly":         unlockBug(.sandFly);         SoundManager.shared.play("flutter")
                case "Desert Cricket":   unlockBug(.desertCricket);   SoundManager.shared.play("skitter")
                case "Snow Flea":        unlockBug(.snowFlea)
                case "Ice Moth":         unlockBug(.iceMoth);         SoundManager.shared.play("flutter")
                case "Jungle Beetle":    unlockBug(.jungleBeetle);    SoundManager.shared.play("skitter")
                case "Butterfly":        unlockBug(.butterfly);       SoundManager.shared.play("flutter")
                case "Cave Cricket":    unlockBug(.caveCricket);    SoundManager.shared.play("skitter")
                case "Glowworm":        unlockBug(.glowworm);       SoundManager.shared.play("flutter")
                case "Crystal Beetle":  unlockBug(.crystalBeetle);  SoundManager.shared.play("skitter")
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
            // Bubble berry (boss fight power-up)
            if let berry = (contact.bodyA.node as? SKShapeNode) ?? (contact.bodyB.node as? SKShapeNode),
               berry.name == "bubbleBerry" {
                berry.removeFromParent()
                collectBubbleBerry()
                return
            }
            // Gnat swarm
            if let gs = (contact.bodyA.node as? GnatSwarm) ?? (contact.bodyB.node as? GnatSwarm) {
                score += 30
                showFloatingScore(30, at: gs.position, color: SKColor(white: 0.9, alpha: 1))
                showEatParticles(at: gs.position)
                gs.removeFromParent()
                ladybug.pulse()
                SoundManager.shared.play("pop")
                unlockBug(.gnatSwarm)
                return
            }
            // HeartBug — restore a life
            if let hb = (contact.bodyA.node as? HeartBug) ?? (contact.bodyB.node as? HeartBug) {
                if lives < 6 { lives += 1; updateLivesDisplay() }
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
                // Cave spider stays on web — just damage, don't remove
                if enemyNode is CaveSpider {
                    unlockBug(.caveSpider)
                    takeDamage()
                    return
                }
                // Monkey stays on tree — just damage, don't remove
                if enemyNode?.name == "monkey" {
                    unlockBug(.monkey)
                    takeDamage()
                    return
                }
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
                    case "Desert Wasp": unlockBug(.desertWasp)
                    case "Vampire Bat": unlockBug(.vampireBat)
                    case "Frost Moth": unlockBug(.frostMoth)
                    case "Cicada Bee": unlockBug(.cicadaBee)
                    default: break
                    }
                }
                else if let enemy = enemyNode as? BiomeEnemy {
                    switch enemy.biomeName {
                    case "Scorpion": unlockBug(.scorpion)
                    case "Rattlesnake": unlockBug(.rattlesnake)
                    case "Ice Spider": unlockBug(.iceSpider)
                    case "Jungle Spider": unlockBug(.jungleSpider)
                    case "Rock Worm": unlockBug(.rockWorm)
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

    private func collectGemstone(at pos: CGPoint) {
        GameScene.gemCount += 1
        gemLabel.text = "\(GameScene.gemCount)"
        SoundManager.shared.play("powerup")

        // Sparkle burst
        for _ in 0..<8 {
            let spark = SKShapeNode(circleOfRadius: 2)
            spark.fillColor = SKColor(red: 0.8, green: 0.5, blue: 1.0, alpha: 0.9)
            spark.strokeColor = .clear
            spark.position = pos
            spark.zPosition = 80
            addChild(spark)
            let dx = CGFloat.random(in: -25...25)
            let dy = CGFloat.random(in: 5...30)
            spark.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.35),
                    SKAction.fadeOut(withDuration: 0.35),
                    SKAction.scale(to: 0.2, duration: 0.35),
                ]),
                SKAction.removeFromParent()
            ]))
        }

        // Floating "+1 💎" text
        let gemText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemText.text = "+1 💎"
        gemText.fontSize = 16
        gemText.fontColor = SKColor(red: 0.85, green: 0.55, blue: 1.0, alpha: 1.0)
        gemText.position = CGPoint(x: pos.x, y: pos.y + 10)
        gemText.zPosition = 90
        addChild(gemText)
        gemText.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 35, duration: 0.7),
                SKAction.fadeOut(withDuration: 0.7),
            ]),
            SKAction.removeFromParent()
        ]))

        // Pulse gem counter
        gemLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.15),
        ]))
    }

    private func unlockBug(_ bug: BugTracker.BugType) {
        let wasNew = !BugTracker.shared.isUnlocked(bug)
        BugTracker.shared.unlock(bug)
        if wasNew {
            discoveryQueue.append(bug)
        }
    }

    private func processDiscoveryQueue() {
        guard !isShowingDiscovery, !discoveryQueue.isEmpty else { return }
        let bug = discoveryQueue.removeFirst()
        isShowingDiscovery = true
        SoundManager.shared.play("newBug")

        let banner = SKLabelNode(fontNamed: "AvenirNext-Bold")
        banner.text = "New Discovery: \(bug.rawValue)!"
        banner.fontSize = 14
        banner.fontColor = SKColor(red: 1.0, green: 0.90, blue: 0.30, alpha: 1.0)
        banner.position = CGPoint(x: size.width / 2, y: size.height - 55)
        banner.zPosition = 120
        banner.alpha = 0
        addChild(banner)
        banner.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.15),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.35),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in self?.isShowingDiscovery = false }
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

    // MARK: - Biome Spawning

    /// Difficulty multiplier for enemy spawn intervals (higher = slower spawns = fewer enemies)
    private var enemySpawnMul: Double { MenuScene.difficulty.enemyMul }
    /// Difficulty multiplier for food spawn intervals (higher = slower spawns = fewer food)
    private var foodSpawnMul: Double { MenuScene.difficulty.foodMul }

    private func spawnForBiome(dt: TimeInterval) {
        // Bushes only in meadow biomes
        if currentBiome == .meadowDay || currentBiome == .meadowNight {
            logTimer += dt
            let li = max(2.5, 5.0 - Double(distanceTraveled) * 0.0003)
            if logTimer >= li { logTimer = 0; spawnLog() }
        }

        heartBugTimer += dt
        if heartBugTimer >= 20.0 && lives < 6 { heartBugTimer = 0; spawnHeartBug() }

        envTimer += dt
        if envTimer >= 0.6 { envTimer = 0; spawnEnvironment() }

        // Difficulty-scaled dt: food spawns faster/slower, enemies slower/faster
        let fdt = dt / foodSpawnMul   // food timers: smaller mul = faster dt = more food
        let edt = dt / enemySpawnMul  // enemy timers: smaller mul = faster dt = more enemies

        switch currentBiome {
        case .meadowDay:
            aphidTimer += fdt
            if aphidTimer >= 1.2 { aphidTimer = 0; spawnAphid() }
            flyTimer += fdt
            if flyTimer >= 1.5 { flyTimer = 0; spawnFruitFly() }
            antTimer += edt
            if antTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { antTimer = 0; spawnAnt() }
            birdTimer += edt
            if birdTimer >= max(2.5, 5.5 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBird() }
            frogTimer += edt
            if frogTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnPondCreature() }

        case .meadowNight:
            gnatTimer += fdt
            if gnatTimer >= 1.0 { gnatTimer = 0; spawnGnatSwarm() }
            aphidTimer += fdt
            if aphidTimer >= 2.0 { aphidTimer = 0; spawnAphid() }
            fireflyTimer += dt // Powerups unaffected by difficulty
            if fireflyTimer >= 22.0 { fireflyTimer = 0; spawnFirefly() }
            spiderTimer += edt
            if spiderTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnSpider() }
            birdTimer += edt
            if birdTimer >= max(2.5, 5.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Bat") }
            frogTimer += edt
            if frogTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnPondCreature() }

        case .desert:
            aphidTimer += fdt
            if aphidTimer >= 1.4 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateDesertBeetleTexture(size: CGSize(width: 28, height: 24)), pts: 15, flying: false, name: "Desert Beetle") }
            flyTimer += fdt
            if flyTimer >= 1.8 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 18, height: 18), color: .brown).first!, pts: 20, flying: true, name: "Sand Fly") }
            gnatTimer += fdt
            if gnatTimer >= 2.2 { gnatTimer = 0; spawnDesertCricket() }
            dragonflyTimer += edt // Scorpions (slower, never with snake)
            if dragonflyTimer >= max(6.0, 11.0 - Double(distanceTraveled) * 0.0003) {
                dragonflyTimer = 0
                let snakeOnScreen = children.contains { ($0 as? BiomeEnemy)?.biomeName == "Rattlesnake" }
                if !snakeOnScreen { spawnBiomeGroundEnemy(texture: TextureGenerator.generateScorpionTexture(size: CGSize(width: 44, height: 34)), name: "Scorpion") }
            }
            spiderTimer += edt // Rattlesnake (slower, never with scorpion, bigger)
            if spiderTimer >= max(8.0, 13.0 - Double(distanceTraveled) * 0.0003) {
                spiderTimer = 0
                let scorpionOnScreen = children.contains { ($0 as? BiomeEnemy)?.biomeName == "Scorpion" }
                if !scorpionOnScreen { spawnBiomeGroundEnemy(texture: TextureGenerator.generateRattlesnakeTexture(size: CGSize(width: 64, height: 40)), name: "Rattlesnake") }
            }
            birdTimer += edt // Hawks
            if birdTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Hawk") }
            frogTimer += edt // Vultures
            if frogTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnVulture() }
            waspTimer += edt // Desert wasps — never spawn if vulture on screen
            if waspTimer >= max(4.5, 9.0 - Double(distanceTraveled) * 0.0003) {
                waspTimer = 0
                let vultureOnScreen = children.contains { $0.name == "vulture" }
                if !vultureOnScreen { spawnDesertWasp() }
            }

        case .snow:
            aphidTimer += fdt
            if aphidTimer >= 1.3 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateSnowFleaTexture(size: CGSize(width: 24, height: 20)), pts: 15, flying: false, name: "Snow Flea") }
            flyTimer += fdt
            if flyTimer >= 1.6 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateFruitFlyFrames(size: CGSize(width: 20, height: 20), color: .blue).first!, pts: 25, flying: true, name: "Ice Moth") }
            spiderTimer += edt
            if spiderTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnBiomeGroundEnemy(texture: TextureGenerator.generateIceSpiderTexture(size: CGSize(width: 44, height: 36)), name: "Ice Spider") }
            birdTimer += edt
            if birdTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Snow Owl") }
            fireflyTimer += dt // Powerups unaffected
            if fireflyTimer >= 15.0 { fireflyTimer = 0; spawnFirefly() }
            waspTimer += edt
            if waspTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { waspTimer = 0; spawnFrostMoth() }

        case .jungle:
            aphidTimer += fdt
            if aphidTimer >= 1.2 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateJungleBeetleTexture(size: CGSize(width: 28, height: 24)), pts: 30, flying: false, name: "Jungle Beetle") }
            flyTimer += fdt
            if flyTimer >= 1.5 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateButterflyTexture(size: CGSize(width: 22, height: 20)), pts: 20, flying: true, name: "Butterfly") }
            dragonflyTimer += edt
            if dragonflyTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { dragonflyTimer = 0; spawnPondCreature() }
            spiderTimer += edt
            if spiderTimer >= max(3.5, 7.0 - Double(distanceTraveled) * 0.0003) { spiderTimer = 0; spawnJungleSpider() }
            birdTimer += edt
            if birdTimer >= max(2.5, 5.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Toucan") }
            fireflyTimer += edt // Monkeys
            if fireflyTimer >= max(5.0, 10.0 - Double(distanceTraveled) * 0.0003) { fireflyTimer = 0; spawnMonkey() }
            waspTimer += edt
            if waspTimer >= max(5.0, 9.0 - Double(distanceTraveled) * 0.0003) { waspTimer = 0; spawnCicadaBee() }
            gnatTimer += fdt
            if gnatTimer >= 2.5 { gnatTimer = 0; spawnJungleGnatSwarm() }

        case .cave:
            aphidTimer += fdt
            if aphidTimer >= 1.3 { aphidTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateCaveCricketTexture(size: CGSize(width: 26, height: 20)), pts: 25, flying: false, name: "Cave Cricket") }
            flyTimer += fdt
            if flyTimer >= 1.6 { flyTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateGlowwormTexture(size: CGSize(width: 24, height: 20)), pts: 35, flying: true, name: "Glowworm") }
            gnatTimer += fdt
            if gnatTimer >= 4.0 { gnatTimer = 0; spawnBiomeFood(texture: TextureGenerator.generateCrystalBeetleTexture(size: CGSize(width: 26, height: 22)), pts: 50, flying: false, name: "Crystal Beetle") }
            dragonflyTimer += edt
            if dragonflyTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { dragonflyTimer = 0; spawnBiomeGroundEnemy(texture: TextureGenerator.generateRockWormTexture(size: CGSize(width: 48, height: 30)), name: "Rock Worm") }
            birdTimer += edt
            if birdTimer >= max(3.0, 6.0 - Double(distanceTraveled) * 0.0003) { birdTimer = 0; spawnBiomeSwooper(name: "Vampire Bat") }
            caveSpiderTimer += edt
            if caveSpiderTimer >= max(4.0, 8.0 - Double(distanceTraveled) * 0.0003) { caveSpiderTimer = 0; spawnCaveSpider() }
            fallingRockTimer += edt
            if fallingRockTimer >= max(3.5, 7.0 - Double(distanceTraveled) * 0.0003) { fallingRockTimer = 0; spawnFallingRock() }
            fireflyTimer += dt // Fireflies return in caves
            if fireflyTimer >= 15.0 { fireflyTimer = 0; spawnFirefly() }
            frogTimer += dt // Cave pools with fish
            if frogTimer >= max(5.0, 10.0 - Double(distanceTraveled) * 0.0003) { frogTimer = 0; spawnCavePool() }
        }
    }

    private func spawnBiomeFood(texture: SKTexture, pts: Int, flying: Bool, name: String) {
        let spawnX = size.width + 30
        if !flying && isNearGroundObject(x: spawnX, range: 60) { return }
        let food = BiomeFood(texture: texture, points: pts, biomeName: name, isFlying: flying)
        let y: CGFloat = flying ? groundY + CGFloat.random(in: 40...size.height * 0.45) : groundY + food.size.height / 2
        food.position = CGPoint(x: spawnX, y: y)
        food.minY = groundY
        // Butterflies and glowworms evade the player
        if food.biomeName == "Butterfly" {
            food.position.y = groundY + CGFloat.random(in: 80...size.height * 0.55)
            food.playerRef = ladybug
        }
        if food.biomeName == "Glowworm" { food.playerRef = ladybug }
        food.setupPhysics()
        food.startMoving()
        // ~2% chance to become a rare gemstone bug
        if Int.random(in: 1...50) == 1 { food.makeGemBug() }
        addChild(food)
    }

    // MARK: - Cave Terrain Helpers

    private func effectiveGroundY(atScreenX screenX: CGFloat) -> CGFloat {
        if let terrain = caveTerrain, isCaveBiome {
            return terrain.groundY(atScreenX: screenX)
        }
        return groundY
    }

    private func effectiveCeilingY(atScreenX screenX: CGFloat) -> CGFloat {
        if let terrain = caveTerrain, isCaveBiome {
            return terrain.ceilingY(atScreenX: screenX)
        }
        return size.height
    }

    private func setupCaveGround() {
        caveTerrain = CaveTerrain(baseGroundY: groundY, screenHeight: size.height)
        let tileWidth = size.width + 10
        for i in 0..<3 {
            let gTile = SKShapeNode()
            gTile.fillColor = Biome.cave.groundColor
            gTile.strokeColor = .clear
            gTile.position = CGPoint(x: CGFloat(i) * (tileWidth - 10), y: 0)
            gTile.zPosition = 0
            gTile.name = "caveGroundTile"
            gTile.alpha = 0
            addChild(gTile)
            caveGroundTiles.append(gTile)

            let cTile = SKShapeNode()
            cTile.fillColor = Biome.cave.ceilingColor
            cTile.strokeColor = .clear
            cTile.position = CGPoint(x: CGFloat(i) * (tileWidth - 10), y: 0)
            cTile.zPosition = 0
            cTile.name = "caveCeilingTile"
            cTile.alpha = 0
            addChild(cTile)
            caveCeilingTiles.append(cTile)
        }
        regenerateAllCaveTilePaths()
    }

    private func regenerateAllCaveTilePaths() {
        let tileWidth = size.width + 10
        for (i, gTile) in caveGroundTiles.enumerated() {
            let left = gTile.position.x
            gTile.path = caveTerrain?.groundTilePath(tileLeft: left, tileWidth: tileWidth)
            caveCeilingTiles[i].position.x = gTile.position.x
            caveCeilingTiles[i].path = caveTerrain?.ceilingTilePath(tileLeft: left, tileWidth: tileWidth, tileHeight: size.height)
        }
    }

    private func regenerateCaveTilePath(index: Int) {
        let tileWidth = size.width + 10
        let gTile = caveGroundTiles[index]
        gTile.path = caveTerrain?.groundTilePath(tileLeft: gTile.position.x, tileWidth: tileWidth)
        caveCeilingTiles[index].position.x = gTile.position.x
        caveCeilingTiles[index].path = caveTerrain?.ceilingTilePath(tileLeft: gTile.position.x, tileWidth: tileWidth, tileHeight: size.height)
    }

    private func isNearBiomeEnemy(x: CGFloat, range: CGFloat) -> Bool {
        for child in children {
            if child is BiomeEnemy, abs(child.position.x - x) < range { return true }
        }
        return false
    }

    private func spawnBiomeGroundEnemy(texture: SKTexture, name: String) {
        let spawnX = size.width + 40
        if isNearGroundObject(x: spawnX, range: 80) { return }
        if isNearBiomeEnemy(x: spawnX, range: 160) { return }
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
        case "Vampire Bat": frames = vampireBatFrames
        case "Frost Moth": frames = frostMothFrames
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
        case "Vampire Bat": SoundManager.shared.play("screech")
        case "Frost Moth": SoundManager.shared.play("flutter")
        case "Snow Owl": SoundManager.shared.play("hoot")
        case "Toucan": SoundManager.shared.play("squawk")
        default: SoundManager.shared.play("caw")
        }
        // Delayed whoosh as it dives
        swooper.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run {
            SoundManager.shared.play("whoosh")
        }]))
        let targetY = ladybug.position.y
        swooper.swoopAcross(sceneWidth: size.width, ladybugX: ladybug.position.x,
                            targetY: targetY, groundY: groundY,
                            duration: 2.4 + Double.random(in: 0...0.6))
    }

    private func spawnVulture() {
        let vulture = Dragonfly(textures: vultureFrames)
        vulture.position = CGPoint(x: size.width + 60, y: groundY + CGFloat.random(in: 60...size.height * 0.55))
        vulture.name = "vulture"
        vulture.setupPhysics()
        vulture.startHovering(minY: groundY + 50, maxY: size.height * 0.94, playerX: ladybug.position.x)
        addChild(vulture)
        SoundManager.shared.play("screech")
    }

    private func spawnDesertCricket() {
        let spawnX = size.width + 30
        if isNearGroundObject(x: spawnX, range: 60) { return }
        if isNearBiomeEnemy(x: spawnX, range: 140) { return }
        let texture = TextureGenerator.generateDesertCricketTexture(size: CGSize(width: 28, height: 22))
        let cricket = BiomeFood(texture: texture, points: 50, biomeName: "Desert Cricket", isFlying: false)
        cricket.position = CGPoint(x: spawnX, y: groundY + cricket.size.height / 2)
        cricket.minY = groundY
        cricket.setupPhysics()
        addChild(cricket)

        // Hopping animation — squat, leap, land, recover
        let baseY = groundY + cricket.size.height / 2
        let hop = SKAction.run { [weak cricket] in
            guard let cricket = cricket else { return }
            let dist = CGFloat.random(in: -30...30)
            let height = CGFloat.random(in: 22...42)
            // Face hop direction
            let dir: CGFloat = dist >= 0 ? 1.0 : -1.0
            let squat = SKAction.group([SKAction.scaleX(to: 1.18 * dir, duration: 0.08), SKAction.scaleY(to: 0.82, duration: 0.08)])
            let launch = SKAction.group([SKAction.scaleX(to: 0.82 * dir, duration: 0.14), SKAction.scaleY(to: 1.28, duration: 0.14), SKAction.moveBy(x: dist * 0.5, y: height, duration: 0.18)])
            let fall = SKAction.group([SKAction.scaleX(to: 1.0 * dir, duration: 0.14), SKAction.scaleY(to: 1.0, duration: 0.14), SKAction.moveBy(x: dist * 0.5, y: -height, duration: 0.18)])
            let land = SKAction.group([SKAction.scaleX(to: 1.14 * dir, duration: 0.06), SKAction.scaleY(to: 0.88, duration: 0.06)])
            let recover = SKAction.group([SKAction.scaleX(to: 1.0 * dir, duration: 0.08), SKAction.scaleY(to: 1.0, duration: 0.08)])
            let fixY = SKAction.run { cricket.position.y = baseY }
            cricket.run(SKAction.sequence([squat, launch, fall, land, recover, fixY]))
        }
        cricket.run(SKAction.repeatForever(SKAction.sequence([hop, SKAction.wait(forDuration: 0.8, withRange: 0.5)])), withKey: "hop")
    }

    private func spawnDesertWasp() {
        // Only one wasp on screen at a time
        for child in children {
            if let s = child as? BiomeSwooper, s.biomeName == "Desert Wasp" { return }
        }
        let wasp = BiomeSwooper(textures: waspFrames, biomeName: "Desert Wasp")
        // Spawn high — top 30% of sky
        let spawnY = size.height * CGFloat.random(in: 0.72...0.92)
        wasp.position = CGPoint(x: size.width + 50, y: spawnY)
        wasp.xScale = -1
        wasp.setupPhysics()
        addChild(wasp)
        unlockBug(.desertWasp)
        SoundManager.shared.play("screech")

        // Patrol: move horizontally across screen, bobbing up/down, then exit left
        let patrolDuration: TimeInterval = 7.0 + Double.random(in: 0...3.0)
        let minY = size.height * 0.65
        let maxY = size.height * 0.95

        // Drift slowly left across the screen while bobbing
        let driftLeft = SKAction.moveBy(x: -(size.width + 100), y: 0, duration: patrolDuration)
        // Bob up/down randomly
        let bobStep = SKAction.run { [weak wasp] in
            guard let wasp = wasp else { return }
            let targetY = CGFloat.random(in: minY...maxY)
            let dy = targetY - wasp.position.y
            let move = SKAction.moveBy(x: 0, y: dy, duration: Double.random(in: 0.6...1.2))
            move.timingMode = .easeInEaseOut
            wasp.run(move, withKey: "waspBob")
        }
        let bobWait = SKAction.wait(forDuration: 0.8, withRange: 0.4)

        wasp.run(driftLeft)
        wasp.run(SKAction.repeatForever(SKAction.sequence([bobStep, bobWait])))
        wasp.run(SKAction.sequence([SKAction.wait(forDuration: patrolDuration + 0.2), SKAction.removeFromParent()]))
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

    private func spawnCicadaBee() {
        for child in children {
            if let s = child as? BiomeSwooper, s.biomeName == "Cicada Bee" { return }
        }
        let frames = TextureGenerator.generateCicadaBeeFrames(size: CGSize(width: 52, height: 32))
        let bee = BiomeSwooper(textures: frames, biomeName: "Cicada Bee")
        bee.position = CGPoint(x: size.width + 50, y: size.height * CGFloat.random(in: 0.60...0.88))
        bee.xScale = -1
        bee.setupPhysics()
        addChild(bee)
        unlockBug(.cicadaBee)
        SoundManager.shared.play("buzz")
        let dur: TimeInterval = 6.0 + Double.random(in: 0...3.0)
        let minY = size.height * 0.50
        let maxY = size.height * 0.90
        bee.run(SKAction.moveBy(x: -(size.width + 100), y: 0, duration: dur))
        let bob = SKAction.run { [weak bee] in
            guard let bee = bee else { return }
            let dy = CGFloat.random(in: minY...maxY) - bee.position.y
            let m = SKAction.moveBy(x: 0, y: dy, duration: Double.random(in: 0.5...1.0))
            m.timingMode = .easeInEaseOut
            bee.run(m, withKey: "beeBob")
        }
        bee.run(SKAction.repeatForever(SKAction.sequence([bob, SKAction.wait(forDuration: 0.7, withRange: 0.3)])))
        bee.run(SKAction.sequence([SKAction.wait(forDuration: dur + 0.2), SKAction.removeFromParent()]))
    }

    private func spawnJungleGnatSwarm() {
        let swarm = GnatSwarm()
        let y = groundY + CGFloat.random(in: 30...size.height * 0.35)
        swarm.position = CGPoint(x: size.width + 30, y: y)
        swarm.minY = groundY
        // Tint individual gnat dots darker (not the parent — avoids black box)
        for child in swarm.children {
            if let dot = child as? SKShapeNode {
                dot.fillColor = SKColor(red: 0.25, green: 0.18, blue: 0.10, alpha: 0.75)
            }
        }
        swarm.setupPhysics()
        swarm.startMoving()
        addChild(swarm)
    }

    private func spawnFrostMoth() {
        // Only one on screen
        for child in children {
            if let s = child as? BiomeSwooper, s.biomeName == "Frost Moth" { return }
        }
        let moth = BiomeSwooper(textures: frostMothFrames, biomeName: "Frost Moth")
        let spawnY = size.height * CGFloat.random(in: 0.65...0.90)
        moth.position = CGPoint(x: size.width + 50, y: spawnY)
        moth.xScale = -1
        moth.setupPhysics()
        addChild(moth)
        unlockBug(.frostMoth)
        SoundManager.shared.play("flutter")

        // Patrol: drift left across screen, bobbing up/down (like desert wasp)
        let patrolDuration: TimeInterval = 7.0 + Double.random(in: 0...3.0)
        let minY = size.height * 0.55
        let maxY = size.height * 0.92
        let driftLeft = SKAction.moveBy(x: -(size.width + 100), y: 0, duration: patrolDuration)
        let bobStep = SKAction.run { [weak moth] in
            guard let moth = moth else { return }
            let targetY = CGFloat.random(in: minY...maxY)
            let dy = targetY - moth.position.y
            let move = SKAction.moveBy(x: 0, y: dy, duration: Double.random(in: 0.6...1.2))
            move.timingMode = .easeInEaseOut
            moth.run(move, withKey: "mothBob")
        }
        moth.run(driftLeft)
        moth.run(SKAction.repeatForever(SKAction.sequence([bobStep, SKAction.wait(forDuration: 0.8, withRange: 0.4)])))
        moth.run(SKAction.sequence([SKAction.wait(forDuration: patrolDuration + 0.2), SKAction.removeFromParent()]))
    }

    private func spawnCavePool() {
        guard let terrain = caveTerrain else { return }
        let spawnX = size.width + 60
        if isNearGroundObject(x: spawnX, range: 140) { return }
        if isNearBiomeEnemy(x: spawnX, range: 120) { return }

        let gY = terrain.groundY(atScreenX: spawnX)
        let poolW = CGFloat.random(in: 80...120)

        // Deep pool — sinks below ground level
        let pool = SKShapeNode(ellipseOf: CGSize(width: poolW, height: 20))
        pool.fillColor = SKColor(red: 0.12, green: 0.22, blue: 0.38, alpha: 0.7)
        pool.strokeColor = SKColor(red: 0.18, green: 0.30, blue: 0.45, alpha: 0.5)
        pool.lineWidth = 1.5
        pool.position = CGPoint(x: spawnX, y: gY - 2)
        pool.zPosition = 2
        pool.name = "pond"
        addChild(pool)

        // Fish swimming in pool
        let fishTex = TextureGenerator.generateCaveFishTexture(size: CGSize(width: 22, height: 14))
        let fishCount = Int.random(in: 1...2)
        for i in 0..<fishCount {
            let fish = SKSpriteNode(texture: fishTex, size: CGSize(width: 22, height: 14))
            fish.position = CGPoint(x: spawnX + CGFloat(i * 20 - 10), y: gY - 4)
            fish.zPosition = 3
            fish.name = "envDecor"
            // Swim back and forth
            let swimDist = poolW * 0.3
            let swimR = SKAction.sequence([
                SKAction.run { [weak fish] in fish?.xScale = 1 },
                SKAction.moveBy(x: swimDist, y: 0, duration: Double.random(in: 1.2...2.0))
            ])
            let swimL = SKAction.sequence([
                SKAction.run { [weak fish] in fish?.xScale = -1 },
                SKAction.moveBy(x: -swimDist, y: 0, duration: Double.random(in: 1.2...2.0))
            ])
            let pause = SKAction.wait(forDuration: Double.random(in: 0.3...0.8))
            fish.run(SKAction.repeatForever(SKAction.sequence([swimR, pause, swimL, pause])))
            addChild(fish)
        }

        // Jumping fish — one fish periodically leaps out of pool
        let jumpFish = SKSpriteNode(texture: fishTex, size: CGSize(width: 22, height: 14))
        jumpFish.position = CGPoint(x: spawnX, y: gY - 4)
        jumpFish.zPosition = 7
        jumpFish.alpha = 0
        jumpFish.name = "envDecor"
        // Physics — damages ladybug when jumping
        let jBody = SKPhysicsBody(circleOfRadius: 8)
        jBody.isDynamic = false
        jBody.categoryBitMask = GameScene.PhysicsCategory.bird
        jBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        jumpFish.physicsBody = jBody
        addChild(jumpFish)

        // Jump cycle: wait → appear → arc up (face up) → arc down (face down) → hide
        let jumpCycle = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 2.5...5.0)),
            SKAction.run { [weak jumpFish] in
                jumpFish?.alpha = 1
                jumpFish?.zRotation = .pi / 2 // face up
                SoundManager.shared.play("splash")
            },
            SKAction.moveBy(x: CGFloat.random(in: -15...15), y: 60, duration: 0.35),
            SKAction.run { [weak jumpFish] in
                jumpFish?.zRotation = -.pi / 2 // face down
            },
            SKAction.moveBy(x: 0, y: -60, duration: 0.30),
            SKAction.run { [weak jumpFish, weak self] in
                jumpFish?.alpha = 0
                jumpFish?.zRotation = 0
                guard let self = self, let terrain = self.caveTerrain else { return }
                let gY = terrain.groundY(atScreenX: jumpFish?.position.x ?? 0)
                jumpFish?.position.y = gY - 4
                // Splash particles
                if let pos = jumpFish?.position {
                    for _ in 0..<4 {
                        let drop = SKShapeNode(circleOfRadius: 1.5)
                        drop.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 0.6)
                        drop.strokeColor = .clear
                        drop.position = CGPoint(x: pos.x + CGFloat.random(in: -10...10), y: pos.y + 5)
                        drop.zPosition = 6
                        drop.name = "envDecor"
                        self.addChild(drop)
                        drop.run(SKAction.sequence([
                            SKAction.group([SKAction.moveBy(x: CGFloat.random(in: -8...8), y: CGFloat.random(in: 5...15), duration: 0.3), SKAction.fadeOut(withDuration: 0.3)]),
                            SKAction.removeFromParent()
                        ]))
                    }
                }
            },
        ])
        jumpFish.run(SKAction.repeatForever(jumpCycle))
    }

    private func spawnCaveSpider() {
        guard let terrain = caveTerrain else { return }
        let spawnX = size.width + 40
        // Don't spawn directly above ground enemies
        if isNearBiomeEnemy(x: spawnX, range: 100) { return }
        let ceilY = terrain.ceilingY(atScreenX: spawnX)
        let texture = TextureGenerator.generateCaveSpiderTexture(size: CGSize(width: 40, height: 34))
        let spider = CaveSpider(texture: texture, ceilingY: ceilY)
        let hangLen = CGFloat.random(in: 30...60)
        spider.position = CGPoint(x: spawnX, y: ceilY - hangLen)
        spider.setupPhysics()
        spider.startSwaying()
        addChild(spider)
        unlockBug(.caveSpider)
    }

    private func spawnFallingRock() {
        guard let terrain = caveTerrain else { return }
        let targetX = CGFloat.random(in: size.width * 0.3...size.width * 0.85)
        let gY = terrain.groundY(atScreenX: targetX)
        let cY = terrain.ceilingY(atScreenX: targetX)
        let rockSize = CGSize(width: CGFloat.random(in: 20...34), height: CGFloat.random(in: 18...28))
        let rock = FallingRock(rockSize: rockSize, groundY: gY, ceilingY: cY)
        rock.position = CGPoint(x: targetX, y: cY)
        addChild(rock)
        let shadow = rock.createWarningShadow(groundY: gY)
        addChild(shadow)
    }

    private func spawnMonkey() {
        let spawnX = size.width + 30
        if isNearGroundObject(x: spawnX, range: 80) { return }
        // Avoid overlapping with existing envDecor trees
        for child in children where child.name == "envDecor" {
            if abs(child.position.x - spawnX) < 60 && child.position.y > groundY + 40 { return }
        }

        // Spawn a tree trunk for the monkey to climb (big)
        let trunkH: CGFloat = CGFloat.random(in: 200...280)
        let trunk = SKShapeNode(rectOf: CGSize(width: 22, height: trunkH))
        trunk.fillColor = SKColor(red: 0.32, green: 0.20, blue: 0.08, alpha: 0.9)
        trunk.strokeColor = .clear
        trunk.position = CGPoint(x: spawnX, y: groundY + trunkH / 2)
        trunk.zPosition = 1
        trunk.name = "envDecor"
        addChild(trunk)
        // Small canopy on top
        // Layered canopy with leaves
        for (dx, dy, r) in [(-20.0, 5.0, 28.0), (16.0, 12.0, 26.0), (0.0, 25.0, 32.0), (-14.0, 30.0, 24.0), (10.0, 32.0, 20.0)] as [(CGFloat, CGFloat, CGFloat)] {
            let leaf = SKShapeNode(circleOfRadius: r)
            leaf.fillColor = SKColor(red: CGFloat.random(in: 0.10...0.16), green: CGFloat.random(in: 0.42...0.55), blue: 0.12, alpha: 0.85)
            leaf.strokeColor = .clear
            leaf.position = CGPoint(x: spawnX + dx, y: groundY + trunkH + dy)
            leaf.zPosition = 1
            leaf.name = "envDecor"
            addChild(leaf)
        }

        let texture = TextureGenerator.generateMonkeyTexture(size: CGSize(width: 56, height: 60))
        let monkey = SKSpriteNode(texture: texture, color: .clear, size: texture.size())
        monkey.name = "monkey"
        monkey.zPosition = 6
        monkey.xScale = -1
        let body = SKPhysicsBody(rectangleOf: CGSize(width: texture.size().width * 0.55, height: texture.size().height * 0.65))
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        monkey.physicsBody = body
        monkey.position = CGPoint(x: spawnX, y: groundY + monkey.size.height / 2)
        addChild(monkey)
        unlockBug(.monkey)

        let climbHeight = CGFloat.random(in: 140...210)
        let upDur = Double.random(in: 1.4...2.2)
        let downDur = Double.random(in: 1.4...2.2)
        let pause = SKAction.wait(forDuration: Double.random(in: 0.3...0.7))
        let up = SKAction.moveBy(x: 0, y: climbHeight, duration: upDur)
        up.timingMode = .easeInEaseOut
        let down = SKAction.moveBy(x: 0, y: -climbHeight, duration: downDur)
        down.timingMode = .easeInEaseOut
        monkey.run(SKAction.repeatForever(SKAction.sequence([up, pause, down, pause])), withKey: "climb")
    }

    // MARK: - Biome Transitions

    private func transitionToBiome(_ biome: Biome) {
        // Stop previous biome effects
        removeAction(forKey: "snowfall")
        removeAction(forKey: "shootingStars")

        // Fade out and remove all previous sky decorations
        for child in children {
            switch child.name {
            case "skyBg", "cloud", "hill", "nightBg", "nightOverlay":
                child.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.5), SKAction.removeFromParent()]))
            default: break
            }
        }

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
        skyOverlay.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5))

        // Night-specific effects
        if biome == .meadowNight {
            isNight = true
            hasTransitionedToNight = true
            transitionToNight()
        }

        // Desert: warm gradient sky (golden horizon fading to deeper orange top)
        if biome == .desert {
            let horizonBand = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height * 0.25))
            horizonBand.fillColor = SKColor(red: 0.95, green: 0.78, blue: 0.45, alpha: 0.5)
            horizonBand.strokeColor = .clear
            horizonBand.position = CGPoint(x: size.width / 2, y: groundY + size.height * 0.12)
            horizonBand.zPosition = -0.8
            horizonBand.alpha = 0
            addChild(horizonBand)
            horizonBand.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5))

            let midBand = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height * 0.20))
            midBand.fillColor = SKColor(red: 0.90, green: 0.65, blue: 0.30, alpha: 0.35)
            midBand.strokeColor = .clear
            midBand.position = CGPoint(x: size.width / 2, y: size.height * 0.50)
            midBand.zPosition = -0.8
            midBand.alpha = 0
            addChild(midBand)
            midBand.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5))
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


        // Jungle: warm haze gradient near horizon
        if biome == .jungle {
            let horizonBand = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height * 0.20))
            horizonBand.fillColor = SKColor(red: 0.45, green: 0.60, blue: 0.35, alpha: 0.35)
            horizonBand.strokeColor = .clear
            horizonBand.position = CGPoint(x: size.width / 2, y: groundY + size.height * 0.10)
            horizonBand.zPosition = -0.8
            horizonBand.alpha = 0
            addChild(horizonBand)
            horizonBand.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5))
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

        // Cave: setup cave terrain, fade flat tiles, show cave tiles
        if biome == .cave {
            setupCaveGround()
            // Fade in cave tiles, fade out flat tiles
            for tile in caveGroundTiles { tile.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5)) }
            for tile in caveCeilingTiles { tile.run(SKAction.fadeAlpha(to: 1.0, duration: 2.5)) }
            for tile in groundTiles { tile.run(SKAction.fadeAlpha(to: 0.0, duration: 2.5)) }
            // Dark ambient overlay for cave atmosphere
            let ambient = SKShapeNode(rectOf: CGSize(width: size.width + 20, height: size.height))
            ambient.fillColor = SKColor(red: 0.05, green: 0.03, blue: 0.08, alpha: 0.3)
            ambient.strokeColor = .clear
            ambient.position = CGPoint(x: size.width / 2, y: size.height / 2)
            ambient.zPosition = 45
            addChild(ambient)
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
        nightOverlay.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.0)
        nightOverlay.strokeColor = .clear
        nightOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        nightOverlay.zPosition = -1
        nightOverlay.name = "nightOverlay"
        addChild(nightOverlay)
        nightOverlay.run(SKAction.customAction(withDuration: 3.0) { node, elapsed in
            let p = min(1.0, elapsed / 3.0)
            (node as? SKShapeNode)?.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.20 * p)
        })

        // Darken ground
        for tile in groundTiles {
            tile.run(SKAction.colorize(with: SKColor(red: 0.22, green: 0.40, blue: 0.18, alpha: 1), colorBlendFactor: 0.25, duration: 3.0))
        }

        // Moon (fixed position, top-right)
        let moon = SKShapeNode(circleOfRadius: 20)
        moon.fillColor = SKColor(red: 0.95, green: 0.93, blue: 0.80, alpha: 0.9)
        moon.strokeColor = .clear
        moon.position = CGPoint(x: size.width * 0.82, y: size.height * 0.88)
        moon.zPosition = -0.5
        moon.alpha = 0
        moon.name = "nightBg"
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
            star.name = "nightBg"
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

            // Menu button
            let menuBg = SKShapeNode(rectOf: CGSize(width: 140, height: 34), cornerRadius: 8)
            menuBg.fillColor = SKColor(red: 0.55, green: 0.15, blue: 0.15, alpha: 0.9)
            menuBg.strokeColor = SKColor(white: 1.0, alpha: 0.3)
            menuBg.lineWidth = 1
            menuBg.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
            menuBg.zPosition = 141
            menuBg.name = "pauseMenuBtn"
            addChild(menuBg)
            let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            menuLabel.text = "Back to Menu"
            menuLabel.fontSize = 14
            menuLabel.fontColor = .white
            menuLabel.verticalAlignmentMode = .center
            menuLabel.name = "pauseMenuBtn"
            menuBg.addChild(menuLabel)
        } else {
            enumerateChildNodes(withName: "pauseOverlay") { node, _ in node.removeFromParent() }
            enumerateChildNodes(withName: "resumeLabel") { node, _ in node.removeFromParent() }
            enumerateChildNodes(withName: "pauseMenuBtn") { node, _ in node.removeFromParent() }
            lastUpdateTime = 0 // Reset to avoid big dt jump
        }
    }

    // MARK: - Boss Fight

    private func startBossFight() {
        isBossFight = true
        bossHP = 20
        bossAttackTimer = 0
        bossAttackPhase = 0
        bossBerryTimer = 0

        // Save checkpoint
        GameScene.hasNightCheckpoint = true
        GameScene.checkpointScore = 6000
        GameScene.unlockBiome(.cave)

        // Clear all existing entities from screen
        for child in children {
            if child is Aphid || child is FruitFly || child is Log || child is Bird ||
               child is Frog || child is Dragonfly || child is Firefly || child is HeartBug ||
               child is Ant || child is Spider || child is GnatSwarm || child is BiomeFood ||
               child is BiomeEnemy || child is BiomeSwooper || child is CaveSpider ||
               child is FallingRock || child.name == "monkey" || child.name == "envDecor" {
                child.removeFromParent()
            }
        }

        // Banner with dramatic entry
        let banner = SKLabelNode(fontNamed: "AvenirNext-Bold")
        banner.text = "BOSS FIGHT!"
        banner.fontSize = 36
        banner.fontColor = SKColor(red: 1, green: 0.25, blue: 0.15, alpha: 1)
        banner.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        banner.zPosition = 130
        banner.setScale(0.3)
        addChild(banner)
        banner.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.4),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))

        SoundManager.shared.play("roar")

        // Bear appears from right — big and menacing
        let bearTex = TextureGenerator.generateBearTexture(size: CGSize(width: 200, height: 150))
        let bear = SKSpriteNode(texture: bearTex, size: CGSize(width: 200, height: 150))
        bear.position = CGPoint(x: size.width + 120, y: groundY + 75)
        bear.xScale = -1
        bear.zPosition = 8
        bear.name = "boss"
        addChild(bear)
        bossNode = bear

        // Dramatic entrance: shake + walk in
        bear.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.moveTo(x: size.width * 0.75, duration: 1.5)
        ]))
        // Bear idle breathing
        let breathe = SKAction.sequence([
            SKAction.scaleY(to: -1.03, duration: 0.8),
            SKAction.scaleY(to: -0.97, duration: 0.8),
        ])
        bear.run(SKAction.repeatForever(breathe), withKey: "breathe")

        // Health bar background (above bear)
        let hpBg = SKShapeNode(rectOf: CGSize(width: 104, height: 10), cornerRadius: 3)
        hpBg.fillColor = SKColor(red: 0.2, green: 0.1, blue: 0.1, alpha: 0.8)
        hpBg.strokeColor = SKColor(white: 0.5, alpha: 0.6)
        hpBg.lineWidth = 1
        hpBg.position = CGPoint(x: 0, y: 85)
        hpBg.zPosition = 10
        hpBg.name = "bossHPBg"
        bear.addChild(hpBg)

        // Health bar fill
        let hpBar = SKShapeNode(rectOf: CGSize(width: 100, height: 6), cornerRadius: 2)
        hpBar.fillColor = SKColor(red: 0.85, green: 0.15, blue: 0.10, alpha: 1)
        hpBar.strokeColor = .clear
        hpBar.position = CGPoint(x: 0, y: 85)
        hpBar.zPosition = 11
        hpBar.name = "bossHPBar"
        bear.addChild(hpBar)
        bossHPLabel = nil // Not using text anymore
    }

    private func updateBossHP() {
        guard let boss = bossNode else { return }
        let ratio = CGFloat(bossHP) / 20.0
        if let bar = boss.childNode(withName: "bossHPBar") as? SKShapeNode {
            let w = 100 * ratio
            bar.path = CGPath(roundedRect: CGRect(x: -w / 2, y: -3, width: w, height: 6), cornerWidth: 2, cornerHeight: 2, transform: nil)
            // Color shifts from green to yellow to red as HP drops
            if ratio > 0.5 {
                bar.fillColor = SKColor(red: 0.15, green: 0.75, blue: 0.15, alpha: 1)
            } else if ratio > 0.25 {
                bar.fillColor = SKColor(red: 0.85, green: 0.70, blue: 0.10, alpha: 1)
            } else {
                bar.fillColor = SKColor(red: 0.85, green: 0.15, blue: 0.10, alpha: 1)
            }
        }
    }

    private func updateBossFight(dt: TimeInterval) {
        guard isBossFight, bossHP > 0 else { return }

        bossAttackTimer += dt
        bossBerryTimer += dt

        // Ladybug X movement during boss fight — follows touch with smooth lerp
        if let tx = touchX {
            let dx = tx - ladybug.position.x
            ladybug.position.x += dx * 0.08
            ladybug.position.x = max(ladybug.size.width / 2, min(size.width * 0.60, ladybug.position.x))
        }

        // Boss attacks faster as HP drops — every 2.5s at full HP, 1.2s at low HP
        let attackInterval = 1.2 + 1.3 * (CGFloat(bossHP) / 20.0)
        if bossAttackTimer >= Double(attackInterval) {
            bossAttackTimer = 0
            let phase = bossAttackPhase % 4
            bossAttackPhase += 1

            switch phase {
            case 0: bossThrowRock()
            case 1: bossThrowRock(); bossThrowRock() // Double rocks
            case 2: bossCharge()
            default: bossGroundSlam()
            }
        }

        // Bubble berry every 10s
        if bossBerryTimer >= 10.0 {
            bossBerryTimer = 0
            spawnBubbleBerry()
        }

        // Bubble shooting mode
        if isBubbleMode {
            bubbleTimer += dt
            bubbleDuration -= dt
            if bubbleDuration <= 0 {
                isBubbleMode = false
                ladybug.colorBlendFactor = 0
            } else if bubbleTimer >= 0.3 {
                bubbleTimer = 0
                shootBubble()
            }
        }

        // Scroll bubbles and check hits
        for child in children where child.name == "bubble" {
            child.position.x += 400 * CGFloat(dt)
            if child.position.x > size.width + 20 { child.removeFromParent(); continue }
            if let boss = bossNode, boss.frame.contains(child.position) {
                child.removeFromParent()
                damageBoss()
            }
        }
    }

    private func bossThrowRock() {
        guard let boss = bossNode else { return }
        let rockSize = CGSize(width: CGFloat.random(in: 22...32), height: CGFloat.random(in: 20...28))
        let tex = TextureGenerator.generateFallingRockTexture(size: rockSize)
        let rock = SKSpriteNode(texture: tex, size: rockSize)
        rock.position = CGPoint(x: boss.position.x - 40, y: boss.position.y + CGFloat.random(in: -20...30))
        rock.zPosition = 7
        rock.name = "bossRock"
        let body = SKPhysicsBody(circleOfRadius: rockSize.width / 2 * 0.6)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.bird
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        rock.physicsBody = body
        addChild(rock)
        SoundManager.shared.play("whoosh")
        let targetY = groundY + CGFloat.random(in: 20...size.height * 0.60)
        rock.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: -50, y: targetY), duration: 1.2),
            SKAction.removeFromParent()
        ]))
    }

    private func bossCharge() {
        guard let boss = bossNode else { return }
        SoundManager.shared.play("roar")
        let startX = boss.position.x
        let charge = SKAction.sequence([
            SKAction.moveTo(x: -60, duration: 0.8),
            SKAction.wait(forDuration: 0.3),
            SKAction.moveTo(x: startX, duration: 1.0),
        ])
        charge.timingMode = .easeInEaseOut
        boss.run(charge)
    }

    private func bossGroundSlam() {
        guard let boss = bossNode else { return }
        SoundManager.shared.play("crunch")
        // Visual shockwave along ground
        let wave = SKShapeNode(rectOf: CGSize(width: 30, height: 8), cornerRadius: 4)
        wave.fillColor = SKColor(red: 0.60, green: 0.45, blue: 0.30, alpha: 0.7)
        wave.strokeColor = .clear
        wave.position = CGPoint(x: boss.position.x - 50, y: groundY + 6)
        wave.zPosition = 3
        wave.name = "shockwave"
        let wBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 8))
        wBody.isDynamic = false
        wBody.categoryBitMask = GameScene.PhysicsCategory.bird
        wBody.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        wave.physicsBody = wBody
        addChild(wave)
        wave.run(SKAction.sequence([
            SKAction.moveBy(x: -(size.width + 60), y: 0, duration: 0.8),
            SKAction.removeFromParent()
        ]))
        // Bear slam animation
        boss.run(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.15),
            SKAction.moveBy(x: 0, y: -20, duration: 0.08),
        ]))
    }

    private func spawnBubbleBerry() {
        let berry = SKShapeNode(circleOfRadius: 10)
        berry.fillColor = SKColor(red: 0.30, green: 0.70, blue: 1.0, alpha: 0.8)
        berry.strokeColor = SKColor(red: 0.40, green: 0.80, blue: 1.0, alpha: 0.6)
        berry.lineWidth = 2
        berry.position = CGPoint(x: CGFloat.random(in: size.width * 0.15...size.width * 0.50),
                                  y: CGFloat.random(in: groundY + 40...size.height * 0.65))
        berry.zPosition = 9
        berry.name = "bubbleBerry"
        addChild(berry)
        // Glow pulse
        let pulse = SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.4), SKAction.fadeAlpha(to: 1.0, duration: 0.4)])
        berry.run(SKAction.repeatForever(pulse))
        // Physics
        let body = SKPhysicsBody(circleOfRadius: 10)
        body.isDynamic = false
        body.categoryBitMask = GameScene.PhysicsCategory.fruitfly
        body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
        berry.physicsBody = body
        // Remove after 6s if not collected
        berry.run(SKAction.sequence([SKAction.wait(forDuration: 6), SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
    }

    private func collectBubbleBerry() {
        isBubbleMode = true
        bubbleDuration = 4.0
        bubbleTimer = 0
        SoundManager.shared.play("powerup")
        ladybug.color = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1)
        ladybug.colorBlendFactor = 0.4
        // Flash text
        let txt = SKLabelNode(fontNamed: "AvenirNext-Bold")
        txt.text = "BUBBLE MODE!"
        txt.fontSize = 18
        txt.fontColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1)
        txt.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        txt.zPosition = 130
        addChild(txt)
        txt.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
    }

    private func shootBubble() {
        let bubble = SKShapeNode(circleOfRadius: 6)
        bubble.fillColor = SKColor(red: 0.40, green: 0.75, blue: 1.0, alpha: 0.6)
        bubble.strokeColor = SKColor(red: 0.50, green: 0.85, blue: 1.0, alpha: 0.8)
        bubble.lineWidth = 1.5
        bubble.position = CGPoint(x: ladybug.position.x + 15, y: ladybug.position.y)
        bubble.zPosition = 9
        bubble.name = "bubble"
        addChild(bubble)
        SoundManager.shared.play("pop")
    }

    private func damageBoss() {
        bossHP -= 1
        updateBossHP()
        SoundManager.shared.play("bossHit")
        bossNode?.run(SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.15),
        ]))
        if bossHP <= 0 { bossDefeated() }
    }

    private func bossDefeated() {
        isBossFight = false
        SoundManager.shared.play("powerup")
        // Bear runs away
        bossNode?.run(SKAction.sequence([
            SKAction.moveTo(x: size.width + 200, duration: 1.0),
            SKAction.removeFromParent()
        ]))
        // Clean up boss projectiles
        enumerateChildNodes(withName: "bossRock") { n, _ in n.removeFromParent() }
        enumerateChildNodes(withName: "shockwave") { n, _ in n.removeFromParent() }
        enumerateChildNodes(withName: "bubbleBerry") { n, _ in n.removeFromParent() }
        enumerateChildNodes(withName: "bubble") { n, _ in n.removeFromParent() }
        // Victory banner
        let victory = SKLabelNode(fontNamed: "AvenirNext-Bold")
        victory.text = "VICTORY!"
        victory.fontSize = 40
        victory.fontColor = SKColor(red: 1, green: 0.85, blue: 0.0, alpha: 1)
        victory.position = CGPoint(x: size.width / 2, y: size.height / 2 + 10)
        victory.zPosition = 130
        addChild(victory)
        victory.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.4, duration: 0.5), SKAction.fadeAlpha(to: 1, duration: 0.1)]),
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                // Award bonus gems
                GameScene.gemCount += 10
                self.gemLabel.text = "\(GameScene.gemCount)"
                // Return to menu
                let menu = MenuScene(size: self.size)
                menu.scaleMode = self.scaleMode
                self.view?.presentScene(menu, transition: .fade(withDuration: 0.5))
            }
        ]))
        // Gem reward text
        let gemReward = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemReward.text = "+10 💎"
        gemReward.fontSize = 22
        gemReward.fontColor = SKColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1)
        gemReward.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
        gemReward.zPosition = 130
        addChild(gemReward)
        gemReward.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.fadeOut(withDuration: 3.0), SKAction.removeFromParent()]))
    }

    private func gameOver() {
        isGameOver = true
        SoundManager.shared.stopMusic()
        SoundManager.shared.play("death")
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
