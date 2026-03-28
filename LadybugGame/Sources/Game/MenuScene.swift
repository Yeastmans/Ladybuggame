import SpriteKit

class MenuScene: SKScene {

    private static let highScoreKey = "LadybugGameHighScore"
    static var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.35, green: 0.62, blue: 0.85, alpha: 1.0)

        // Ground strip
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.35))
        ground.fillColor = SKColor(red: 0.45, green: 0.72, blue: 0.30, alpha: 1.0)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.175)
        addChild(ground)

        // Ground line
        let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
        line.fillColor = SKColor(red: 0.35, green: 0.58, blue: 0.22, alpha: 1.0)
        line.strokeColor = .clear
        line.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        addChild(line)

        // Ladybug on the ground
        let ladybugTex = TextureGenerator.generateLadybugTexture(size: CGSize(width: 64, height: 64))
        let ladybug = SKSpriteNode(texture: ladybugTex)
        ladybug.position = CGPoint(x: size.width * 0.15, y: size.height * 0.35 + 32)
        ladybug.zPosition = 10
        addChild(ladybug)

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Ladybug Run"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        title.zPosition = 20
        addChild(title)

        // Start button
        let startBg = SKShapeNode(rectOf: CGSize(width: 220, height: 50), cornerRadius: 12)
        startBg.fillColor = SKColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1.0)
        startBg.strokeColor = SKColor(red: 0.65, green: 0.08, blue: 0.06, alpha: 1.0)
        startBg.lineWidth = 2
        startBg.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        startBg.zPosition = 20
        startBg.name = "startButton"
        addChild(startBg)

        let startLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        startLabel.text = "Start Game"
        startLabel.fontSize = 22
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startLabel.name = "startButton"
        startBg.addChild(startLabel)

        // Leaderboard button
        let lbBg = SKShapeNode(rectOf: CGSize(width: 220, height: 50), cornerRadius: 12)
        lbBg.fillColor = SKColor(red: 0.25, green: 0.50, blue: 0.75, alpha: 1.0)
        lbBg.strokeColor = SKColor(red: 0.18, green: 0.38, blue: 0.58, alpha: 1.0)
        lbBg.lineWidth = 2
        lbBg.position = CGPoint(x: size.width / 2, y: size.height * 0.34)
        lbBg.zPosition = 20
        lbBg.name = "leaderboard"
        addChild(lbBg)

        let lbLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbLabel.text = "Leaderboards"
        lbLabel.fontSize = 22
        lbLabel.fontColor = .white
        lbLabel.verticalAlignmentMode = .center
        lbLabel.name = "leaderboard"
        lbBg.addChild(lbLabel)

        // High score
        let hsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        hsLabel.text = "Best: \(MenuScene.highScore)"
        hsLabel.fontSize = 18
        hsLabel.fontColor = SKColor(white: 1.0, alpha: 0.7)
        hsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        hsLabel.zPosition = 20
        addChild(hsLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            if node.name == "startButton" {
                let game = GameScene(size: size)
                game.scaleMode = scaleMode
                view?.presentScene(game, transition: .fade(withDuration: 0.4))
                return
            }
            if node.name == "leaderboard" {
                showLeaderboard()
                return
            }
        }
    }

    private func showLeaderboard() {
        // Remove existing leaderboard overlay if any
        childNode(withName: "lbOverlay")?.removeFromParent()

        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.6, height: size.height * 0.7), cornerRadius: 16)
        overlay.fillColor = SKColor(white: 0.0, alpha: 0.85)
        overlay.strokeColor = SKColor(white: 1.0, alpha: 0.3)
        overlay.lineWidth = 2
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        overlay.name = "lbOverlay"
        addChild(overlay)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Leaderboards"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.25)
        overlay.addChild(title)

        let score = SKLabelNode(fontNamed: "AvenirNext-Medium")
        score.text = "High Score: \(MenuScene.highScore)"
        score.fontSize = 22
        score.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        score.position = CGPoint(x: 0, y: size.height * 0.08)
        overlay.addChild(score)

        let hint = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hint.text = "Tap to close"
        hint.fontSize = 16
        hint.fontColor = SKColor(white: 1.0, alpha: 0.5)
        hint.position = CGPoint(x: 0, y: -size.height * 0.25)
        overlay.addChild(hint)

        // Tap overlay to dismiss
        overlay.isUserInteractionEnabled = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let overlay = childNode(withName: "lbOverlay") {
            overlay.removeFromParent()
        }
    }
}
