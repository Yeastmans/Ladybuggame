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
        addButton("Bug Tracker", name: "bugTracker",
                  color: SKColor(red: 0.55, green: 0.35, blue: 0.70, alpha: 1.0),
                  y: size.height * 0.40)
        addButton("Leaderboards", name: "leaderboard",
                  color: SKColor(red: 0.25, green: 0.50, blue: 0.75, alpha: 1.0),
                  y: size.height * 0.28)

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

        for node in nodes {
            if node.name == "startButton" {
                let game = GameScene(size: size)
                game.scaleMode = scaleMode
                view?.presentScene(game, transition: .fade(withDuration: 0.4))
                return
            }
            if node.name == "leaderboard" { showLeaderboard(); return }
            if node.name == "bugTracker" { showBugTracker(); return }
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

    private func showBugTracker() {
        childNode(withName: "overlay")?.removeFromParent()
        let overlay = makeOverlay()

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Bug Tracker"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.28)
        overlay.addChild(title)

        let tracker = BugTracker.shared
        let bugs = BugTracker.BugType.allCases
        let cols = 4
        let cellSize: CGFloat = 50
        let startX = -CGFloat(cols - 1) * cellSize / 2
        let startY = size.height * 0.15

        for (i, bug) in bugs.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cellSize
            let y = startY - CGFloat(row) * (cellSize + 16)

            let tex = tracker.texture(for: bug, size: CGSize(width: 32, height: 32))
            let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 32, height: 32))
            sprite.position = CGPoint(x: x, y: y)
            overlay.addChild(sprite)

            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = tracker.isUnlocked(bug) ? bug.rawValue : "???"
            label.fontSize = 8
            label.fontColor = tracker.isUnlocked(bug) ? .white : SKColor(white: 0.5, alpha: 1)
            label.position = CGPoint(x: x, y: y - 22)
            overlay.addChild(label)
        }

        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        let unlocked = bugs.filter { tracker.isUnlocked($0) }.count
        countLabel.text = "\(unlocked)/\(bugs.count) discovered"
        countLabel.fontSize = 14
        countLabel.fontColor = SKColor(white: 0.8, alpha: 1)
        countLabel.position = CGPoint(x: 0, y: -size.height * 0.28)
        overlay.addChild(countLabel)

        addTapToClose(overlay)
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
