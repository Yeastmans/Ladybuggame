import SpriteKit

class MenuScene: SKScene {

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

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.35, green: 0.62, blue: 0.85, alpha: 1.0)

        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.35))
        ground.fillColor = SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1.0)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.175)
        addChild(ground)

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
        ladybug.position = CGPoint(x: size.width * 0.15, y: size.height * 0.35 + 32)
        ladybug.zPosition = 10
        addChild(ladybug)

        // Show equipped hat on menu ladybug
        if let hatId = ShopScene.equippedHat {
            let hatNode = SKSpriteNode()
            hatNode.zPosition = 12
            hatNode.position = CGPoint(x: 22, y: 14) // on top of head
            switch hatId {
            case "hat_tophat":
                let t = TextureGenerator.generateTopHatTexture(size: CGSize(width: 22, height: 18))
                hatNode.texture = t; hatNode.size = t.size()
            case "hat_cap":
                let t = TextureGenerator.generateCapTexture(size: CGSize(width: 24, height: 16))
                hatNode.texture = t; hatNode.size = t.size()
            case "hat_crown":
                let t = TextureGenerator.generateCrownTexture(size: CGSize(width: 24, height: 16))
                hatNode.texture = t; hatNode.size = t.size()
            case "hat_flower":
                let t = TextureGenerator.generateFlowerHatTexture(size: CGSize(width: 18, height: 18))
                hatNode.texture = t; hatNode.size = t.size()
            default: break
            }
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

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Ladybug Run"
        title.fontSize = 44
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        title.zPosition = 20
        addChild(title)

        // High score under title
        let hsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        hsLabel.text = "Best: \(MenuScene.highScore)"
        hsLabel.fontSize = 16
        hsLabel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 0.8)
        hsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        hsLabel.zPosition = 20
        addChild(hsLabel)

        // Row 1: Start Game (wide, centered)
        addButton("Start Game", name: "startButton",
                  color: SKColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0),
                  x: size.width / 2, y: size.height * 0.56, w: 220)

        // Row 2: Checkpoints + Difficulty (side by side)
        let unlocked = GameScene.unlockedBiomes.compactMap { Biome(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue }
        if !unlocked.isEmpty {
            addButton("Checkpoints", name: "checkpointsMenu",
                      color: SKColor(red: 0.20, green: 0.15, blue: 0.45, alpha: 1.0),
                      x: size.width / 2 - 58, y: size.height * 0.44, w: 108)
        }
        addButton("Difficulty", name: "difficultyBtn",
                  color: SKColor(red: 0.45, green: 0.40, blue: 0.55, alpha: 1),
                  x: size.width / 2 + 58, y: size.height * 0.44, w: 108)

        // Row 3: Shop + Bugopedia (side by side)
        addButton("Shop", name: "shopButton",
                  color: SKColor(red: 0.82, green: 0.65, blue: 0.12, alpha: 1.0),
                  x: size.width / 2 - 58, y: size.height * 0.32, w: 108)
        addButton("Bugopedia", name: "bugTracker",
                  color: SKColor(red: 0.55, green: 0.35, blue: 0.70, alpha: 1.0),
                  x: size.width / 2 + 58, y: size.height * 0.32, w: 108)
    }

    private func addButton(_ text: String, name: String, color: SKColor, y: CGFloat) {
        addButton(text, name: name, color: color, x: size.width / 2, y: y, w: 200)
    }

    private func addButton(_ text: String, name: String, color: SKColor, x: CGFloat, y: CGFloat, w: CGFloat) {
        let bg = SKShapeNode(rectOf: CGSize(width: w, height: 38), cornerRadius: 10)
        bg.fillColor = color
        bg.strokeColor = SKColor(white: 0, alpha: 0.2)
        bg.lineWidth = 1.5
        bg.position = CGPoint(x: x, y: y)
        bg.zPosition = 20
        bg.name = name
        addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        bg.addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let nodes = self.nodes(at: touch.location(in: self))

        // Close bug detail first if open
        if childNode(withName: "bugDetail") != nil {
            childNode(withName: "bugDetail")?.removeFromParent()
            return
        }

        for node in nodes {
            if node.name == "startButton" {
                let game = GameScene(size: size)
                game.scaleMode = scaleMode
                view?.presentScene(game, transition: .fade(withDuration: 0.4))
                return
            }
            if node.name == "difficultyBtn" { showDifficultySelector(); return }
            if let name = node.name, name.hasPrefix("diff_") {
                let raw = Int(name.replacingOccurrences(of: "diff_", with: "")) ?? 1
                MenuScene.difficulty = Difficulty(rawValue: raw) ?? .normal
                // Redraw selector in place (don't close)
                showDifficultySelector()
                return
            }
            if node.name == "shopButton" {
                let shop = ShopScene(size: size)
                shop.scaleMode = scaleMode
                view?.presentScene(shop, transition: .fade(withDuration: 0.3))
                return
            }
            if node.name == "bugTracker" {
                let bugopedia = BugopediaScene(size: size)
                bugopedia.scaleMode = scaleMode
                view?.presentScene(bugopedia, transition: .fade(withDuration: 0.3))
                return
            }
            if node.name == "checkpointsMenu" { showCheckpoints(); return }
            if let name = node.name, name.hasPrefix("cp_") {
                let biomeRaw = Int(name.replacingOccurrences(of: "cp_", with: "")) ?? 0
                let game = GameScene(size: size)
                game.scaleMode = scaleMode
                game.startFromCheckpoint = true
                GameScene.checkpointScore = Biome(rawValue: biomeRaw)?.scoreThreshold ?? 0
                view?.presentScene(game, transition: .fade(withDuration: 0.4))
                return
            }

            // Click on a bug in the tracker
            if let name = node.name, name.hasPrefix("bug_") {
                let bugName = String(name.dropFirst(4))
                if let bugType = BugTracker.BugType.allCases.first(where: { $0.rawValue == bugName }) {
                    showBugDetail(bugType)
                    return
                }
            }

            if node.name == "tabFood" { showBugPage(.food); return }
            if node.name == "tabEnemy" { showBugPage(.enemy); return }
            if node.name == "overlay" || node.name == "closeOverlay" {
                childNode(withName: "overlay")?.removeFromParent()
                return
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = childNode(withName: "overlay") {
            // Overlay handled in touchesBegan
        }
    }

    private func showDifficultySelector() {
        childNode(withName: "overlay")?.removeFromParent()
        let overlay = makeOverlay()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Difficulty"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.24)
        overlay.addChild(title)

        let options: [(Difficulty, String, String, SKColor)] = [
            (.easy, "Easy", "More food, fewer enemies", SKColor(red: 0.30, green: 0.70, blue: 0.30, alpha: 1)),
            (.normal, "Normal", "Balanced challenge", SKColor(red: 0.70, green: 0.55, blue: 0.15, alpha: 1)),
            (.hard, "Hard", "Less food, more enemies", SKColor(red: 0.75, green: 0.20, blue: 0.15, alpha: 1)),
        ]

        for (i, (diff, _, _, _)) in options.enumerated() {
            let (_, name, desc, color) = options[i]
            let y = size.height * 0.12 - CGFloat(i) * 60
            let isSelected = MenuScene.difficulty == diff

            // Big touch-friendly button row
            let rowBg = SKShapeNode(rectOf: CGSize(width: size.width * 0.50, height: 46), cornerRadius: 10)
            rowBg.fillColor = isSelected ? color.withAlphaComponent(0.35) : SKColor(white: 0.15, alpha: 0.6)
            rowBg.strokeColor = isSelected ? color : SKColor(white: 0.3, alpha: 0.5)
            rowBg.lineWidth = isSelected ? 2.5 : 1
            rowBg.position = CGPoint(x: 0, y: y)
            rowBg.name = "diff_\(diff.rawValue)"
            overlay.addChild(rowBg)

            // Checkbox
            let box = SKShapeNode(rectOf: CGSize(width: 18, height: 18), cornerRadius: 4)
            box.strokeColor = .white
            box.lineWidth = 1.5
            box.fillColor = isSelected ? color : .clear
            box.position = CGPoint(x: -size.width * 0.20, y: 0)
            box.name = "diff_\(diff.rawValue)"
            rowBg.addChild(box)
            if isSelected {
                let tick = SKLabelNode(text: "✓")
                tick.fontSize = 14
                tick.fontColor = .white
                tick.verticalAlignmentMode = .center
                tick.horizontalAlignmentMode = .center
                tick.name = "diff_\(diff.rawValue)"
                box.addChild(tick)
            }

            // Name
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = name
            label.fontSize = 17
            label.fontColor = isSelected ? color : .white
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: -size.width * 0.13, y: 5)
            label.name = "diff_\(diff.rawValue)"
            rowBg.addChild(label)

            // Description
            let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            descLabel.text = desc
            descLabel.fontSize = 9
            descLabel.fontColor = SKColor(white: 0.65, alpha: 1)
            descLabel.horizontalAlignmentMode = .left
            descLabel.verticalAlignmentMode = .center
            descLabel.position = CGPoint(x: -size.width * 0.13, y: -8)
            descLabel.name = "diff_\(diff.rawValue)"
            rowBg.addChild(descLabel)
        }

        addTapToClose(overlay)
    }

    private func showCheckpoints() {
        childNode(withName: "overlay")?.removeFromParent()
        let overlay = makeOverlay()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Checkpoints"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.22)
        overlay.addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "Resume from a biome you've reached"
        subtitle.fontSize = 11
        subtitle.fontColor = SKColor(white: 0.7, alpha: 1)
        subtitle.position = CGPoint(x: 0, y: size.height * 0.15)
        overlay.addChild(subtitle)

        let biomes = GameScene.unlockedBiomes.compactMap { Biome(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue }
        let cols = 3
        let btnW: CGFloat = 110
        let btnH: CGFloat = 34
        let spacingX: CGFloat = 120
        let spacingY: CGFloat = 44
        let gridW = CGFloat(min(cols, biomes.count)) * spacingX
        let startX = -gridW / 2 + spacingX / 2
        let startY = size.height * 0.08

        for (i, biome) in biomes.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * spacingX
            let y = startY - CGFloat(row) * spacingY

            let btn = SKShapeNode(rectOf: CGSize(width: btnW, height: btnH), cornerRadius: 8)
            btn.fillColor = biome.skyColor.withAlphaComponent(0.8)
            btn.strokeColor = SKColor(white: 1.0, alpha: 0.3)
            btn.lineWidth = 1
            btn.position = CGPoint(x: x, y: y)
            btn.name = "cp_\(biome.rawValue)"
            overlay.addChild(btn)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = biome.name
            label.fontSize = 13
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: 2)
            label.name = "cp_\(biome.rawValue)"
            btn.addChild(label)

            let scoreHint = SKLabelNode(fontNamed: "AvenirNext-Regular")
            scoreHint.text = "\(biome.scoreThreshold)"
            scoreHint.fontSize = 9
            scoreHint.fontColor = SKColor(white: 1.0, alpha: 0.5)
            scoreHint.verticalAlignmentMode = .center
            scoreHint.position = CGPoint(x: 0, y: -10)
            scoreHint.name = "cp_\(biome.rawValue)"
            btn.addChild(scoreHint)
        }

        addTapToClose(overlay)
    }

    private var currentBugPage: BugTracker.Category = .food

    private func showBugTracker() {
        showBugPage(.food)
    }

    private func showBugPage(_ page: BugTracker.Category) {
        currentBugPage = page
        childNode(withName: "overlay")?.removeFromParent()
        let overlay = makeOverlay()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Bugopedia"
        title.fontSize = 22
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.30)
        overlay.addChild(title)

        // Tab buttons
        let foodTab = SKShapeNode(rectOf: CGSize(width: 90, height: 28), cornerRadius: 6)
        foodTab.fillColor = page == .food ? SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1) : SKColor(white: 0.25, alpha: 1)
        foodTab.strokeColor = .clear
        foodTab.position = CGPoint(x: -55, y: size.height * 0.22)
        foodTab.name = "tabFood"
        overlay.addChild(foodTab)
        let foodLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        foodLabel.text = "Snacks"
        foodLabel.fontSize = 13
        foodLabel.fontColor = .white
        foodLabel.verticalAlignmentMode = .center
        foodLabel.name = "tabFood"
        foodTab.addChild(foodLabel)

        let enemyTab = SKShapeNode(rectOf: CGSize(width: 90, height: 28), cornerRadius: 6)
        enemyTab.fillColor = page == .enemy ? SKColor(red: 0.80, green: 0.20, blue: 0.20, alpha: 1) : SKColor(white: 0.25, alpha: 1)
        enemyTab.strokeColor = .clear
        enemyTab.position = CGPoint(x: 55, y: size.height * 0.22)
        enemyTab.name = "tabEnemy"
        overlay.addChild(enemyTab)
        let enemyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        enemyLabel.text = "Threats"
        enemyLabel.fontSize = 13
        enemyLabel.fontColor = .white
        enemyLabel.verticalAlignmentMode = .center
        enemyLabel.name = "tabEnemy"
        enemyTab.addChild(enemyLabel)

        // Bug grid
        let bugs = page == .food ? BugTracker.foodBugs : BugTracker.enemyBugs
        let tracker = BugTracker.shared
        let cols = 4
        let cellSize: CGFloat = 50
        let startX = -CGFloat(min(cols, bugs.count) - 1) * cellSize / 2
        let startY = size.height * 0.10

        for (i, bug) in bugs.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cellSize
            let y = startY - CGFloat(row) * (cellSize + 14)

            let tex = tracker.texture(for: bug, size: CGSize(width: 32, height: 32))
            let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 32, height: 32))
            sprite.position = CGPoint(x: x, y: y)
            sprite.name = "bug_\(bug.rawValue)"
            overlay.addChild(sprite)

            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = tracker.isUnlocked(bug) ? bug.rawValue : "???"
            label.fontSize = 7
            label.fontColor = tracker.isUnlocked(bug) ? .white : SKColor(white: 0.5, alpha: 1)
            label.position = CGPoint(x: x, y: y - 22)
            label.name = "bug_\(bug.rawValue)"
            overlay.addChild(label)
        }

        let allBugs = BugTracker.BugType.allCases
        let unlocked = allBugs.filter { tracker.isUnlocked($0) }.count
        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        countLabel.text = "\(unlocked)/\(allBugs.count) discovered"
        countLabel.fontSize = 12
        countLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        countLabel.position = CGPoint(x: 0, y: -size.height * 0.28)
        overlay.addChild(countLabel)

        let hint = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hint.text = "Tap bug for details  |  Tap outside to close"
        hint.fontSize = 9
        hint.fontColor = SKColor(white: 1.0, alpha: 0.35)
        hint.position = CGPoint(x: 0, y: -size.height * 0.33)
        overlay.addChild(hint)
    }

    private func showBugDetail(_ bugType: BugTracker.BugType) {
        childNode(withName: "bugDetail")?.removeFromParent()

        let detail = SKShapeNode(rectOf: CGSize(width: size.width * 0.45, height: size.height * 0.50), cornerRadius: 12)
        detail.fillColor = SKColor(white: 0.05, alpha: 0.95)
        detail.strokeColor = SKColor(white: 1.0, alpha: 0.3)
        detail.lineWidth = 1.5
        detail.position = CGPoint(x: size.width / 2, y: size.height / 2)
        detail.zPosition = 200
        detail.name = "bugDetail"
        addChild(detail)

        let tracker = BugTracker.shared
        let isFound = tracker.isUnlocked(bugType)

        let tex = tracker.texture(for: bugType, size: CGSize(width: 48, height: 48))
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 48, height: 48))
        sprite.position = CGPoint(x: 0, y: size.height * 0.12)
        detail.addChild(sprite)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = isFound ? bugType.rawValue : "???"
        nameLabel.fontSize = 18
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: size.height * 0.04)
        detail.addChild(nameLabel)

        if isFound {
            let ptsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            ptsLabel.text = bugType.points
            ptsLabel.fontSize = 14
            ptsLabel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            ptsLabel.position = CGPoint(x: 0, y: -size.height * 0.02)
            detail.addChild(ptsLabel)

            let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            descLabel.text = bugType.description
            descLabel.fontSize = 10
            descLabel.fontColor = SKColor(white: 0.8, alpha: 1)
            descLabel.preferredMaxLayoutWidth = size.width * 0.38
            descLabel.numberOfLines = 3
            descLabel.position = CGPoint(x: 0, y: -size.height * 0.10)
            detail.addChild(descLabel)
        } else {
            let unkLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            unkLabel.text = "Not yet discovered!"
            unkLabel.fontSize = 12
            unkLabel.fontColor = SKColor(white: 0.5, alpha: 1)
            unkLabel.position = CGPoint(x: 0, y: -size.height * 0.04)
            detail.addChild(unkLabel)
        }

        let close = SKLabelNode(fontNamed: "AvenirNext-Regular")
        close.text = "Tap to close"
        close.fontSize = 10
        close.fontColor = SKColor(white: 1.0, alpha: 0.4)
        close.position = CGPoint(x: 0, y: -size.height * 0.18)
        close.name = "closeBugDetail"
        detail.addChild(close)
    }

    private func makeOverlay() -> SKShapeNode {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.65, height: size.height * 0.75), cornerRadius: 16)
        overlay.fillColor = SKColor(white: 0.0, alpha: 0.88)
        overlay.strokeColor = SKColor(white: 1.0, alpha: 0.25)
        overlay.lineWidth = 2
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        overlay.name = "overlay"
        addChild(overlay)
        return overlay
    }

    private func addTapToClose(_ overlay: SKShapeNode) {
        let hint = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hint.text = "Tap to close"
        hint.fontSize = 12
        hint.fontColor = SKColor(white: 1.0, alpha: 0.4)
        hint.position = CGPoint(x: 0, y: -size.height * 0.33)
        hint.name = "closeOverlay"
        overlay.addChild(hint)
    }
}
