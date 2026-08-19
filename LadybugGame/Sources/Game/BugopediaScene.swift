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
        case .underwater: return [.clownfish, .seaSnail, .starfish, .shrimplet, .seahorse, .jellyfish, .anglerFish, .seaUrchin, .electricEel, .stingray, .pufferfish]
        case .volcano: return [.emberBeetle, .ashMoth, .magmaSnail, .fireAnt, .phoenixBird, .obsidianGolem, .komodoDragon, .sloth]
        case .cloud: return [.cloudMite, .starBug, .skyButterfly, .stormHawk, .windSprite, .thunderWasp, .lightningBug]
        case .swamp: return [.mudCricket, .swampFly, .leech, .mosquitoSwarm, .alligator, .swampSnake, .bogSpider]
        case .city: return [.gardenAnt, .honeybee, .pillBug, .houseCat, .gardenSnake, .yellowJacket, .gardenSpider, .guardDog]
        case .ruins: return [.scarab, .dustMite, .templeWorm, .stoneGuardian, .tombSpider, .curseWraith, .sandViper]
        case .mushroom: return [.sporeBug, .glowShroom, .fungusGnat, .toxicSpore, .shroomGolem, .myceliumCrawler, .capBouncer]
        case .crystal: return [.gemLarva, .prismFly, .crystalMite, .shardSentinel, .crystalWyrm, .refractor, .geodeRoller]
        case .space: return [.cosmicDust, .starLarva, .nebulaJelly, .alienDrone, .asteroidBeetle, .voidMoth, .cosmicSerpent]
        }
    }

    private func showBiome(_ biome: Biome) {
        currentBiome = biome
        removeAllChildren()

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Creature Collection"
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

        let totalTrack = SKSpriteNode(color: SKColor(white: 1.0, alpha: 0.13), size: CGSize(width: 96, height: 5))
        totalTrack.position = CGPoint(x: size.width - 63, y: size.height - 43)
        totalTrack.zPosition = 10
        addChild(totalTrack)
        let totalFill = SKSpriteNode(color: SKColor(red: 0.48, green: 0.90, blue: 0.48, alpha: 1), size: CGSize(width: max(1, 96 * CGFloat(found) / CGFloat(max(1, all.count))), height: 5))
        totalFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        totalFill.position = CGPoint(x: size.width - 111, y: size.height - 43)
        totalFill.zPosition = 11
        addChild(totalFill)

        // Biome tabs
        let biomes: [(Biome, String)] = [
            (.meadowDay, "Meadow"), (.meadowNight, "Night"), (.desert, "Desert"),
            (.snow, "Tundra"), (.jungle, "Jungle"), (.cave, "Cave"),
            (.underwater, "Sea"), (.volcano, "Volcano"), (.cloud, "Sky"),
            (.swamp, "Swamp"), (.city, "Garden"),
            (.ruins, "Ruins"), (.mushroom, "Shroom"), (.crystal, "Crystal"), (.space, "Space"),
        ]
        let tabW: CGFloat = 32
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

            let foundBug = tracker.isUnlocked(bug)
            let roleColor = bug.category == .food
                ? SKColor(red: 0.28, green: 0.82, blue: 0.48, alpha: 1)
                : SKColor(red: 0.96, green: 0.24, blue: 0.28, alpha: 1)
            let card = SKShapeNode(rectOf: CGSize(width: 52, height: 56), cornerRadius: 8)
            card.fillColor = foundBug ? roleColor.withAlphaComponent(0.10) : SKColor(white: 0.12, alpha: 0.82)
            card.strokeColor = foundBug ? roleColor.withAlphaComponent(0.62) : SKColor(white: 1.0, alpha: 0.10)
            card.lineWidth = 1.2
            card.position = CGPoint(x: x, y: y - 7)
            card.zPosition = 1
            card.name = "bug_\(bug.rawValue)"
            addChild(card)

            let tex = tracker.texture(for: bug, size: CGSize(width: 32, height: 32))
            let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 32, height: 32))
            sprite.position = CGPoint(x: x, y: y)
            sprite.zPosition = 2
            sprite.name = "bug_\(bug.rawValue)"
            addChild(sprite)

            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = tracker.isUnlocked(bug) ? bug.rawValue : "???"
            label.fontSize = 7
            label.fontColor = tracker.isUnlocked(bug) ? .white : SKColor(white: 0.4, alpha: 1)
            label.position = CGPoint(x: x, y: y - 22)
            label.zPosition = 3
            label.name = "bug_\(bug.rawValue)"
            addChild(label)

            let roleBadge = SKShapeNode(circleOfRadius: 6)
            roleBadge.fillColor = roleColor
            roleBadge.strokeColor = SKColor(white: 1.0, alpha: 0.55)
            roleBadge.lineWidth = 0.8
            roleBadge.position = CGPoint(x: x + 19, y: y + 18)
            roleBadge.zPosition = 4
            roleBadge.name = "bug_\(bug.rawValue)"
            addChild(roleBadge)
            let roleMark = SKLabelNode(fontNamed: "AvenirNext-Bold")
            roleMark.text = bug.category == .food ? "+" : "!"
            roleMark.fontSize = 9
            roleMark.fontColor = .white
            roleMark.verticalAlignmentMode = .center
            roleMark.name = "bug_\(bug.rawValue)"
            roleBadge.addChild(roleMark)
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
            let role = SKLabelNode(fontNamed: "AvenirNext-Bold")
            role.text = "\(bug.category.rawValue.uppercased())  •  \(bug.points)"
            role.fontSize = 14
            role.fontColor = bug.category == .food
                ? SKColor(red: 0.35, green: 0.92, blue: 0.55, alpha: 1)
                : SKColor(red: 1.0, green: 0.32, blue: 0.30, alpha: 1)
            role.position = CGPoint(x: 0, y: -size.height * 0.03)
            bg.addChild(role)

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
