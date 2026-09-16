import SpriteKit

/// Cosmetics are earned with play currency. Real-money merchandising is separate.
final class ShopScene: GameScreenScene {
    enum Tab: String { case colors = "Colors", hats = "Hats", shoes = "Shoes", wings = "Wings", spots = "Spots" }

    struct ShopItem {
        let id: String
        let displayName: String
        let price: Int
        let tab: Tab
        let color: UIColor?  // For color/shoe items
        let isSparkly: Bool
    }

    static let allItems: [ShopItem] = [
        // === COLORS (16) ===
        ShopItem(id: "color_red", displayName: "Classic Red", price: 0, tab: .colors, color: UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "color_pink", displayName: "Pink", price: 20, tab: .colors, color: UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1), isSparkly: false),
        ShopItem(id: "color_purple", displayName: "Purple", price: 20, tab: .colors, color: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), isSparkly: false),
        ShopItem(id: "color_gold", displayName: "Gold", price: 50, tab: .colors, color: UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "color_silver", displayName: "Silver", price: 50, tab: .colors, color: UIColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1), isSparkly: false),
        ShopItem(id: "color_blue", displayName: "Blue", price: 20, tab: .colors, color: UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "color_magenta", displayName: "Magenta", price: 35, tab: .colors, color: UIColor(red: 0.85, green: 0.15, blue: 0.55, alpha: 1), isSparkly: false),
        ShopItem(id: "color_lime", displayName: "Lime", price: 20, tab: .colors, color: UIColor(red: 0.45, green: 0.85, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "color_orange", displayName: "Orange", price: 20, tab: .colors, color: UIColor(red: 0.95, green: 0.55, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "color_teal", displayName: "Teal", price: 35, tab: .colors, color: UIColor(red: 0.15, green: 0.75, blue: 0.70, alpha: 1), isSparkly: false),
        ShopItem(id: "color_black", displayName: "Midnight", price: 50, tab: .colors, color: UIColor(red: 0.12, green: 0.10, blue: 0.18, alpha: 1), isSparkly: false),
        ShopItem(id: "color_white", displayName: "Snow", price: 50, tab: .colors, color: UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "color_sparkpink", displayName: "Sparkly Pink", price: 75, tab: .colors, color: UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1), isSparkly: true),
        ShopItem(id: "color_sparkblue", displayName: "Sparkly Blue", price: 75, tab: .colors, color: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        ShopItem(id: "color_sparkgold", displayName: "Sparkly Gold", price: 95, tab: .colors, color: UIColor(red: 1.0, green: 0.82, blue: 0.25, alpha: 1), isSparkly: true),
        ShopItem(id: "color_sparkpurple", displayName: "Sparkly Purple", price: 95, tab: .colors, color: UIColor(red: 0.70, green: 0.30, blue: 0.95, alpha: 1), isSparkly: true),

        // === HATS (16) ===
        ShopItem(id: "hat_tophat", displayName: "Top Hat", price: 45, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_cap", displayName: "Backwards Cap", price: 25, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_crown", displayName: "Crown", price: 80, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_flower", displayName: "Flower", price: 25, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_wizard", displayName: "Wizard", price: 60, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_pirate", displayName: "Pirate", price: 45, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_chef", displayName: "Chef", price: 35, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_cowboy", displayName: "Cowboy", price: 45, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_beanie", displayName: "Beanie", price: 25, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_halo", displayName: "Halo", price: 80, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_horns", displayName: "Devil Horns", price: 60, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_party", displayName: "Party Hat", price: 20, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_bow", displayName: "Bow", price: 20, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_mushroom", displayName: "Mushroom", price: 35, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_leaf", displayName: "Leaf", price: 20, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_gem", displayName: "Gem Crown", price: 120, tab: .hats, color: nil, isSparkly: true),

        // === SHOES (16) ===
        ShopItem(id: "shoe_pink", displayName: "Pink", price: 20, tab: .shoes, color: UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_purple", displayName: "Purple", price: 20, tab: .shoes, color: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_gold", displayName: "Gold", price: 50, tab: .shoes, color: UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_silver", displayName: "Silver", price: 50, tab: .shoes, color: UIColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_blue", displayName: "Blue", price: 20, tab: .shoes, color: UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_magenta", displayName: "Magenta", price: 35, tab: .shoes, color: UIColor(red: 0.85, green: 0.15, blue: 0.55, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_lime", displayName: "Lime", price: 20, tab: .shoes, color: UIColor(red: 0.45, green: 0.85, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_orange", displayName: "Orange", price: 20, tab: .shoes, color: UIColor(red: 0.95, green: 0.55, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_teal", displayName: "Teal", price: 35, tab: .shoes, color: UIColor(red: 0.15, green: 0.75, blue: 0.70, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_black", displayName: "Midnight", price: 50, tab: .shoes, color: UIColor(red: 0.12, green: 0.10, blue: 0.18, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_white", displayName: "Snow", price: 50, tab: .shoes, color: UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_red", displayName: "Red", price: 20, tab: .shoes, color: UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_sparkpink", displayName: "Sparkly Pink", price: 75, tab: .shoes, color: UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_sparkblue", displayName: "Sparkly Blue", price: 75, tab: .shoes, color: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_sparkgold", displayName: "Sparkly Gold", price: 95, tab: .shoes, color: UIColor(red: 1.0, green: 0.82, blue: 0.25, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_sparkpurple", displayName: "Sparkly Purple", price: 95, tab: .shoes, color: UIColor(red: 0.70, green: 0.30, blue: 0.95, alpha: 1), isSparkly: true),

        // === WINGS (16) ===
        ShopItem(id: "wing_white", displayName: "White", price: 50, tab: .wings, color: UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_blue", displayName: "Blue", price: 20, tab: .wings, color: UIColor(red: 0.40, green: 0.60, blue: 0.95, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_pink", displayName: "Pink", price: 20, tab: .wings, color: UIColor(red: 1.0, green: 0.55, blue: 0.70, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_green", displayName: "Green", price: 20, tab: .wings, color: UIColor(red: 0.35, green: 0.80, blue: 0.40, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_gold", displayName: "Gold", price: 50, tab: .wings, color: UIColor(red: 0.95, green: 0.80, blue: 0.30, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_purple", displayName: "Purple", price: 20, tab: .wings, color: UIColor(red: 0.65, green: 0.35, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_orange", displayName: "Orange", price: 20, tab: .wings, color: UIColor(red: 0.95, green: 0.60, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_red", displayName: "Red", price: 20, tab: .wings, color: UIColor(red: 0.90, green: 0.20, blue: 0.15, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_teal", displayName: "Teal", price: 35, tab: .wings, color: UIColor(red: 0.20, green: 0.78, blue: 0.75, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_silver", displayName: "Silver", price: 50, tab: .wings, color: UIColor(red: 0.80, green: 0.82, blue: 0.88, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_black", displayName: "Shadow", price: 50, tab: .wings, color: UIColor(red: 0.15, green: 0.12, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_rainbow", displayName: "Rainbow", price: 120, tab: .wings, color: UIColor(red: 0.90, green: 0.40, blue: 0.60, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_sparkblue", displayName: "Sparkly Blue", price: 75, tab: .wings, color: UIColor(red: 0.30, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_sparkpink", displayName: "Sparkly Pink", price: 75, tab: .wings, color: UIColor(red: 1.0, green: 0.45, blue: 0.75, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_sparkgold", displayName: "Sparkly Gold", price: 95, tab: .wings, color: UIColor(red: 1.0, green: 0.85, blue: 0.30, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_crystal", displayName: "Crystal", price: 120, tab: .wings, color: UIColor(red: 0.70, green: 0.85, blue: 1.0, alpha: 1), isSparkly: true),

        // === SPOTS (16) ===
        ShopItem(id: "spot_default", displayName: "Classic", price: 0, tab: .spots, color: UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_navy", displayName: "Navy", price: 20, tab: .spots, color: UIColor(red: 0.08, green: 0.12, blue: 0.32, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_forest", displayName: "Forest", price: 20, tab: .spots, color: UIColor(red: 0.05, green: 0.28, blue: 0.12, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_maroon", displayName: "Maroon", price: 35, tab: .spots, color: UIColor(red: 0.38, green: 0.05, blue: 0.08, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_charcoal", displayName: "Charcoal", price: 20, tab: .spots, color: UIColor(red: 0.22, green: 0.22, blue: 0.25, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_plum", displayName: "Plum", price: 35, tab: .spots, color: UIColor(red: 0.35, green: 0.10, blue: 0.38, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_bronze", displayName: "Bronze", price: 50, tab: .spots, color: UIColor(red: 0.45, green: 0.30, blue: 0.12, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_crimson", displayName: "Crimson", price: 35, tab: .spots, color: UIColor(red: 0.55, green: 0.02, blue: 0.15, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_olive", displayName: "Olive", price: 20, tab: .spots, color: UIColor(red: 0.30, green: 0.32, blue: 0.08, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_wine", displayName: "Wine", price: 50, tab: .spots, color: UIColor(red: 0.42, green: 0.08, blue: 0.22, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_slate", displayName: "Slate", price: 35, tab: .spots, color: UIColor(red: 0.28, green: 0.30, blue: 0.38, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_cocoa", displayName: "Cocoa", price: 35, tab: .spots, color: UIColor(red: 0.28, green: 0.18, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_ivory", displayName: "Ivory", price: 50, tab: .spots, color: UIColor(red: 0.88, green: 0.85, blue: 0.75, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_sparkwhite", displayName: "Sparkly White", price: 75, tab: .spots, color: UIColor(red: 0.92, green: 0.90, blue: 0.95, alpha: 1), isSparkly: true),
        ShopItem(id: "spot_sparkgold", displayName: "Sparkly Gold", price: 95, tab: .spots, color: UIColor(red: 0.72, green: 0.58, blue: 0.15, alpha: 1), isSparkly: true),
        ShopItem(id: "spot_sparkviolet", displayName: "Sparkly Violet", price: 95, tab: .spots, color: UIColor(red: 0.40, green: 0.15, blue: 0.55, alpha: 1), isSparkly: true),
    ]

    // Persistence
    private static let ownedKey = "OwnedShopItems"
    private static let equippedColorKey = "EquippedColor"
    private static let equippedHatKey = "EquippedHat"
    private static let equippedShoesKey = "EquippedShoes"
    private static let equippedWingsKey = "EquippedWings"
    private static let equippedSpotsKey = "EquippedSpots"

    static var ownedItems: [String] {
        get { PlayerWallet.shared.ownedItems }
        set { PlayerWallet.shared.ownedItems = newValue }
    }
    static var equippedColor: String? {
        get { UserDefaults.standard.string(forKey: equippedColorKey) }
        set { UserDefaults.standard.set(newValue, forKey: equippedColorKey) }
    }
    static var equippedHat: String? {
        get { UserDefaults.standard.string(forKey: equippedHatKey) }
        set { UserDefaults.standard.set(newValue, forKey: equippedHatKey) }
    }
    static var equippedShoes: String? {
        get { UserDefaults.standard.string(forKey: equippedShoesKey) }
        set { UserDefaults.standard.set(newValue, forKey: equippedShoesKey) }
    }
    static var equippedWings: String? {
        get { UserDefaults.standard.string(forKey: equippedWingsKey) }
        set { UserDefaults.standard.set(newValue, forKey: equippedWingsKey) }
    }
    static var equippedSpots: String? {
        get { UserDefaults.standard.string(forKey: equippedSpotsKey) }
        set { UserDefaults.standard.set(newValue, forKey: equippedSpotsKey) }
    }

    static func isOwned(_ id: String) -> Bool { id == "color_red" || id == "spot_default" || ownedItems.contains(id) }
    static func isEquipped(_ id: String) -> Bool {
        id == equippedColor || id == equippedHat || id == equippedShoes || id == equippedWings || id == equippedSpots
    }


    private var currentTab: Tab = .colors
    private var page = 0
    private var selectedItem: ShopItem?
    private var notice: String?

    override func rebuild() {
        removeAllChildren()
        backgroundColor = GameUITheme.ink
        let area = safeContentFrame
        if let selectedItem { buildPreview(selectedItem); return }
        label("Dress up", at: CGPoint(x: area.midX, y: area.maxY - 23), fontSize: 27)
        button("Back", name: "back", at: CGPoint(x: area.minX + 43, y: area.maxY - 23), width: 86)
        label("◆ \(GameScene.gemCount)", at: CGPoint(x: area.maxX - 52, y: area.maxY - 23), fontSize: 17, color: GameUITheme.gold)
        let tabs: [Tab] = [.colors, .hats, .shoes, .wings, .spots]
        let tabWidth = min(110, (area.width - 32) / 5)
        for (index, tab) in tabs.enumerated() {
            button(tab.rawValue, name: "tab_\(tab.rawValue)",
                   at: CGPoint(x: area.midX + CGFloat(index - 2) * (tabWidth + 7), y: area.maxY - 77),
                   width: tabWidth, height: 44, color: tab == currentTab ? GameUITheme.violet : GameUITheme.panel)
        }
        let all = Self.allItems.filter { $0.tab == currentTab }
        let items = Array(all.dropFirst(page * 4).prefix(4))
        let width = min(170, (area.width - 30) / 4)
        let height = min(155, area.height - 174)
        for (index, item) in items.enumerated() {
            let card = button("", name: "item_\(item.id)",
                at: CGPoint(x: area.midX + (CGFloat(index) - CGFloat(items.count - 1) / 2) * (width + 10), y: area.midY - 18),
                width: width, height: height, color: GameUITheme.panel)
            let owned = Self.isOwned(item.id)
            card.accessibilityLabel = "\(item.displayName), \(owned ? "owned" : "\(item.price) gems")"
            if Self.isEquipped(item.id) { card.strokeColor = GameUITheme.gold; card.lineWidth = 2 }
            let preview = CosmeticArt.preview(item: item, size: min(70, height - 46))
            preview.position.y = height / 2 - min(70, height - 46) / 2 - 2
            card.addChild(preview)
            label(item.displayName, at: CGPoint(x: 0, y: -height / 2 + 31), fontSize: 12, width: width - 12, parent: card)
            label(Self.isEquipped(item.id) ? "Wearing" : owned ? "Owned" : "◆ \(item.price)",
                  at: CGPoint(x: 0, y: -height / 2 + 13), fontSize: 11, color: GameUITheme.gold, parent: card)
        }
        let footer = area.minY + 23
        if page > 0 { button("Previous", name: "previous", at: CGPoint(x: area.midX - 155, y: footer), width: 104) }
        label(notice ?? "\(page + 1) / \((all.count + 3) / 4)", at: CGPoint(x: area.midX, y: footer), fontSize: 11, width: 190)
        if (page + 1) * 4 < all.count { button("Next", name: "next", at: CGPoint(x: area.midX + 155, y: footer), width: 104) }
    }

    private func buildPreview(_ item: ShopItem) {
        let area = safeContentFrame
        label(item.displayName, at: CGPoint(x: area.midX, y: area.maxY - 30), fontSize: 27)
        let preview = CosmeticArt.preview(item: item, size: min(124, area.height * 0.39))
        preview.position = CGPoint(x: area.midX - area.width * 0.20, y: area.midY + 8)
        addChild(preview)
        let x = area.midX + area.width * 0.20
        let owned = Self.isOwned(item.id)
        label(owned ? "A look that's all yours" : "◆ \(item.price) gems", at: CGPoint(x: x, y: area.midY + 43),
              fontSize: 20, color: GameUITheme.gold, width: area.width * 0.42)
        label(owned ? "Try it on whenever you like." : "Your balance: \(GameScene.gemCount)\nEarn gems from stages and mastery stars.",
              at: CGPoint(x: x, y: area.midY - 13), fontSize: 14, width: area.width * 0.40)
        let canBuy = GameScene.gemCount >= item.price
        let action = Self.isEquipped(item.id) ? "Take off" : owned ? "Wear it" : canBuy ? "Get it · \(item.price) gems" : "Keep exploring"
        button("Back", name: "cancel", at: CGPoint(x: area.midX - 112, y: area.minY + 30), width: 128)
        button(action, name: "confirm", at: CGPoint(x: area.midX + 87, y: area.minY + 30), width: 230, color: GameUITheme.mint)
    }

    override func activate(_ name: String) {
        notice = nil
        switch name {
        case "back": show(MenuScene(size: size)); return
        case "previous": page = max(0, page - 1)
        case "next": page = min((Self.allItems.filter { $0.tab == currentTab }.count - 1) / 4, page + 1)
        case "cancel": selectedItem = nil
        case "confirm":
            guard let item = selectedItem else { return }
            if Self.isEquipped(item.id) { unequip(item); notice = "Look updated" }
            else if Self.isOwned(item.id) { equip(item); notice = "Now wearing \(item.displayName)" }
            else if PlayerWallet.shared.unlockCosmetic(item.id, price: item.price) {
                equip(item)
                notice = "Now wearing \(item.displayName)"
                AppServices.shared.analytics.track(.economySpend(itemID: item.id, gems: item.price))
                SoundManager.shared.play("powerup")
            } else {
                let menu = MenuScene(size: size); show(menu); return
            }
            selectedItem = nil
        default:
            if name.hasPrefix("tab_"), let tab = Tab(rawValue: String(name.dropFirst(4))) { currentTab = tab; page = 0 }
            if name.hasPrefix("item_") { selectedItem = Self.allItems.first { $0.id == String(name.dropFirst(5)) } }
        }
        rebuild()
    }

    private func equip(_ item: ShopItem) {
        switch item.tab {
        case .colors: ShopScene.equippedColor = item.id
        case .hats: ShopScene.equippedHat = item.id
        case .shoes: ShopScene.equippedShoes = item.id
        case .wings: ShopScene.equippedWings = item.id
        case .spots: ShopScene.equippedSpots = item.id
        }
    }

    private func unequip(_ item: ShopItem) {
        switch item.tab {
        case .colors: ShopScene.equippedColor = nil
        case .hats: ShopScene.equippedHat = nil
        case .shoes: ShopScene.equippedShoes = nil
        case .wings: ShopScene.equippedWings = nil
        case .spots: ShopScene.equippedSpots = nil
        }
    }

}
