import SpriteKit
import UIKit

final class BugTracker: @unchecked Sendable {
    static let shared = BugTracker()

    enum Category: String { case food = "Snacks", enemy = "Threats" }

    enum BugType: String, CaseIterable {
        case greenAphid = "Green Aphid"
        case yellowAphid = "Yellow Aphid"
        case redAphid = "Red Aphid"
        case brownFly = "Fruit Fly"
        case blueFly = "Blue Fly"
        case purpleFly = "Purple Fly"
        case firefly = "Firefly"
        case heartBug = "Heart Bug"
        case bird = "Bird"
        case frog = "Frog"
        case dragonfly = "Dragonfly"
        case ant = "Ant"
        case spider = "Spider"

        var category: Category {
            switch self {
            case .greenAphid, .yellowAphid, .redAphid, .brownFly, .blueFly, .purpleFly, .firefly, .heartBug:
                return .food
            case .bird, .frog, .dragonfly, .ant, .spider:
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
            case .bird: return "Swoops from the sky to attack. Dodge or hide!"
            case .frog: return "Sits by ponds. Shoots tongue at you!"
            case .dragonfly: return "Hovers menacingly. Hard to avoid in the air."
            case .ant: return "Patrols the ground. Bites if you get close!"
            case .spider: return "Lurks on the ground. Can hide in bushes!"
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
            case .bird, .frog, .dragonfly, .ant, .spider: return "Danger!"
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
        case .bird: return TextureGenerator.generateBirdTextures(size: size).first!
        case .frog: return TextureGenerator.generateFrogTexture(size: size)
        case .dragonfly: return TextureGenerator.generateDragonflyFrames(size: size).first!
        case .ant: return TextureGenerator.generateAntFrames(size: size).first!
        case .spider: return TextureGenerator.generateSpiderFrames(size: size).first!
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
