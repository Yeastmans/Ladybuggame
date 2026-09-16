import Foundation

/// Single owner for currency persistence. Existing callers can migrate gradually
/// while StoreKit grants and gameplay rewards share the same balance.
@MainActor
final class PlayerWallet {
    static let shared = PlayerWallet()

    private let defaults: UserDefaults
    private struct Snapshot: Codable {
        var version = 2
        var gems: Int
        var grantedTransactions: Set<String>
        var ownedItems: Set<String>
    }
    private let key = "PlayerWalletSnapshotV2"
    private var snapshot: Snapshot

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let saved = try? JSONDecoder().decode(Snapshot.self, from: data) {
            snapshot = saved
        } else {
            snapshot = Snapshot(gems: max(0, defaults.integer(forKey: "GemstoneCount")),
                grantedTransactions: Set(defaults.stringArray(forKey: "GrantedStoreTransactionIDs") ?? []),
                ownedItems: Set(defaults.stringArray(forKey: "OwnedShopItems") ?? []))
            persist(snapshot)
        }
    }

    var gems: Int {
        get { snapshot.gems }
        set { var next = snapshot; next.gems = max(0, newValue); persist(next) }
    }

    var ownedItems: [String] {
        get { snapshot.ownedItems.sorted() }
        set { var next = snapshot; next.ownedItems = Set(newValue); persist(next) }
    }

    func addGems(_ amount: Int) {
        guard amount > 0, amount <= Int.max - gems else { return }
        gems += amount
    }

    @discardableResult
    func spendGems(_ amount: Int) -> Bool {
        guard amount >= 0, gems >= amount else { return false }
        var next = snapshot
        next.gems -= amount
        return persist(next)
    }

    /// Commit the cost and ownership together; repeating confirmation is harmless.
    @discardableResult
    func unlockCosmetic(_ id: String, price: Int) -> Bool {
        guard price >= 0 else { return false }
        if snapshot.ownedItems.contains(id) { return true }
        guard gems >= price else { return false }
        var next = snapshot
        next.gems -= price
        next.ownedItems.insert(id)
        return persist(next)
    }

    /// Returns false when StoreKit redelivers a transaction already granted on
    /// this install, preventing duplicate consumable rewards after interruption.
    @discardableResult
    func grantStoreGems(_ amount: Int, transactionID: UInt64) -> Bool {
        guard amount > 0, amount <= Int.max - gems else { return false }
        var next = snapshot
        guard next.grantedTransactions.insert(String(transactionID)).inserted else { return false }
        next.gems += amount
        return persist(next)
    }

    @discardableResult
    private func persist(_ value: Snapshot) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else { return false }
        defaults.set(data, forKey: key)
        snapshot = value
        return true
    }
}
