import SpriteKit
import UIKit

final class BugTracker: @unchecked Sendable {
    static let shared = BugTracker()

    enum Category: String { case food = "Snacks", enemy = "Threats" }

    enum BugType: String, CaseIterable {
        // Meadow food
        case greenAphid = "Green Aphid"
        case yellowAphid = "Yellow Aphid"
        case redAphid = "Red Aphid"
        case brownFly = "Fruit Fly"
        case blueFly = "Blue Fly"
        case purpleFly = "Purple Fly"
        case firefly = "Firefly"
        case heartBug = "Heart Bug"
        // Night food
        case gnatSwarm = "Gnat Swarm"
        // Desert food
        case desertBeetle = "Desert Beetle"
        case sandFly = "Sand Fly"
        case desertCricket = "Desert Cricket"
        // Snow food
        case snowFlea = "Snow Flea"
        case iceMoth = "Ice Moth"
        // Jungle food
        case jungleBeetle = "Jungle Beetle"
        case butterfly = "Butterfly"
        // Meadow enemies
        case bird = "Bird"
        case frog = "Frog"
        case dragonfly = "Dragonfly"
        case ant = "Ant"
        // Night enemies
        case spider = "Spider"
        case bat = "Bat"
        case toad = "Toad"
        // Desert enemies
        case scorpion = "Scorpion"
        case rattlesnake = "Rattlesnake"
        case vulture = "Vulture"
        case hawk = "Hawk"
        case desertWasp = "Desert Wasp"
        // Snow enemies
        case iceSpider = "Ice Spider"
        case snowOwl = "Snow Owl"
        // Jungle enemies
        case poisonDartFrog = "Poison Dart Frog"
        case jungleSpider = "Jungle Spider"
        case toucan = "Toucan"
        case monkey = "Monkey"

        var category: Category {
            switch self {
            case .greenAphid, .yellowAphid, .redAphid, .brownFly, .blueFly, .purpleFly,
                 .firefly, .heartBug, .gnatSwarm, .desertBeetle, .sandFly, .desertCricket,
                 .snowFlea, .iceMoth, .jungleBeetle, .butterfly:
                return .food
            case .bird, .frog, .dragonfly, .ant, .spider, .bat, .toad,
                 .scorpion, .rattlesnake, .vulture, .hawk, .desertWasp, .iceSpider, .snowOwl,
                 .poisonDartFrog, .jungleSpider, .toucan, .monkey:
                return .enemy
            }
        }

        var description: String {
            switch self {
            case .greenAphid: return "Common garden pest. Scurries along the ground."
            case .yellowAphid: return "Rarer yellow variant. Faster than green."
            case .redAphid: return "Elusive red aphid. Hard to spot!"
            case .brownFly: return "Common fruit fly. Bobs erratically in the air."
            case .blueFly: return "Rare blue fruit fly. Quick and agile."
            case .purpleFly: return "Mythical purple fly. Very rare spawn."
            case .firefly: return "Magical firefly. Grants 10s invincibility!"
            case .heartBug: return "Heart-shaped healer. Restores one life!"
            case .gnatSwarm: return "Cluster of tiny gnats. Night-time snack."
            case .desertBeetle: return "Hardy desert dweller. Crawls through the sand."
            case .sandFly: return "Buzzes through dry desert air."
            case .desertCricket: return "Chirping desert cricket. Hops through the dunes!"
            case .snowFlea: return "Tiny dark bug that hops on snow."
            case .iceMoth: return "Icy blue moth fluttering through the cold."
            case .jungleBeetle: return "Shiny green beetle in the jungle undergrowth."
            case .butterfly: return "Tropical butterfly dancing through the canopy."
            case .bird: return "Swoops from the sky to attack. Dodge or hide!"
            case .frog: return "Sits by ponds. Shoots tongue at you!"
            case .dragonfly: return "Hovers menacingly over ponds."
            case .ant: return "Patrols the ground. Bites if you get close!"
            case .spider: return "Black widow. Jumps when you approach!"
            case .bat: return "Nocturnal swooper. Faster than birds!"
            case .toad: return "Night-time pond dweller. Sticky tongue!"
            case .scorpion: return "Desert predator. Lunges with its stinger!"
            case .rattlesnake: return "Coiled danger. Strikes when you get close!"
            case .vulture: return "Circling scavenger. Swoops down with huge wings!"
            case .hawk: return "Desert raptor. Dives fast from above!"
            case .desertWasp: return "Aggressive desert wasp. Hunts you down through the air!"
            case .iceSpider: return "Frost-covered spider. Slides on ice!"
            case .snowOwl: return "Silent white hunter in the snow."
            case .poisonDartFrog: return "Vibrant and deadly! Toxic tongue attack!"
            case .jungleSpider: return "Camouflaged in green. Lurks in vines!"
            case .toucan: return "Tropical bird with a massive beak!"
            case .monkey: return "Mischievous jungle monkey! Climbs trees and swipes at you!"
            }
        }

        var points: String {
            switch self {
            case .greenAphid: return "10 pts"
            case .yellowAphid: return "25 pts"
            case .redAphid: return "50 pts"
            case .brownFly: return "15 pts"
            case .blueFly: return "30 pts"
            case .purpleFly: return "50 pts"
            case .firefly: return "100 pts + Shield"
            case .heartBug: return "50 pts + ♥"
            case .gnatSwarm: return "20 pts"
            case .desertBeetle: return "15 pts"
            case .sandFly: return "20 pts"
            case .desertCricket: return "50 pts"
            case .snowFlea: return "15 pts"
            case .iceMoth: return "25 pts"
            case .jungleBeetle: return "30 pts"
            case .butterfly: return "20 pts"
            case .bird, .frog, .dragonfly, .ant, .spider, .bat, .toad,
                 .scorpion, .rattlesnake, .vulture, .hawk, .desertWasp, .iceSpider, .snowOwl,
                 .poisonDartFrog, .jungleSpider, .toucan, .monkey:
                return "Danger!"
            }
        }
    }

    private let key = "BugTrackerUnlocked"

    private var unlocked: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: key) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: key) }
    }

    func unlock(_ bug: BugType) {
        var u = unlocked
        u.insert(bug.rawValue)
        unlocked = u
    }

    func isUnlocked(_ bug: BugType) -> Bool {
        unlocked.contains(bug.rawValue)
    }

    func texture(for bug: BugType, size: CGSize) -> SKTexture {
        if isUnlocked(bug) {
            return coloredTexture(for: bug, size: size)
        } else {
            return silhouetteTexture(size: size)
        }
    }

    private func coloredTexture(for bug: BugType, size: CGSize) -> SKTexture {
        switch bug {
        case .greenAphid: return TextureGenerator.generateAphidTexture(size: size, color: .green)
        case .yellowAphid: return TextureGenerator.generateAphidTexture(size: size, color: .yellow)
        case .redAphid: return TextureGenerator.generateAphidTexture(size: size, color: .red)
        case .brownFly: return TextureGenerator.generateFruitFlyFrames(size: size, color: .brown).first!
        case .blueFly: return TextureGenerator.generateFruitFlyFrames(size: size, color: .blue).first!
        case .purpleFly: return TextureGenerator.generateFruitFlyFrames(size: size, color: .purple).first!
        case .firefly: return TextureGenerator.generateFireflyFrames(size: size).first!
        case .heartBug: return TextureGenerator.generateHeartBugFrames(size: size).first!
        case .gnatSwarm: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(white: 0.8, alpha: 1), eyeColor: .white)
        case .desertBeetle: return TextureGenerator.generateDesertBeetleTexture(size: size)
        case .sandFly: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.70, green: 0.55, blue: 0.25, alpha: 1), eyeColor: .white)
        case .desertCricket: return TextureGenerator.generateDesertCricketTexture(size: size)
        case .snowFlea: return TextureGenerator.generateSnowFleaTexture(size: size)
        case .iceMoth: return TextureGenerator.generateFruitFlyFrames(size: size, color: .blue).first!
        case .jungleBeetle: return TextureGenerator.generateJungleBeetleTexture(size: size)
        case .butterfly: return TextureGenerator.generateFruitFlyFrames(size: size, color: .purple).first!
        case .bird: return TextureGenerator.generateBirdTextures(size: size).first!
        case .frog: return TextureGenerator.generateFrogTexture(size: size)
        case .dragonfly: return TextureGenerator.generateDragonflyFrames(size: size).first!
        case .ant: return TextureGenerator.generateAntFrames(size: size).first!
        case .spider: return TextureGenerator.generateSpiderFrames(size: size).first!
        case .bat: return TextureGenerator.generateBatFrames(size: size).first!
        case .toad: return TextureGenerator.generateToadTexture(size: size)
        case .scorpion: return TextureGenerator.generateScorpionTexture(size: size)
        case .rattlesnake: return TextureGenerator.generateRattlesnakeTexture(size: size)
        case .vulture: return TextureGenerator.generateVultureFrames(size: size).first!
        case .hawk: return TextureGenerator.generateHawkFrames(size: size).first!
        case .desertWasp: return TextureGenerator.generateDesertWaspFrames(size: size).first!
        case .iceSpider: return TextureGenerator.generateIceSpiderTexture(size: size)
        case .snowOwl: return TextureGenerator.generateOwlFrames(size: size).first!
        case .poisonDartFrog: return TextureGenerator.generatePoisonDartFrogTexture(size: size)
        case .jungleSpider: return TextureGenerator.generateJungleSpiderFrames(size: size).first!
        case .toucan: return TextureGenerator.generateToucanFrames(size: size).first!
        case .monkey: return TextureGenerator.generateMonkeyTexture(size: size)
        }
    }

    private func silhouetteTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(UIColor(white: 0.15, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: size.width * 0.10, y: size.height * 0.10,
                                       width: size.width * 0.80, height: size.height * 0.80))
            let qm = NSAttributedString(string: "?", attributes: [
                .font: UIFont.boldSystemFont(ofSize: size.height * 0.4),
                .foregroundColor: UIColor(white: 0.35, alpha: 1.0)
            ])
            let qs = qm.size()
            qm.draw(at: CGPoint(x: (size.width - qs.width) / 2, y: (size.height - qs.height) / 2))
        }
        return SKTexture(image: image)
    }

    static var foodBugs: [BugType] { BugType.allCases.filter { $0.category == .food } }
    static var enemyBugs: [BugType] { BugType.allCases.filter { $0.category == .enemy } }
}
