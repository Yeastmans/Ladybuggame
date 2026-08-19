import Foundation

/// Data-driven identity and phase pacing for the three Adventure chapter gates.
struct BossProfile: Sendable {
    let level: Int
    let name: String
    let phaseNames: [String]
    let moveWarnings: [String]
    let phaseMoves: [[Int]]
    let healthMultiplier: Double

    func phaseName(_ phase: Int) -> String {
        phaseNames[min(max(phase - 1, 0), phaseNames.count - 1)]
    }

    func moves(for phase: Int) -> [Int] {
        phaseMoves[min(max(phase - 1, 0), phaseMoves.count - 1)]
    }

    func warning(for move: Int) -> String {
        moveWarnings[min(max(move, 0), moveWarnings.count - 1)]
    }

    static func profile(for level: Int) -> BossProfile {
        switch level {
        case 2:
            return BossProfile(
                level: 2,
                name: "Stormfeather Crow",
                phaseNames: ["Circling", "Gathering Storm", "Blackout"],
                moveWarnings: ["FEATHER VOLLEY", "LOW SWOOP", "RAZOR FLOCK", "WIND GUST"],
                phaseMoves: [[0, 1], [0, 3, 1, 2], [3, 2, 1, 2, 0]],
                healthMultiplier: 2.0
            )
        case 3:
            return BossProfile(
                level: 3,
                name: "Void Harvester",
                phaseNames: ["Scanning", "Abduction", "Core Overload"],
                moveWarnings: ["TARGETING LASER", "METEOR DROP", "GRAVITY SWEEP", "COMBO STRIKE"],
                phaseMoves: [[0, 1], [0, 2, 1], [2, 3, 1, 0]],
                healthMultiplier: 2.5
            )
        default:
            return BossProfile(
                level: 1,
                name: "Bramble Bear",
                phaseNames: ["Sizing You Up", "Breaking Ground", "Last Roar"],
                moveWarnings: ["ROCK THROW", "ROCK BARRAGE", "CHARGE", "GROUND SLAM"],
                phaseMoves: [[0, 2], [0, 1, 3, 2], [3, 1, 2, 1, 0]],
                healthMultiplier: 1.0
            )
        }
    }
}
