import Foundation

/// Vendor-neutral product telemetry. The launch implementation can be swapped
/// without coupling gameplay code to a specific analytics SDK.
enum GameAnalyticsEvent: Sendable {
    case appLaunched
    case runStarted(difficulty: String, checkpoint: String?)
    case runEnded(score: Int, biome: String, durationSeconds: Int)
    case stageStarted(number: Int, name: String)
    case stageCompleted(number: Int, name: String, stars: Int, score: Int)
    case biomeReached(name: String, score: Int)
    case bossStarted(level: Int)
    case bossDefeated(level: Int)
    case economySpend(itemID: String, gems: Int)
    case adStarted(format: String, placement: String)
    case adCompleted(format: String, placement: String)
    case purchaseStarted(productID: String)
    case purchaseCompleted(productID: String)
    case purchaseFailed(productID: String, reason: String)
    case purchasesRestored(success: Bool)

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .runStarted: return "run_started"
        case .runEnded: return "run_ended"
        case .stageStarted: return "stage_started"
        case .stageCompleted: return "stage_completed"
        case .biomeReached: return "biome_reached"
        case .bossStarted: return "boss_started"
        case .bossDefeated: return "boss_defeated"
        case .economySpend: return "economy_spend"
        case .adStarted: return "ad_started"
        case .adCompleted: return "ad_completed"
        case .purchaseStarted: return "purchase_started"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .purchasesRestored: return "purchases_restored"
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
        case let .stageStarted(number, name):
            return ["stage_number": String(number), "stage_name": name]
        case let .stageCompleted(number, name, stars, score):
            return ["stage_number": String(number), "stage_name": name, "stars": String(stars), "score": String(score)]
        case let .biomeReached(name, score):
            return ["biome": name, "score": String(score)]
        case let .bossStarted(level), let .bossDefeated(level):
            return ["boss_level": String(level)]
        case let .economySpend(itemID, gems):
            return ["item_id": itemID, "gems": String(gems)]
        case let .adStarted(format, placement), let .adCompleted(format, placement):
            return ["format": format, "placement": placement]
        case let .purchaseStarted(productID), let .purchaseCompleted(productID):
            return ["product_id": productID]
        case let .purchaseFailed(productID, reason):
            return ["product_id": productID, "reason": reason]
        case let .purchasesRestored(success):
            return ["success": String(success)]
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
