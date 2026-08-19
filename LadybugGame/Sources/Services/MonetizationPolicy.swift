import Foundation
import UIKit

enum RewardedAdPlacement: String, Sendable {
    case revive
    case doubleRunReward
    case dailyBonus
}

enum InterstitialAdPlacement: String, Sendable {
    case postRun
}

/// Central policy keeps ad cadence deterministic and reviewable instead of
/// scattering monetization decisions throughout scenes.
struct MonetizationPolicy: Sendable {
    static let rewardedRevivesPerRun = 1
    static let runsBetweenInterstitials = 3
    static let minimumRunDurationForInterstitial: TimeInterval = 60
    static let minimumSecondsBetweenInterstitials: TimeInterval = 240

    static func shouldOfferInterstitial(
        runDuration: TimeInterval,
        eligibleRunsSinceLastAd: Int,
        secondsSinceLastAd: TimeInterval,
        hasRemoveAdsEntitlement: Bool
    ) -> Bool {
        guard !hasRemoveAdsEntitlement else { return false }
        guard runDuration >= minimumRunDurationForInterstitial else { return false }
        guard eligibleRunsSinceLastAd >= runsBetweenInterstitials else { return false }
        return secondsSinceLastAd >= minimumSecondsBetweenInterstitials
    }
}

@MainActor
protocol AdServing: AnyObject {
    var isRewardedReady: Bool { get }
    var isInterstitialReady: Bool { get }

    func prepare()
    func showRewarded(from presenter: UIViewController, placement: RewardedAdPlacement) async -> Bool
    func showInterstitial(from presenter: UIViewController, placement: InterstitialAdPlacement) async -> Bool
}

/// Used until consent and a production ad provider are configured. Gameplay
/// always continues normally when ads are unavailable.
@MainActor
final class DisabledAdService: AdServing {
    var isRewardedReady: Bool { false }
    var isInterstitialReady: Bool { false }

    func prepare() {}

    func showRewarded(from presenter: UIViewController, placement: RewardedAdPlacement) async -> Bool {
        false
    }

    func showInterstitial(from presenter: UIViewController, placement: InterstitialAdPlacement) async -> Bool {
        false
    }
}
