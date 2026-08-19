import Foundation

/// Single owner for currency persistence. Existing callers can migrate gradually
/// while StoreKit grants and gameplay rewards share the same balance.
@MainActor
final class PlayerWallet {
    static let shared = PlayerWallet()

    private let defaults: UserDefaults
    private let gemsKey = "GemstoneCount"
    private let transactionLedgerKey = "GrantedStoreTransactionIDs"

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var gems: Int {
        get { max(0, defaults.integer(forKey: gemsKey)) }
        set { defaults.set(max(0, newValue), forKey: gemsKey) }
    }

    func addGems(_ amount: Int) {
        guard amount > 0 else { return }
        gems += amount
    }

    @discardableResult
    func spendGems(_ amount: Int) -> Bool {
        guard amount >= 0, gems >= amount else { return false }
        gems -= amount
        return true
    }

    /// Returns false when StoreKit redelivers a transaction already granted on
    /// this install, preventing duplicate consumable rewards after interruption.
    @discardableResult
    func grantStoreGems(_ amount: Int, transactionID: UInt64) -> Bool {
        guard amount > 0 else { return false }
        let key = String(transactionID)
        var granted = Set(defaults.stringArray(forKey: transactionLedgerKey) ?? [])
        guard granted.insert(key).inserted else { return false }
        defaults.set(Array(granted).sorted(), forKey: transactionLedgerKey)
        addGems(amount)
        return true
    }
}
