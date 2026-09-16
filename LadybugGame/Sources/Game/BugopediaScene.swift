import SpriteKit

final class BugopediaScene: GameScreenScene {
    private let tracker = BugTracker.shared
    private var currentBiome: Biome = .meadowDay
    private var page = 0
    private var detail: BugTracker.BugType?

    private func bugsForBiome(_ biome: Biome) -> [BugTracker.BugType] {
        switch biome {
        case .meadowDay: return [.greenAphid, .yellowAphid, .redAphid, .brownFly, .blueFly, .purpleFly, .firefly, .heartBug, .bird, .frog, .dragonfly, .ant]
        case .meadowNight: return [.gnatSwarm, .spider, .bat, .toad]
        case .desert: return [.desertBeetle, .sandFly, .desertCricket, .scorpion, .rattlesnake, .hawk, .vulture, .desertWasp]
        case .snow: return [.snowFlea, .iceMoth, .iceSpider, .snowOwl, .frostMoth]
        case .jungle: return [.jungleBeetle, .butterfly, .poisonDartFrog, .jungleSpider, .toucan, .monkey, .cicadaBee]
        case .cave: return [.caveCricket, .glowworm, .crystalBeetle, .caveSpider, .vampireBat, .rockWorm, .caveFish]
        case .underwater: return [.clownfish, .seaSnail, .starfish, .shrimplet, .seahorse, .jellyfish, .anglerFish, .seaUrchin, .electricEel, .stingray, .pufferfish]
        case .volcano: return [.emberBeetle, .ashMoth, .magmaSnail, .fireAnt, .phoenixBird, .komodoDragon, .sloth]
        case .cloud: return [.cloudMite, .starBug, .skyButterfly, .stormHawk, .windSprite, .thunderWasp, .lightningBug]
        case .swamp: return [.mudCricket, .swampFly, .leech, .mosquitoSwarm, .alligator, .swampSnake, .bogSpider]
        case .city: return [.gardenAnt, .honeybee, .pillBug, .houseCat, .gardenSnake, .yellowJacket, .gardenSpider, .guardDog]
        case .ruins: return [.scarab, .dustMite, .templeWorm, .stoneGuardian, .tombSpider, .curseWraith, .sandViper]
        case .mushroom: return [.sporeBug, .glowShroom, .fungusGnat, .toxicSpore, .myceliumCrawler, .capBouncer]
        case .crystal: return [.gemLarva, .prismFly, .crystalMite, .shardSentinel, .crystalWyrm, .refractor, .geodeRoller]
        case .space: return [.cosmicDust, .starLarva, .nebulaJelly, .alienDrone, .voidMoth, .cosmicSerpent]
        case .mars: return [.redDustMite, .solarGrub, .martianHopper, .oxygenBug, .alienScout, .roverDrone, .craterWorm]
        }
    }


    override func rebuild() {
        removeAllChildren()
        backgroundColor = GameUITheme.ink
        let area = safeContentFrame
        if let detail { buildDetail(detail); return }
        label("Field guide", at: CGPoint(x: area.midX, y: area.maxY - 22), fontSize: 26)
        button("Back", name: "back", at: CGPoint(x: area.minX + 43, y: area.maxY - 22), width: 86)
        let all = BugTracker.BugType.allCases
        let found = all.filter { tracker.isUnlocked($0) }.count
        label("\(found) / \(all.count)", at: CGPoint(x: area.maxX - 49, y: area.maxY - 22), fontSize: 14, color: GameUITheme.gold)
        button("‹", name: "biomePrevious", at: CGPoint(x: area.midX - 151, y: area.maxY - 78), width: 52)
        label(currentBiome.name, at: CGPoint(x: area.midX, y: area.maxY - 78), fontSize: 21)
        button("›", name: "biomeNext", at: CGPoint(x: area.midX + 151, y: area.maxY - 78), width: 52)
        let bugs = bugsForBiome(currentBiome)
        let items = Array(bugs.dropFirst(page * 4).prefix(4))
        let width = min(170, (area.width - 30) / 4)
        let height = min(155, area.height - 174)
        for (index, bug) in items.enumerated() {
            let unlocked = tracker.isUnlocked(bug)
            let card = button("", name: "bug_\(bug.rawValue)",
                at: CGPoint(x: area.midX + (CGFloat(index) - CGFloat(items.count - 1) / 2) * (width + 10), y: area.midY - 18),
                width: width, height: height, color: GameUITheme.panel)
            card.accessibilityLabel = unlocked ? "\(bug.rawValue), \(bug.category.rawValue)" : "Undiscovered creature"
            let artSize = min(86, height - 47)
            let sprite = SKSpriteNode(texture: tracker.texture(for: bug, size: CGSize(width: artSize, height: artSize)))
            sprite.position.y = 18
            sprite.zPosition = 2
            if !unlocked { sprite.color = SKColor(white: 0.43, alpha: 1); sprite.colorBlendFactor = 1; sprite.alpha = 0.65 }
            card.addChild(sprite)
            label(unlocked ? bug.rawValue : "Undiscovered", at: CGPoint(x: 0, y: -height / 2 + 34),
                  fontSize: 12, width: width - 10, parent: card)
            label(unlocked ? (bug.category == .food ? "+ Snack" : "! Threat") : "Find it in the wild",
                  at: CGPoint(x: 0, y: -height / 2 + 14), fontSize: 10,
                  color: bug.category == .food ? GameUITheme.mint : GameUITheme.gold, parent: card)
        }
        let foot = area.minY + 24
        if page > 0 { button("Previous", name: "pagePrevious", at: CGPoint(x: area.midX - 142, y: foot), width: 108) }
        label("\(page + 1) / \((bugs.count + 3) / 4)", at: CGPoint(x: area.midX, y: foot), fontSize: 13)
        if (page + 1) * 4 < bugs.count { button("Next", name: "pageNext", at: CGPoint(x: area.midX + 142, y: foot), width: 108) }
    }

    private func buildDetail(_ bug: BugTracker.BugType) {
        let area = safeContentFrame
        let unlocked = tracker.isUnlocked(bug)
        let sprite = SKSpriteNode(texture: tracker.texture(for: bug, size: CGSize(width: 100, height: 92)))
        sprite.position = CGPoint(x: area.minX + area.width * 0.23, y: area.midY + 22)
        if !unlocked { sprite.color = .black; sprite.colorBlendFactor = 1 }
        addChild(sprite)
        let x = area.minX + area.width * 0.68
        label(unlocked ? bug.rawValue : "A mystery awaits", at: CGPoint(x: x, y: area.maxY - 46), fontSize: 24, width: area.width * 0.52)
        label(unlocked ? "\(bug.category.rawValue.uppercased())  ·  \(bug.points)" : currentBiome.name,
              at: CGPoint(x: x, y: area.maxY - 85), fontSize: 13, color: GameUITheme.gold)
        label(unlocked ? bug.description : "Explore this habitat to discover its creatures. Your field guide fills up as you play.",
              at: CGPoint(x: x, y: area.midY - 10), fontSize: 16, width: area.width * 0.51)
        button("Back to guide", name: "closeDetail", at: CGPoint(x: area.midX, y: area.minY + 27), width: 170)
    }

    override func activate(_ name: String) {
        switch name {
        case "back": show(MenuScene(size: size)); return
        case "closeDetail": detail = nil
        case "biomePrevious": currentBiome = Biome(rawValue: (currentBiome.rawValue + Biome.allCases.count - 1) % Biome.allCases.count) ?? .meadowDay; page = 0
        case "biomeNext": currentBiome = Biome(rawValue: (currentBiome.rawValue + 1) % Biome.allCases.count) ?? .meadowDay; page = 0
        case "pagePrevious": page = max(0, page - 1)
        case "pageNext": page = min((bugsForBiome(currentBiome).count - 1) / 4, page + 1)
        default:
            if name.hasPrefix("bug_") { detail = BugTracker.BugType(rawValue: String(name.dropFirst(4))) }
        }
        rebuild()
    }
}
