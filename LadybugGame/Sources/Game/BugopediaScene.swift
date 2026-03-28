import SpriteKit

class BugopediaScene: SKScene {

    private var currentPage: BugTracker.Category = .food
    private let tracker = BugTracker.shared

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.06, blue: 0.14, alpha: 1.0)
        showPage(.food)
    }

    private func showPage(_ page: BugTracker.Category) {
        currentPage = page
        removeAllChildren()

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Bugopedia"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height - 35)
        title.zPosition = 10
        addChild(title)

        // Back button
        let back = SKLabelNode(fontNamed: "AvenirNext-Bold")
        back.text = "< Back"
        back.fontSize = 16
        back.fontColor = SKColor(white: 0.7, alpha: 1)
        back.horizontalAlignmentMode = .left
        back.position = CGPoint(x: 20, y: size.height - 35)
        back.zPosition = 10
        back.name = "back"
        addChild(back)

        // Tabs
        let foodTab = makeTab("Snacks", name: "tabFood", active: page == .food,
                              color: SKColor(red: 0.35, green: 0.65, blue: 0.25, alpha: 1))
        foodTab.position = CGPoint(x: size.width / 2 - 60, y: size.height - 65)
        addChild(foodTab)

        let enemyTab = makeTab("Threats", name: "tabEnemy", active: page == .enemy,
                               color: SKColor(red: 0.75, green: 0.20, blue: 0.20, alpha: 1))
        enemyTab.position = CGPoint(x: size.width / 2 + 60, y: size.height - 65)
        addChild(enemyTab)

        // Bug grid
        let bugs = page == .food ? BugTracker.foodBugs : BugTracker.enemyBugs
        let cols = 5
        let cellW: CGFloat = 65
        let cellH: CGFloat = 70
        let gridW = CGFloat(min(cols, bugs.count)) * cellW
        let startX = (size.width - gridW) / 2 + cellW / 2
        let startY = size.height - 110

        for (i, bug) in bugs.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cellW
            let y = startY - CGFloat(row) * cellH

            let tex = tracker.texture(for: bug, size: CGSize(width: 36, height: 36))
            let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 36, height: 36))
            sprite.position = CGPoint(x: x, y: y)
            sprite.name = "bug_\(bug.rawValue)"
            addChild(sprite)

            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = tracker.isUnlocked(bug) ? bug.rawValue : "???"
            label.fontSize = 7
            label.fontColor = tracker.isUnlocked(bug) ? .white : SKColor(white: 0.4, alpha: 1)
            label.position = CGPoint(x: x, y: y - 24)
            label.name = "bug_\(bug.rawValue)"
            addChild(label)
        }

        // Count
        let all = BugTracker.BugType.allCases
        let found = all.filter { tracker.isUnlocked($0) }.count
        let count = SKLabelNode(fontNamed: "AvenirNext-Medium")
        count.text = "\(found)/\(all.count) discovered"
        count.fontSize = 14
        count.fontColor = SKColor(white: 0.6, alpha: 1)
        count.position = CGPoint(x: size.width / 2, y: 30)
        count.zPosition = 10
        addChild(count)
    }

    private func makeTab(_ text: String, name: String, active: Bool, color: SKColor) -> SKShapeNode {
        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 30), cornerRadius: 8)
        bg.fillColor = active ? color : SKColor(white: 0.20, alpha: 1)
        bg.strokeColor = .clear
        bg.name = name
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        bg.addChild(label)
        return bg
    }

    private func showDetail(_ bug: BugTracker.BugType) {
        childNode(withName: "detail")?.removeFromParent()

        let bg = SKShapeNode(rectOf: CGSize(width: size.width * 0.5, height: size.height * 0.55), cornerRadius: 14)
        bg.fillColor = SKColor(white: 0.05, alpha: 0.95)
        bg.strokeColor = SKColor(white: 1, alpha: 0.2)
        bg.lineWidth = 1.5
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = 50
        bg.name = "detail"
        addChild(bg)

        let tex = tracker.texture(for: bug, size: CGSize(width: 56, height: 56))
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 56, height: 56))
        sprite.position = CGPoint(x: 0, y: size.height * 0.14)
        bg.addChild(sprite)

        let isFound = tracker.isUnlocked(bug)

        let nameL = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameL.text = isFound ? bug.rawValue : "???"
        nameL.fontSize = 20
        nameL.fontColor = .white
        nameL.position = CGPoint(x: 0, y: size.height * 0.04)
        bg.addChild(nameL)

        if isFound {
            let pts = SKLabelNode(fontNamed: "AvenirNext-Bold")
            pts.text = bug.points
            pts.fontSize = 15
            pts.fontColor = SKColor(red: 1, green: 0.85, blue: 0, alpha: 1)
            pts.position = CGPoint(x: 0, y: -size.height * 0.03)
            bg.addChild(pts)

            let desc = SKLabelNode(fontNamed: "AvenirNext-Regular")
            desc.text = bug.description
            desc.fontSize = 11
            desc.fontColor = SKColor(white: 0.8, alpha: 1)
            desc.preferredMaxLayoutWidth = size.width * 0.42
            desc.numberOfLines = 3
            desc.position = CGPoint(x: 0, y: -size.height * 0.12)
            bg.addChild(desc)
        } else {
            let unk = SKLabelNode(fontNamed: "AvenirNext-Regular")
            unk.text = "Not yet discovered!"
            unk.fontSize = 13
            unk.fontColor = SKColor(white: 0.5, alpha: 1)
            unk.position = CGPoint(x: 0, y: -size.height * 0.05)
            bg.addChild(unk)
        }

        let close = SKLabelNode(fontNamed: "AvenirNext-Regular")
        close.text = "Tap to close"
        close.fontSize = 10
        close.fontColor = SKColor(white: 0.4, alpha: 1)
        close.position = CGPoint(x: 0, y: -size.height * 0.22)
        close.name = "closeDetail"
        bg.addChild(close)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let nodes = self.nodes(at: touch.location(in: self))

        // Close detail first
        if childNode(withName: "detail") != nil {
            childNode(withName: "detail")?.removeFromParent()
            return
        }

        for node in nodes {
            if node.name == "back" {
                let menu = MenuScene(size: size)
                menu.scaleMode = scaleMode
                view?.presentScene(menu, transition: .fade(withDuration: 0.3))
                return
            }
            if node.name == "tabFood" { showPage(.food); return }
            if node.name == "tabEnemy" { showPage(.enemy); return }
            if let name = node.name, name.hasPrefix("bug_") {
                let bugName = String(name.dropFirst(4))
                if let bug = BugTracker.BugType.allCases.first(where: { $0.rawValue == bugName }) {
                    showDetail(bug)
                    return
                }
            }
        }
    }
}
