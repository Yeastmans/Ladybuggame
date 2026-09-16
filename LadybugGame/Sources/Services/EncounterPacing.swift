import Foundation

/// A repeating breathing space for finite stages. Endless retains its old cadence.
enum EncounterPacing {
    static func enemyTimeScale(distance: Double, targetDistance: Double?) -> Double {
        guard let targetDistance, targetDistance > 0 else { return 1 }
        let progress = min(1, max(0, distance / targetDistance))
        if progress < 0.12 { return 0.45 }
        if progress > 0.90 { return 0.70 }
        // Short recovery windows between encounter sections; food keeps spawning.
        let section = progress.truncatingRemainder(dividingBy: 0.25)
        return section > 0.19 ? 0.25 : 1
    }
}
