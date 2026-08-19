import Foundation
import CoreGraphics

struct CampaignStageRecord: Codable, Equatable {
    var completed = false
    var bestStars = 0
    var bestScore = 0
    var bestDistance: Double = 0
    var bestLivesRemaining = 0
    var attempts = 0
}

struct CampaignCompletionResult {
    let stars: Int
    let previousBestStars: Int
    let isFirstClear: Bool
    let isNewBestScore: Bool
}

/// Owns durable Adventure progression. Legacy score checkpoints are imported
/// once, after which stage completion is the sole source of unlocks.
@MainActor
final class CampaignProgressStore {
    static let shared = CampaignProgressStore()

    private let defaults: UserDefaults
    private let recordsKey = "AdventureStageRecordsV1"
    private let migrationKey = "AdventureCheckpointMigrationV1"
    private let lastStageKey = "AdventureLastStageID"
    private var records: [String: CampaignStageRecord]

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([String: CampaignStageRecord].self, from: data) {
            records = decoded
        } else {
            records = [:]
        }
    }

    func migrateLegacyProgress(unlockedBiomeIDs: [Int], checkpointScore: Int, highScore: Int) {
        guard !defaults.bool(forKey: migrationKey) else { return }

        var highestReached = unlockedBiomeIDs.max() ?? 0
        let legacyScore = max(checkpointScore, highScore)
        if legacyScore > 0 {
            highestReached = max(highestReached, Biome.biome(for: legacyScore).rawValue)
        }
        highestReached = min(max(0, highestReached), CampaignStage.all.count - 1)

        // A legacy checkpoint meant the player had reached this biome. Mark all
        // earlier stages complete and leave that biome available to continue.
        if highestReached > 0 {
            for id in 0..<highestReached {
                var value = record(for: id)
                value.completed = true
                value.bestStars = max(1, value.bestStars)
                records[String(id)] = value
            }
        }

        save()
        defaults.set(true, forKey: migrationKey)
    }

    func record(for stageID: Int) -> CampaignStageRecord {
        records[String(stageID)] ?? CampaignStageRecord()
    }

    func isUnlocked(_ stageID: Int) -> Bool {
        guard CampaignStage.stage(id: stageID) != nil else { return false }
        return stageID == 0 || record(for: stageID - 1).completed
    }

    var completedCount: Int {
        CampaignStage.all.filter { record(for: $0.id).completed }.count
    }

    var totalStars: Int {
        CampaignStage.all.reduce(0) { $0 + record(for: $1.id).bestStars }
    }

    var isAdventureComplete: Bool {
        completedCount == CampaignStage.all.count
    }

    var nextPlayableStageID: Int {
        CampaignStage.all.first(where: { isUnlocked($0.id) && !record(for: $0.id).completed })?.id
            ?? CampaignStage.all.last?.id
            ?? 0
    }

    var continueStageID: Int {
        let last = defaults.integer(forKey: lastStageKey)
        if isUnlocked(last), !record(for: last).completed { return last }
        return nextPlayableStageID
    }

    func beginStage(_ stageID: Int) {
        guard isUnlocked(stageID) else { return }
        var value = record(for: stageID)
        value.attempts += 1
        records[String(stageID)] = value
        defaults.set(stageID, forKey: lastStageKey)
        save()
    }

    func recordRun(stageID: Int, score: Int, distance: CGFloat, livesRemaining: Int) {
        var value = record(for: stageID)
        value.bestScore = max(value.bestScore, score)
        value.bestDistance = max(value.bestDistance, Double(distance))
        value.bestLivesRemaining = max(value.bestLivesRemaining, livesRemaining)
        records[String(stageID)] = value
        save()
    }

    func completeStage(
        _ stage: CampaignStage,
        score: Int,
        distance: CGFloat,
        hitsTaken: Int,
        livesRemaining: Int
    ) -> CampaignCompletionResult {
        var value = record(for: stage.id)
        let previousStars = value.bestStars
        let previousScore = value.bestScore
        let firstClear = !value.completed

        var stars = 1
        if score >= stage.masteryScore { stars += 1 }
        if hitsTaken <= 1 { stars += 1 }

        value.completed = true
        value.bestStars = max(value.bestStars, stars)
        value.bestScore = max(value.bestScore, score)
        value.bestDistance = max(value.bestDistance, Double(distance))
        value.bestLivesRemaining = max(value.bestLivesRemaining, livesRemaining)
        records[String(stage.id)] = value
        if let next = CampaignStage.stage(id: stage.id + 1) {
            defaults.set(next.id, forKey: lastStageKey)
        }
        save()

        return CampaignCompletionResult(
            stars: stars,
            previousBestStars: previousStars,
            isFirstClear: firstClear,
            isNewBestScore: score > previousScore
        )
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: recordsKey)
    }
}
