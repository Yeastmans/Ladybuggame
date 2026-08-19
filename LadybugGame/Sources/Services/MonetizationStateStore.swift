import Foundation

/// Persists frequency caps and one-per-day rewards across app launches.
@MainActor
final class MonetizationStateStore {
    static let shared = MonetizationStateStore()
    static let dailyBonusGems = 5

    private let defaults: UserDefaults
    private let eligibleRunsKey = "MonetizationEligibleRunsSinceInterstitial"
    private let lastInterstitialKey = "MonetizationLastInterstitialAt"
    private let lastDailyBonusKey = "MonetizationLastDailyBonusAt"

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var canClaimDailyBonus: Bool {
        let timestamp = defaults.double(forKey: lastDailyBonusKey)
        guard timestamp > 0 else { return true }
        return !Calendar.current.isDateInToday(Date(timeIntervalSince1970: timestamp))
    }

    func claimDailyBonusIfAvailable() -> Int {
        guard canClaimDailyBonus else { return 0 }
        defaults.set(Date().timeIntervalSince1970, forKey: lastDailyBonusKey)
        return Self.dailyBonusGems
    }

    func registerEligibleRun(duration: TimeInterval) {
        guard duration >= MonetizationPolicy.minimumRunDurationForInterstitial else { return }
        defaults.set(defaults.integer(forKey: eligibleRunsKey) + 1, forKey: eligibleRunsKey)
    }

    func shouldOfferPostRunInterstitial(runDuration: TimeInterval, hasRemoveAds: Bool) -> Bool {
        let lastTimestamp = defaults.double(forKey: lastInterstitialKey)
        let secondsSinceLastAd = lastTimestamp > 0
            ? max(0, Date().timeIntervalSince1970 - lastTimestamp)
            : TimeInterval.greatestFiniteMagnitude

        return MonetizationPolicy.shouldOfferInterstitial(
            runDuration: runDuration,
            eligibleRunsSinceLastAd: defaults.integer(forKey: eligibleRunsKey),
            secondsSinceLastAd: secondsSinceLastAd,
            hasRemoveAdsEntitlement: hasRemoveAds
        )
    }

    func markInterstitialPresented() {
        defaults.set(0, forKey: eligibleRunsKey)
        defaults.set(Date().timeIntervalSince1970, forKey: lastInterstitialKey)
    }
}
