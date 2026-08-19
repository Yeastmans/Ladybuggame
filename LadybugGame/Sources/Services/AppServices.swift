import Foundation

@MainActor
final class AppServices {
    static let shared = AppServices()

    let analytics: any GameAnalytics
    let purchases: PurchaseService
    var ads: any AdServing

    private init() {
        analytics = LocalGameAnalytics()
        purchases = PurchaseService()
        ads = DisabledAdService()
    }
}