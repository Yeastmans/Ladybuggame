import SpriteKit

final class MenuScene: GameScreenScene {
    private static let highScoreKey = "LadybugGameHighScore"
    static var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    enum Difficulty: Int { case easy = 0, normal = 1, hard = 2
        var name: String { switch self { case .easy: return "Easy"; case .normal: return "Normal"; case .hard: return "Hard" } }
        var enemyMul: Double { switch self { case .easy: return 1.5; case .normal: return 1.0; case .hard: return 0.5 } }
        var foodMul: Double { switch self { case .easy: return 0.65; case .normal: return 1.0; case .hard: return 1.8 } }
    }
    private static let diffKey = "GameDifficulty"
    static var difficulty: Difficulty {
        get { Difficulty(rawValue: UserDefaults.standard.integer(forKey: diffKey)) ?? .normal }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: diffKey) }
    }


    private var mapPage: Int?

    override func rebuild() {
        removeAllChildren()
        let progress = CampaignProgressStore.shared
        progress.migrateLegacyProgress(unlockedBiomeIDs: GameScene.unlockedBiomes,
            checkpointScore: GameScene.checkpointScore, highScore: Self.highScore)
        if let page = mapPage { buildMap(page: page); return }
        let area = safeContentFrame
        backgroundColor = SKColor(red: 0.35, green: 0.62, blue: 0.85, alpha: 1.0)
        addMenuBackdrop()

        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.35))
        ground.fillColor = SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1.0)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.175)
        ground.zPosition = 0
        addChild(ground)

        let grassGlow = SKShapeNode(rectOf: CGSize(width: size.width, height: 8), cornerRadius: 3)
        grassGlow.fillColor = SKColor(red: 0.68, green: 0.88, blue: 0.34, alpha: 0.72)
        grassGlow.strokeColor = .clear
        grassGlow.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        grassGlow.zPosition = 1
        addChild(grassGlow)

        // Resolve equipped body color
        var menuBodyColor: UIColor? = nil
        if let colorId = ShopScene.equippedColor,
           let item = ShopScene.allItems.first(where: { $0.id == colorId }),
           let c = item.color {
            menuBodyColor = UIColor(cgColor: c.cgColor)
        }
        let menuHasHat = ShopScene.equippedHat != nil
        var menuSpotColor: UIColor? = nil
        if let spotId = ShopScene.equippedSpots, spotId != "spot_default",
           let item = ShopScene.allItems.first(where: { $0.id == spotId }),
           let c = item.color { menuSpotColor = UIColor(cgColor: c.cgColor) }
        let ladybugTex = TextureGenerator.generateLadybugTexture(size: CGSize(width: 64, height: 64), bodyColor: menuBodyColor, hideAntennae: menuHasHat, spotColor: menuSpotColor)
        let ladybug = SKSpriteNode(texture: ladybugTex)
        ladybug.position = CGPoint(x: area.minX + area.width * 0.23, y: area.midY - 6)
        ladybug.setScale(min(2.3, area.height / 135))
        ladybug.zPosition = 10
        addChild(ladybug)
        if !GameSettings.reducedEffects { ladybug.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 5, duration: 0.75),
                SKAction.rotate(toAngle: 0.05, duration: 0.75),
            ]),
            SKAction.group([
                SKAction.moveBy(x: 0, y: -5, duration: 0.75),
                SKAction.rotate(toAngle: -0.04, duration: 0.75),
            ]),
        ])), withKey: "menuIdle") }

        // Show equipped hat on menu ladybug
        if let hatId = ShopScene.equippedHat {
            let hatNode = SKSpriteNode()
            hatNode.zPosition = 12
            hatNode.position = CGPoint(x: 22, y: 14) // on top of head
            let texture = CosmeticArt.hatTexture(id: hatId, size: CGSize(width: 27, height: 23))
            hatNode.texture = texture
            hatNode.size = texture.size()
            ladybug.addChild(hatNode)
        }

        // Show equipped shoes on menu ladybug
        if let shoeId = ShopScene.equippedShoes,
           let item = ShopScene.allItems.first(where: { $0.id == shoeId }),
           let shoeColor = item.color {
            for dx in [CGFloat(-14), -4, 7] {
                let shoe = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
                shoe.fillColor = SKColor(cgColor: shoeColor.cgColor)
                shoe.strokeColor = SKColor(white: 0, alpha: 0.3)
                shoe.lineWidth = 0.5
                shoe.position = CGPoint(x: dx, y: -28)
                shoe.zPosition = -1
                ladybug.addChild(shoe)
            }
        }


        let title = label("Ladybug Run", at: CGPoint(x: area.minX + area.width * 0.24, y: area.maxY - 37),
                          fontSize: min(42, area.width * 0.065))
        title.zPosition = 20
        label("LITTLE WINGS. BIG ADVENTURE.",
              at: CGPoint(x: area.minX + area.width * 0.24, y: area.maxY - 73),
              fontSize: 11, color: SKColor(red: 0.12, green: 0.25, blue: 0.22, alpha: 1)).zPosition = 20

        let cardWidth = min(330, area.width * 0.46)
        let center = CGPoint(x: area.maxX - cardWidth / 2, y: area.midY + 8)
        let card = GameUITheme.makePanel(size: CGSize(width: cardWidth, height: min(280, area.height - 14)),
            cornerRadius: 24, fillColor: GameUITheme.ink.withAlphaComponent(0.96))
        card.position = center
        card.zPosition = 20
        addChild(card)
        let stage = CampaignStage.stage(id: progress.continueStageID) ?? CampaignStage.all[0]
        let top = min(280, area.height - 14) / 2
        label(progress.completedCount == 0 ? "YOUR ADVENTURE STARTS HERE" : "WELCOME BACK, LITTLE EXPLORER",
              at: CGPoint(x: 0, y: top - 24), fontSize: 10, color: GameUITheme.gold, parent: card)
        label(stage.biome.name, at: CGPoint(x: 0, y: top - 54), fontSize: 27, parent: card)
        label("Stage \(stage.number) of \(CampaignStage.all.count)  ·  \(progress.totalStars) stars",
              at: CGPoint(x: 0, y: top - 82), fontSize: 12, color: SKColor(white: 0.78, alpha: 1), parent: card)
        button(progress.completedCount == 0 ? "Let's play" : "Continue adventure", name: "play",
               at: CGPoint(x: 0, y: top - 123), width: cardWidth - 36, height: 50,
               color: GameUITheme.coral, parent: card)
        let smallWidth = (cardWidth - 48) / 2
        button("World map", name: "map", at: CGPoint(x: -smallWidth / 2 - 6, y: top - 181),
               width: smallWidth, parent: card)
        button("Endless", name: "endless", at: CGPoint(x: smallWidth / 2 + 6, y: top - 181),
               width: smallWidth, parent: card)
        label("Fly, find snacks, and hide from hungry birds.", at: CGPoint(x: 0, y: top - 227),
              fontSize: 11, color: SKColor(white: 0.73, alpha: 1), width: cardWidth - 30, parent: card)

        let navWidth = min(112, (area.width * 0.49 - 16) / 3)
        for (index, item) in [("Collection", "collection"), ("Dress up", "shop"), ("Settings", "settings")].enumerated() {
            let x = area.minX + navWidth / 2 + CGFloat(index) * (navWidth + 6)
            button(item.0, name: item.1, at: CGPoint(x: x, y: area.minY + 30), width: navWidth,
                   color: SKColor(red: 0.13, green: 0.34, blue: 0.24, alpha: 1)).zPosition = 25
        }
    }

    private func startAdventure(_ id: Int) {
        guard CampaignProgressStore.shared.isUnlocked(id) else { return }
        if id == 0, !GameSettings.completedFlightSchool {
            let lesson = FlightSchoolScene(size: size)
            lesson.startAdventureWhenFinished = true
            show(lesson)
        } else {
            let game = GameScene(size: size)
            game.campaignStageID = id
            show(game)
        }
    }

    override func activate(_ name: String) {
        switch name {
        case "play": startAdventure(CampaignProgressStore.shared.continueStageID)
        case "map": mapPage = CampaignProgressStore.shared.continueStageID / 6; rebuild()
        case "back": mapPage = nil; rebuild()
        case "previous": mapPage = max(0, (mapPage ?? 0) - 1); rebuild()
        case "next": mapPage = min((CampaignStage.all.count - 1) / 6, (mapPage ?? 0) + 1); rebuild()
        case "endless": show(GameScene(size: size))
        case "collection": show(BugopediaScene(size: size))
        case "shop": show(ShopScene(size: size))
        case "settings": show(SettingsScene(size: size))
        default:
            if name.hasPrefix("stage_"), let id = Int(name.dropFirst(6)) { startAdventure(id) }
        }
    }

    private func buildMap(page: Int) {
        backgroundColor = GameUITheme.ink
        let area = safeContentFrame
        let progress = CampaignProgressStore.shared
        let titles = ["The wild garden", "Beyond the pond", "Strange new worlds"]
        label(titles[min(page, titles.count - 1)], at: CGPoint(x: area.midX, y: area.maxY - 22), fontSize: 25)
        button("Back", name: "back", at: CGPoint(x: area.minX + 43, y: area.maxY - 22), width: 86)
        label("\(progress.completedCount)/\(CampaignStage.all.count) explored  ·  \(progress.totalStars) stars",
              at: CGPoint(x: area.midX, y: area.maxY - 53), fontSize: 12, color: GameUITheme.gold)
        let cardWidth = min(220, (area.width - 28) / 3)
        let cardHeight = min(100, (area.height - 146) / 2)
        let stepX = cardWidth + 12
        let topY = area.maxY - 78 - cardHeight / 2
        let stages = Array(CampaignStage.all.dropFirst(page * 6).prefix(6))
        for (index, stage) in stages.enumerated() {
            let record = progress.record(for: stage.id)
            let unlocked = progress.isUnlocked(stage.id)
            let col = index < 3 ? index : 5 - index
            let position = CGPoint(x: area.midX + CGFloat(col - 1) * stepX,
                                   y: topY - CGFloat(index / 3) * (cardHeight + 12))
            let card = button("", name: unlocked ? "stage_\(stage.id)" : "locked",
                              at: position, width: cardWidth, height: cardHeight,
                              color: unlocked ? stage.biome.skyColor.withAlphaComponent(0.50) : SKColor(white: 0.12, alpha: 1))
            card.accessibilityLabel = "Stage \(stage.number), \(stage.biome.name), \(unlocked ? "available" : "locked")"
            if stage.id == progress.continueStageID {
                card.strokeColor = GameUITheme.gold
                card.lineWidth = 2.5
            }
            label("\(stage.number)  \(stage.biome.name)", at: CGPoint(x: 0, y: cardHeight * 0.20),
                  fontSize: 15, width: cardWidth - 18, parent: card)
            let detail = !unlocked ? "Finish stage \(stage.number - 1)" : record.completed
                ? String(repeating: "★", count: record.bestStars) + String(repeating: "☆", count: 3 - record.bestStars)
                : stage.isBossStage ? "BOSS ENCOUNTER" : "READY TO EXPLORE"
            label(detail, at: CGPoint(x: 0, y: -cardHeight * 0.25), fontSize: 11,
                  color: unlocked ? GameUITheme.gold : SKColor(white: 0.65, alpha: 1), parent: card)
        }
        let footerY = area.minY + 24
        if page > 0 { button("Previous", name: "previous", at: CGPoint(x: area.midX - 137, y: footerY), width: 110) }
        label("\(page + 1) / \((CampaignStage.all.count + 5) / 6)", at: CGPoint(x: area.midX, y: footerY), fontSize: 13)
        if (page + 1) * 6 < CampaignStage.all.count {
            button("Next", name: "next", at: CGPoint(x: area.midX + 137, y: footerY), width: 110)
        }
    }

    private func addMenuBackdrop() {
        let skyColors: [SKColor] = [
            SKColor(red: 0.22, green: 0.46, blue: 0.78, alpha: 1),
            SKColor(red: 0.31, green: 0.58, blue: 0.86, alpha: 1),
            SKColor(red: 0.43, green: 0.69, blue: 0.91, alpha: 1),
            SKColor(red: 0.56, green: 0.78, blue: 0.94, alpha: 1),
        ]
        let bandHeight = size.height / CGFloat(skyColors.count)
        for (index, color) in skyColors.enumerated() {
            let band = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: bandHeight + 2))
            band.fillColor = color
            band.strokeColor = .clear
            band.position = CGPoint(x: size.width / 2, y: bandHeight * (CGFloat(index) + 0.5))
            band.zPosition = -20
            addChild(band)
        }

        let sunGlow = SKShapeNode(circleOfRadius: 52)
        sunGlow.fillColor = SKColor(red: 1.0, green: 0.89, blue: 0.36, alpha: 0.15)
        sunGlow.strokeColor = .clear
        sunGlow.position = CGPoint(x: size.width * 0.84, y: size.height * 0.82)
        sunGlow.zPosition = -12
        addChild(sunGlow)
        let sun = SKShapeNode(circleOfRadius: 30)
        sun.fillColor = SKColor(red: 1.0, green: 0.87, blue: 0.32, alpha: 0.92)
        sun.strokeColor = SKColor(white: 1, alpha: 0.42)
        sun.lineWidth = 2
        sun.position = sunGlow.position
        sun.zPosition = -11
        addChild(sun)

        for index in 0..<3 {
            let cloud = SKNode()
            cloud.position = CGPoint(
                x: size.width * (0.24 + CGFloat(index) * 0.26),
                y: size.height * (0.78 - CGFloat(index % 2) * 0.12)
            )
            cloud.zPosition = -10
            addChild(cloud)
            for puff in 0..<4 {
                let shape = SKShapeNode(ellipseOf: CGSize(width: 34 + CGFloat(puff % 2) * 10, height: 18 + CGFloat(puff % 2) * 5))
                shape.fillColor = SKColor(white: 1, alpha: 0.28)
                shape.strokeColor = .clear
                shape.position = CGPoint(x: CGFloat(puff) * 21 - 30, y: CGFloat(puff % 2) * 5)
                cloud.addChild(shape)
            }
            if !GameSettings.reducedEffects { cloud.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 8, y: 0, duration: 2.4 + Double(index) * 0.3),
                SKAction.moveBy(x: -8, y: 0, duration: 2.4 + Double(index) * 0.3),
            ]))) }
        }

        for index in 0..<4 {
            let hill = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.42, height: size.height * 0.22))
            hill.fillColor = index.isMultiple(of: 2)
                ? SKColor(red: 0.29, green: 0.60, blue: 0.32, alpha: 0.72)
                : SKColor(red: 0.23, green: 0.52, blue: 0.30, alpha: 0.62)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: CGFloat(index) * size.width * 0.29, y: size.height * 0.35)
            hill.zPosition = -2
            addChild(hill)
        }
        GameUITheme.addAmbientSparkles(to: self, size: size, count: 10, zPosition: -8)
    }
}
