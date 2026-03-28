import SpriteKit

class MenuScene: SKScene {

    private static let highScoreKey = "LadybugGameHighScore"
    static var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.35, green: 0.62, blue: 0.85, alpha: 1.0)

        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.35))
        ground.fillColor = SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1.0)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.175)
        addChild(ground)

        let ladybugTex = TextureGenerator.generateLadybugTexture(size: CGSize(width: 64, height: 64))
        let ladybug = SKSpriteNode(texture: ladybugTex)
        ladybug.position = CGPoint(x: size.width * 0.15, y: size.height * 0.35 + 32)
        ladybug.zPosition = 10
        addChild(ladybug)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Ladybug Run"
        title.fontSize = 44
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        title.zPosition = 20
        addChild(title)

        addButton("Start Game", name: "startButton",
                  color: SKColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0),
                  y: size.height * 0.52)
        addButton("Bugopedia", name: "bugTracker",
                  color: SKColor(red: 0.55, green: 0.35, blue: 0.70, alpha: 1.0),
                  y: size.height * 0.40)
        addButton("Leaderboards", name: "leaderboard",
                  color: SKColor(red: 0.25, green: 0.50, blue: 0.75, alpha: 1.0),
                  y: size.height * 0.28)

        if GameScene.hasNightCheckpoint {
            addButton("Resume Night", name: "checkpoint",
                      color: SKColor(red: 0.20, green: 0.15, blue: 0.45, alpha: 1.0),
                      y: size.height * 0.16)
        }

        let hsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        hsLabel.text = "Best: \(MenuScene.highScore)"
        hsLabel.fontSize = 16
        hsLabel.fontColor = SKColor(white: 1.0, alpha: 0.7)
        hsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        hsLabel.zPosition = 20
        addChild(hsLabel)
    }

    private func addButton(_ text: String, name: String, color: SKColor, y: CGFloat) {
        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 42), cornerRadius: 10)
        bg.fillColor = color
        bg.strokeColor = SKColor(white: 0, alpha: 0.2)
        bg.lineWidth = 1.5
        bg.position = CGPoint(x: size.width / 2, y: y)
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
            if node.name == "leaderboard" { showLeaderboard(); return }
            if node.name == "bugTracker" { showBugTracker(); return }
            if node.name == "checkpoint" {
                let game = GameScene(size: size)
                game.scaleMode = scaleMode
                game.startFromCheckpoint = true
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

    private func showLeaderboard() {
        childNode(withName: "overlay")?.removeFromParent()
        let overlay = makeOverlay()
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Leaderboards"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.22)
        overlay.addChild(title)

        let score = SKLabelNode(fontNamed: "AvenirNext-Medium")
        score.text = "High Score: \(MenuScene.highScore)"
        score.fontSize = 20
        score.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        score.position = CGPoint(x: 0, y: size.height * 0.05)
        overlay.addChild(score)

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
