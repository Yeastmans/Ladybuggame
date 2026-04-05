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
        // Cave food
        case caveCricket = "Cave Cricket"
        case glowworm = "Glowworm"
        case crystalBeetle = "Crystal Beetle"
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
        case frostMoth = "Frost Moth"
        // Jungle enemies
        case poisonDartFrog = "Poison Dart Frog"
        case jungleSpider = "Jungle Spider"
        case toucan = "Toucan"
        case monkey = "Monkey"
        case cicadaBee = "Cicada Bee"
        // Cave enemies
        case caveSpider = "Cave Spider"
        case vampireBat = "Vampire Bat"
        case rockWorm = "Rock Worm"
        case caveFish = "Cave Fish"
        // Underwater food
        case seaSnail = "Sea Snail"
        case plankton = "Plankton"
        case shrimplet = "Shrimplet"
        // Underwater enemies
        case jellyfish = "Jellyfish"
        case anglerFish = "Angler Fish"
        case seaUrchin = "Sea Urchin"
        case electricEel = "Electric Eel"
        // Volcano food
        case emberBeetle = "Ember Beetle"
        case ashMoth = "Ash Moth"
        case magmaSnail = "Magma Snail"
        // Volcano enemies
        case lavaSlime = "Lava Slime"
        case fireAnt = "Fire Ant"
        case phoenixBird = "Phoenix"
        case obsidianGolem = "Obsidian Golem"
        // Cloud food
        case cloudMite = "Cloud Mite"
        case starBug = "Star Bug"
        case skyJelly = "Sky Jelly"
        // Cloud enemies
        case stormHawk = "Storm Hawk"
        case windSprite = "Wind Sprite"
        case thunderWasp = "Thunder Wasp"
        case lightningBug = "Lightning Bug"
        // Swamp food
        case mudCricket = "Mud Cricket"
        case swampFly = "Swamp Fly"
        case leech = "Leech"
        // Swamp enemies
        case mosquitoSwarm = "Mosquito Swarm"
        case alligator = "Alligator"
        case swampSnake = "Swamp Snake"
        case bogSpider = "Bog Spider"
        // City/Garden food
        case gardenAnt = "Garden Ant"
        case honeybee = "Honeybee"
        case pillBug = "Pill Bug"
        // City/Garden enemies
        case houseCat = "House Cat"
        case gardenSnake = "Garden Snake"
        case yellowJacket = "Yellow Jacket"
        case gardenSpider = "Garden Spider"

        var category: Category {
            switch self {
            case .greenAphid, .yellowAphid, .redAphid, .brownFly, .blueFly, .purpleFly,
                 .firefly, .heartBug, .gnatSwarm, .desertBeetle, .sandFly, .desertCricket,
                 .snowFlea, .iceMoth, .jungleBeetle, .butterfly,
                 .caveCricket, .glowworm, .crystalBeetle,
                 .seaSnail, .plankton, .shrimplet,
                 .emberBeetle, .ashMoth, .magmaSnail,
                 .cloudMite, .starBug, .skyJelly,
                 .mudCricket, .swampFly, .leech,
                 .gardenAnt, .honeybee, .pillBug:
                return .food
            case .bird, .frog, .dragonfly, .ant, .spider, .bat, .toad,
                 .scorpion, .rattlesnake, .vulture, .hawk, .desertWasp, .iceSpider, .snowOwl, .frostMoth,
                 .poisonDartFrog, .jungleSpider, .toucan, .monkey, .cicadaBee,
                 .caveSpider, .vampireBat, .rockWorm, .caveFish,
                 .jellyfish, .anglerFish, .seaUrchin, .electricEel,
                 .lavaSlime, .fireAnt, .phoenixBird, .obsidianGolem,
                 .stormHawk, .windSprite, .thunderWasp, .lightningBug,
                 .mosquitoSwarm, .alligator, .swampSnake, .bogSpider,
                 .houseCat, .gardenSnake, .yellowJacket, .gardenSpider:
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
            case .frostMoth: return "Icy moth that patrols the frozen skies!"
            case .poisonDartFrog: return "Vibrant and deadly! Toxic tongue attack!"
            case .jungleSpider: return "Camouflaged in green. Lurks in vines!"
            case .toucan: return "Tropical bird with a massive beak!"
            case .monkey: return "Mischievous jungle monkey! Climbs trees and swipes at you!"
            case .cicadaBee: return "Loud jungle cicada-bee hybrid. Buzzes through the canopy!"
            case .caveCricket: return "Pale cave cricket. Hops in the darkness."
            case .glowworm: return "Bioluminescent worm. Lights up the cave!"
            case .crystalBeetle: return "Rare crystalline beetle. Shimmers with cave gems!"
            case .caveSpider: return "Drops from the ceiling on a web! Watch above!"
            case .vampireBat: return "Red-eyed vampire bat. Swoops from the darkness!"
            case .rockWorm: return "Armored tunnel worm. Patrols the cave floor."
            case .caveFish: return "Blind pale fish. Leaps from underground pools!"
            // Underwater
            case .seaSnail: return "Slow spiral shell. Slides along the sea floor."
            case .plankton: return "Glowing plankton cloud. Floats in the current."
            case .shrimplet: return "Tiny shrimp. Darts through the water!"
            case .jellyfish: return "Translucent and deadly. Tentacles sting on contact!"
            case .anglerFish: return "Deep sea hunter. Lures with its glowing light!"
            case .seaUrchin: return "Spiny ball on the ocean floor. Don't touch!"
            case .electricEel: return "Zaps nearby bugs with electric shocks!"
            // Volcano
            case .emberBeetle: return "Fireproof beetle. Glows with inner heat."
            case .ashMoth: return "Gray moth dancing in volcanic ash."
            case .magmaSnail: return "Molten trail. Slowly crosses the hot ground."
            case .lavaSlime: return "Bubbling lava blob. Slides toward you!"
            case .fireAnt: return "Red-hot ant. Patrols volcanic rock!"
            case .phoenixBird: return "Blazing bird reborn from flames. Dives with fire!"
            case .obsidianGolem: return "Slow stone creature. Throws rocks when near!"
            // Cloud
            case .cloudMite: return "Tiny fluffy mite bouncing on clouds."
            case .starBug: return "Sparkling bug made of starlight."
            case .skyJelly: return "Floating jellyfish of the sky. Harmless and delicious!"
            case .stormHawk: return "Dark hawk riding storm winds. Swoops with lightning!"
            case .windSprite: return "Invisible air spirit. Pushes you with gusts!"
            case .thunderWasp: return "Electric wasp. Buzzes with crackling energy!"
            case .lightningBug: return "Not a firefly — shoots actual lightning bolts!"
            // Swamp
            case .mudCricket: return "Brown cricket hiding in the muck."
            case .swampFly: return "Buzzes through humid swamp air."
            case .leech: return "Slimy blood-sucker. Slow but worth eating."
            case .mosquitoSwarm: return "Cloud of biting mosquitoes. Ouch!"
            case .alligator: return "Lurks in swamp water. Massive jaws snap!"
            case .swampSnake: return "Slithers through murky water. Fast striker!"
            case .bogSpider: return "Web-building swamp spider. Catches flies and you!"
            // City/Garden
            case .gardenAnt: return "Tiny ant carrying a crumb. Easy snack."
            case .honeybee: return "Friendly bee. Sweet and nutritious!"
            case .pillBug: return "Rolls into a ball when scared. Crunchy!"
            case .houseCat: return "Giant fluffy predator. Pounces from above!"
            case .gardenSnake: return "Small green snake in the flower bed."
            case .yellowJacket: return "Aggressive wasp. Patrols the garden aggressively!"
            case .gardenSpider: return "Orb weaver in the bushes. Web traps you!"
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
            case .gnatSwarm: return "30 pts"
            case .desertBeetle: return "15 pts"
            case .sandFly: return "20 pts"
            case .desertCricket: return "50 pts"
            case .caveCricket: return "25 pts"
            case .glowworm: return "35 pts"
            case .crystalBeetle: return "50 pts"
            case .seaSnail: return "20 pts"
            case .plankton: return "30 pts"
            case .shrimplet: return "40 pts"
            case .emberBeetle: return "25 pts"
            case .ashMoth: return "30 pts"
            case .magmaSnail: return "45 pts"
            case .cloudMite: return "20 pts"
            case .starBug: return "35 pts"
            case .skyJelly: return "40 pts"
            case .mudCricket: return "20 pts"
            case .swampFly: return "25 pts"
            case .leech: return "35 pts"
            case .gardenAnt: return "15 pts"
            case .honeybee: return "30 pts"
            case .pillBug: return "25 pts"
            case .snowFlea: return "15 pts"
            case .iceMoth: return "25 pts"
            case .jungleBeetle: return "30 pts"
            case .butterfly: return "20 pts"
            case .bird, .frog, .dragonfly, .ant, .spider, .bat, .toad,
                 .scorpion, .rattlesnake, .vulture, .hawk, .desertWasp, .iceSpider, .snowOwl, .frostMoth,
                 .poisonDartFrog, .jungleSpider, .toucan, .monkey, .cicadaBee,
                 .caveSpider, .vampireBat, .rockWorm, .caveFish,
                 .jellyfish, .anglerFish, .seaUrchin, .electricEel,
                 .lavaSlime, .fireAnt, .phoenixBird, .obsidianGolem,
                 .stormHawk, .windSprite, .thunderWasp, .lightningBug,
                 .mosquitoSwarm, .alligator, .swampSnake, .bogSpider,
                 .houseCat, .gardenSnake, .yellowJacket, .gardenSpider:
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
        case .frostMoth: return TextureGenerator.generateFrostMothFrames(size: size).first!
        case .poisonDartFrog: return TextureGenerator.generatePoisonDartFrogTexture(size: size)
        case .jungleSpider: return TextureGenerator.generateJungleSpiderFrames(size: size).first!
        case .toucan: return TextureGenerator.generateToucanFrames(size: size).first!
        case .monkey: return TextureGenerator.generateMonkeyTexture(size: size)
        case .cicadaBee: return TextureGenerator.generateCicadaBeeFrames(size: size).first!
        case .caveCricket: return TextureGenerator.generateCaveCricketTexture(size: size)
        case .glowworm: return TextureGenerator.generateGlowwormTexture(size: size)
        case .crystalBeetle: return TextureGenerator.generateCrystalBeetleTexture(size: size)
        case .caveSpider: return TextureGenerator.generateCaveSpiderTexture(size: size)
        case .vampireBat: return TextureGenerator.generateVampireBatFrames(size: size).first!
        case .rockWorm: return TextureGenerator.generateRockWormTexture(size: size)
        case .caveFish: return TextureGenerator.generateCaveFishTexture(size: size)
        // Underwater
        case .seaSnail: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.55, green: 0.45, blue: 0.60, alpha: 1), eyeColor: .white)
        case .plankton: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.30, green: 0.80, blue: 0.70, alpha: 1), eyeColor: .white)
        case .shrimplet: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.90, green: 0.55, blue: 0.45, alpha: 1), eyeColor: .black)
        case .jellyfish: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.70, green: 0.50, blue: 0.85, alpha: 1), eyeColor: .white)
        case .anglerFish: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.25, green: 0.20, blue: 0.30, alpha: 1), eyeColor: UIColor.yellow)
        case .seaUrchin: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.20, green: 0.15, blue: 0.25, alpha: 1), eyeColor: .red)
        case .electricEel: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.25, green: 0.35, blue: 0.55, alpha: 1), eyeColor: UIColor.yellow)
        // Volcano
        case .emberBeetle: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.70, green: 0.30, blue: 0.10, alpha: 1), eyeColor: UIColor.orange)
        case .ashMoth: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.50, green: 0.48, blue: 0.45, alpha: 1), eyeColor: .white)
        case .magmaSnail: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.85, green: 0.40, blue: 0.10, alpha: 1), eyeColor: UIColor.yellow)
        case .lavaSlime: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.90, green: 0.30, blue: 0.05, alpha: 1), eyeColor: UIColor.yellow)
        case .fireAnt: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.75, green: 0.15, blue: 0.08, alpha: 1), eyeColor: UIColor.orange)
        case .phoenixBird: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.95, green: 0.55, blue: 0.10, alpha: 1), eyeColor: UIColor.red)
        case .obsidianGolem: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.18, green: 0.15, blue: 0.20, alpha: 1), eyeColor: UIColor.red)
        // Cloud
        case .cloudMite: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.90, green: 0.92, blue: 0.98, alpha: 1), eyeColor: UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1))
        case .starBug: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.95, green: 0.88, blue: 0.40, alpha: 1), eyeColor: .white)
        case .skyJelly: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.70, green: 0.80, blue: 0.95, alpha: 1), eyeColor: .white)
        case .stormHawk: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.30, green: 0.30, blue: 0.40, alpha: 1), eyeColor: UIColor.yellow)
        case .windSprite: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.80, green: 0.90, blue: 0.95, alpha: 1), eyeColor: UIColor.cyan)
        case .thunderWasp: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.85, green: 0.75, blue: 0.15, alpha: 1), eyeColor: .black)
        case .lightningBug: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.95, green: 0.90, blue: 0.30, alpha: 1), eyeColor: UIColor.blue)
        // Swamp
        case .mudCricket: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.45, green: 0.38, blue: 0.25, alpha: 1), eyeColor: .white)
        case .swampFly: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.35, green: 0.42, blue: 0.22, alpha: 1), eyeColor: .red)
        case .leech: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.30, green: 0.18, blue: 0.15, alpha: 1), eyeColor: .white)
        case .mosquitoSwarm: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.35, green: 0.30, blue: 0.28, alpha: 1), eyeColor: .red)
        case .alligator: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.28, green: 0.38, blue: 0.18, alpha: 1), eyeColor: UIColor.yellow)
        case .swampSnake: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.32, green: 0.35, blue: 0.20, alpha: 1), eyeColor: UIColor.yellow)
        case .bogSpider: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.35, green: 0.30, blue: 0.22, alpha: 1), eyeColor: .red)
        // City/Garden
        case .gardenAnt: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.18, green: 0.15, blue: 0.12, alpha: 1), eyeColor: .white)
        case .honeybee: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.92, green: 0.75, blue: 0.15, alpha: 1), eyeColor: .black)
        case .pillBug: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1), eyeColor: .white)
        case .houseCat: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.75, green: 0.55, blue: 0.35, alpha: 1), eyeColor: UIColor.green)
        case .gardenSnake: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.30, green: 0.55, blue: 0.22, alpha: 1), eyeColor: UIColor.yellow)
        case .yellowJacket: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.90, green: 0.78, blue: 0.10, alpha: 1), eyeColor: .black)
        case .gardenSpider: return TextureGenerator.generateSimpleCreature(size: size, bodyColor: UIColor(red: 0.50, green: 0.42, blue: 0.25, alpha: 1), eyeColor: .red)
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
