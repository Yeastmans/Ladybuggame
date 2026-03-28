import SpriteKit
import UIKit

/// Tracks which bugs the player has caught. Persists via UserDefaults.
final class BugTracker: @unchecked Sendable {
    static let shared = BugTracker()

    enum BugType: String, CaseIterable {
        case greenAphid = "Green Aphid"
        case yellowAphid = "Yellow Aphid"
        case redAphid = "Red Aphid"
        case brownFly = "Fruit Fly"
        case blueFly = "Blue Fly"
        case purpleFly = "Purple Fly"
        case firefly = "Firefly"
        case heartBug = "Heart Bug"
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

    /// Generate a colored silhouette or the real texture
    func texture(for bug: BugType, size: CGSize) -> SKTexture {
        if isUnlocked(bug) {
            return coloredTexture(for: bug, size: size)
        } else {
            return silhouetteTexture(for: bug, size: size)
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
        }
    }

    private func silhouetteTexture(for bug: BugType, size: CGSize) -> SKTexture {
        // Draw a dark silhouette with a question mark
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let w = size.width
            let h = size.height

            cg.setFillColor(UIColor(white: 0.15, alpha: 1.0).cgColor)
            cg.fillEllipse(in: CGRect(x: w * 0.10, y: h * 0.10, width: w * 0.80, height: h * 0.80))

            // Question mark
            let qm = NSAttributedString(string: "?", attributes: [
                .font: UIFont.boldSystemFont(ofSize: h * 0.4),
                .foregroundColor: UIColor(white: 0.35, alpha: 1.0)
            ])
            let qmSize = qm.size()
            qm.draw(at: CGPoint(x: (w - qmSize.width) / 2, y: (h - qmSize.height) / 2))
        }
        return SKTexture(image: image)
    }
}
