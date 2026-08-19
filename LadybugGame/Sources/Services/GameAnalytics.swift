import Foundation

/// Vendor-neutral product telemetry. The launch implementation can be swapped
/// without coupling gameplay code to a specific analytics SDK.
enum GameAnalyticsEvent: Sendable {
    case appLaunched
    case runStarted(difficulty: String, checkpoint: String?)
    case runEnded(score: Int, biome: String, durationSeconds: Int)
    case biomeReached(name: String, score: Int)
    case bossStarted(level: Int)
    case bossDefeated(level: Int)
    case economySpend(itemID: String, gems: Int)

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .runStarted: return "run_started"
        case .runEnded: return "run_ended"
        case .biomeReached: return "biome_reached"
        case .bossStarted: return "boss_started"
        case .bossDefeated: return "boss_defeated"
        case .economySpend: return "economy_spend"
        }
    }

    var parameters: [String: String] {
        switch self {
        case .appLaunched:
            return [:]
        case let .runStarted(difficulty, checkpoint):
            return ["difficulty": difficulty, "checkpoint": checkpoint ?? "new_run"]
        case let .runEnded(score, biome, durationSeconds):
            return ["score": String(score), "biome": biome, "duration_seconds": String(durationSeconds)]
        case let .biomeReached(name, score):
            return ["biome": name, "score": String(score)]
        case let .bossStarted(level), let .bossDefeated(level):
            return ["boss_level": String(level)]
        case let .economySpend(itemID, gems):
            return ["item_id": itemID, "gems": String(gems)]
        }
    }
}

protocol GameAnalytics: Sendable {
    func track(_ event: GameAnalyticsEvent)
}

/// Privacy-safe default: no data leaves the device. Debug builds emit events
/// to Xcode/Codemagic logs so event coverage can be verified before an SDK is chosen.
struct LocalGameAnalytics: GameAnalytics {
    func track(_ event: GameAnalyticsEvent) {
#if DEBUG
        let fields = event.parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        print("[analytics] \(event.name)\(fields.isEmpty ? "" : " \(fields)")")
#endif
    }
}
