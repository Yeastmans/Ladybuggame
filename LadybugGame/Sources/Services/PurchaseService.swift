import Foundation
import StoreKit

enum AppPurchaseOutcome: Sendable {
    case purchased
    case pending
    case cancelled
    case unavailable
    case failed(String)
}

/// StoreKit 2 boundary for verified transactions and restorable entitlements.
/// Product merchandising UI is deliberately separate from transaction handling.
@MainActor
final class PurchaseService {
    private(set) var products: [PurchaseProductID: Product] = [:]
    private(set) var entitlements: Set<PurchaseProductID> = []

    private var updateListener: Task<Void, Never>?

    init() {
        updateListener = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self else { return }
                await self.handle(result)
            }
        }
    }

    var hasRemoveAds: Bool {
        entitlements.contains(.removeAds)
    }

    func prepare() async {
        await refreshEntitlements()
        do {
            let loaded = try await Product.products(for: PurchaseProductID.allCases.map(\.rawValue))
            products = Dictionary(uniqueKeysWithValues: loaded.compactMap { product in
                guard let id = PurchaseProductID(rawValue: product.id) else { return nil }
                return (id, product)
            })
        } catch {
            products = [:]
        }
    }

    func purchase(_ id: PurchaseProductID) async -> AppPurchaseOutcome {
        guard let product = products[id] else { return .unavailable }

        do {
            switch try await product.purchase() {
            case let .success(result):
                guard case let .verified(transaction) = result else {
                    return .failed("transaction_unverified")
                }
                await deliver(transaction)
                return .purchased
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            @unknown default:
                return .failed("unknown_purchase_result")
            }
        } catch {
            return .failed(String(describing: error))
        }
    }

    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return true
        } catch {
            return false
        }
    }

    private func handle(_ result: VerificationResult<StoreKit.Transaction>) async {
        guard case let .verified(transaction) = result else { return }
        await deliver(transaction)
    }

    private func deliver(_ transaction: StoreKit.Transaction) async {
        guard let id = PurchaseProductID(rawValue: transaction.productID) else {
            await transaction.finish()
            return
        }

        if !id.isConsumable {
            entitlements.insert(id)
        }

        if let gems = PurchaseCatalog.gemGrant[id] {
            PlayerWallet.shared.grantStoreGems(gems, transactionID: transaction.id)
        }

        await transaction.finish()
    }

    private func refreshEntitlements() async {
        var current: Set<PurchaseProductID> = []
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case let .verified(transaction) = result,
                  transaction.revocationDate == nil,
                  let id = PurchaseProductID(rawValue: transaction.productID),
                  !id.isConsumable else { continue }
            current.insert(id)
            if let gems = PurchaseCatalog.gemGrant[id] {
                PlayerWallet.shared.grantStoreGems(gems, transactionID: transaction.id)
            }
        }
        entitlements = current
    }
}
