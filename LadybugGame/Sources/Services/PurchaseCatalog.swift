import Foundation

enum PurchaseProductID: String, CaseIterable, Sendable, Hashable {
    case removeAds = "com.ladybuggame.LadybugGame.remove_ads"
    case starterPack = "com.ladybuggame.LadybugGame.starter_pack"
    case gemsSmall = "com.ladybuggame.LadybugGame.gems_small"
    case gemsMedium = "com.ladybuggame.LadybugGame.gems_medium"
    case gemsLarge = "com.ladybuggame.LadybugGame.gems_large"
    case seasonalCosmetic = "com.ladybuggame.LadybugGame.seasonal_cosmetic"

    var isConsumable: Bool {
        switch self {
        case .gemsSmall, .gemsMedium, .gemsLarge: return true
        case .removeAds, .starterPack, .seasonalCosmetic: return false
        }
    }
}

struct PurchaseCatalog: Sendable {
    static let gemGrant: [PurchaseProductID: Int] = [
        .starterPack: 80,
        .gemsSmall: 50,
        .gemsMedium: 300,
        .gemsLarge: 800,
    ]
}
