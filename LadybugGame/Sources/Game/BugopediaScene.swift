import SpriteKit

class BugopediaScene: SKScene {

    private let tracker = BugTracker.shared
    private var currentBiome: Biome = .meadowDay

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.06, blue: 0.14, alpha: 1.0)
        showBiome(.meadowDay)
    }

    private func bugsForBiome(_ biome: Biome) -> [BugTracker.BugType] {
        switch biome {
        case .meadowDay: return [.greenAphid, .yellowAphid, .redAphid, .brownFly, .blueFly, .purpleFly, .firefly, .heartBug, .bird, .frog, .dragonfly, .ant]
        case .meadowNight: return [.gnatSwarm, .spider, .bat, .toad]
        case .desert: return [.desertBeetle, .sandFly, .desertCricket, .scorpion, .rattlesnake, .hawk, .vulture, .desertWasp]
        case .snow: return [.snowFlea, .iceMoth, .iceSpider, .snowOwl, .frostMoth]
        case .jungle: return [.jungleBeetle, .butterfly, .poisonDartFrog, .jungleSpider, .toucan, .monkey, .cicadaBee]
        case .cave: return [.caveCricket, .glowworm, .crystalBeetle, .caveSpider, .vampireBat, .rockWorm, .caveFish]
        case .underwater: return [.seaSnail, .plankton, .shrimplet, .jellyfish, .anglerFish, .seaUrchin, .electricEel]
        case .volcano: return [.emberBeetle, .ashMoth, .magmaSnail, .lavaSlime, .fireAnt, .phoenixBird, .obsidianGolem]
        case .cloud: return [.cloudMite, .starBug, .skyJelly, .stormHawk, .windSprite, .thunderWasp, .lightningBug]
        case .swamp: return [.mudCricket, .swampFly, .leech, .mosquitoSwarm, .alligator, .swampSnake, .bogSpider]
        case .city: return [.gardenAnt, .honeybee, .pillBug, .houseCat, .gardenSnake, .yellowJacket, .gardenSpider]
        }
    }

    private func showBiome(_ biome: Biome) {
        currentBiome = biome
        removeAllChildren()

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Bugopedia"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height - 28)
        title.zPosition = 10
        addChild(title)

        // Back
        let back = SKLabelNode(fontNamed: "AvenirNext-Bold")
        back.text = "< Back"
        back.fontSize = 14
        back.fontColor = SKColor(white: 0.7, alpha: 1)
        back.horizontalAlignmentMode = .left
        back.position = CGPoint(x: 15, y: size.height - 28)
        back.zPosition = 10
        back.name = "back"
        addChild(back)

        // Count
        let all = BugTracker.BugType.allCases
        let found = all.filter { tracker.isUnlocked($0) }.count
        let countL = SKLabelNode(fontNamed: "AvenirNext-Medium")
        countL.text = "\(found)/\(all.count)"
        countL.fontSize = 12
        countL.fontColor = SKColor(white: 0.5, alpha: 1)
        countL.horizontalAlignmentMode = .right
        countL.position = CGPoint(x: size.width - 15, y: size.height - 28)
        countL.zPosition = 10
        addChild(countL)

        // Biome tabs (scrollable row)
        let biomes: [(Biome, String)] = [
            (.meadowDay, "Meadow"), (.meadowNight, "Night"), (.desert, "Desert"),
            (.snow, "Tundra"), (.jungle, "Jungle"), (.cave, "Cave"),
            (.underwater, "Sea"), (.volcano, "Volcano"), (.cloud, "Sky"),
            (.swamp, "Swamp"), (.city, "Garden"),
        ]
        let tabW: CGFloat = 38
        let tabStartX = (size.width - CGFloat(biomes.count) * tabW) / 2 + tabW / 2
        for (i, (b, name)) in biomes.enumerated() {
            let active = b == biome
            let tab = SKShapeNode(rectOf: CGSize(width: tabW - 3, height: 20), cornerRadius: 5)
            tab.fillColor = active ? b.skyColor.withAlphaComponent(0.8) : SKColor(white: 0.18, alpha: 1)
            tab.strokeColor = active ? .white : .clear
            tab.lineWidth = active ? 1.5 : 0
            tab.position = CGPoint(x: tabStartX + CGFloat(i) * tabW, y: size.height - 55)
            tab.zPosition = 10
            tab.name = "biome_\(b.rawValue)"
            addChild(tab)

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = name
            label.fontSize = 7
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.name = "biome_\(b.rawValue)"
            tab.addChild(label)
        }

        // Bug grid for this biome
        let bugs = bugsForBiome(biome)
        let cols = 6
        let cellW: CGFloat = 58
        let cellH: CGFloat = 62
        let gridW = CGFloat(min(cols, bugs.count)) * cellW
        let startX = (size.width - gridW) / 2 + cellW / 2
        let startY = size.height - 90

        for (i, bug) in bugs.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cellW
            let y = startY - CGFloat(row) * cellH

            let tex = tracker.texture(for: bug, size: CGSize(width: 32, height: 32))
            let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 32, height: 32))
            sprite.position = CGPoint(x: x, y: y)
            sprite.name = "bug_\(bug.rawValue)"
            addChild(sprite)

            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = tracker.isUnlocked(bug) ? bug.rawValue : "???"
            label.fontSize = 7
            label.fontColor = tracker.isUnlocked(bug) ? .white : SKColor(white: 0.4, alpha: 1)
            label.position = CGPoint(x: x, y: y - 22)
            label.name = "bug_\(bug.rawValue)"
            addChild(label)

            // Food/enemy indicator
            let dot = SKShapeNode(circleOfRadius: 2.5)
            dot.fillColor = bug.category == .food ? SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 0.7) : SKColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.7)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: x + 14, y: y + 14)
            addChild(dot)
        }

        // Biome count
        let biomeFound = bugs.filter { tracker.isUnlocked($0) }.count
        let biomeCt = SKLabelNode(fontNamed: "AvenirNext-Medium")
        biomeCt.text = "\(biomeFound)/\(bugs.count) in \(biome.name)"
        biomeCt.fontSize = 11
        biomeCt.fontColor = SKColor(white: 0.5, alpha: 1)
        biomeCt.position = CGPoint(x: size.width / 2, y: 22)
        biomeCt.zPosition = 10
        addChild(biomeCt)
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
            if let name = node.name, name.hasPrefix("biome_") {
                let raw = Int(name.replacingOccurrences(of: "biome_", with: "")) ?? 0
                if let b = Biome(rawValue: raw) { showBiome(b) }
                return
            }
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
