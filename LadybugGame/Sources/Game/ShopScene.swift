import SpriteKit
import StoreKit

class ShopScene: SKScene {

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
        // Colors
        // === COLORS (16) ===
        ShopItem(id: "color_red", displayName: "Classic Red", price: 0, tab: .colors, color: UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "color_pink", displayName: "Pink", price: 6, tab: .colors, color: UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1), isSparkly: false),
        ShopItem(id: "color_purple", displayName: "Purple", price: 6, tab: .colors, color: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), isSparkly: false),
        ShopItem(id: "color_gold", displayName: "Gold", price: 12, tab: .colors, color: UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "color_silver", displayName: "Silver", price: 12, tab: .colors, color: UIColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1), isSparkly: false),
        ShopItem(id: "color_blue", displayName: "Blue", price: 6, tab: .colors, color: UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "color_magenta", displayName: "Magenta", price: 12, tab: .colors, color: UIColor(red: 0.85, green: 0.15, blue: 0.55, alpha: 1), isSparkly: false),
        ShopItem(id: "color_lime", displayName: "Lime", price: 8, tab: .colors, color: UIColor(red: 0.45, green: 0.85, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "color_orange", displayName: "Orange", price: 8, tab: .colors, color: UIColor(red: 0.95, green: 0.55, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "color_teal", displayName: "Teal", price: 10, tab: .colors, color: UIColor(red: 0.15, green: 0.75, blue: 0.70, alpha: 1), isSparkly: false),
        ShopItem(id: "color_black", displayName: "Midnight", price: 15, tab: .colors, color: UIColor(red: 0.12, green: 0.10, blue: 0.18, alpha: 1), isSparkly: false),
        ShopItem(id: "color_white", displayName: "Snow", price: 15, tab: .colors, color: UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "color_sparkpink", displayName: "Sparkly Pink", price: 18, tab: .colors, color: UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1), isSparkly: true),
        ShopItem(id: "color_sparkblue", displayName: "Sparkly Blue", price: 18, tab: .colors, color: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        ShopItem(id: "color_sparkgold", displayName: "Sparkly Gold", price: 24, tab: .colors, color: UIColor(red: 1.0, green: 0.82, blue: 0.25, alpha: 1), isSparkly: true),
        ShopItem(id: "color_sparkpurple", displayName: "Sparkly Purple", price: 24, tab: .colors, color: UIColor(red: 0.70, green: 0.30, blue: 0.95, alpha: 1), isSparkly: true),
        // === HATS (16) ===
        ShopItem(id: "hat_tophat", displayName: "Top Hat", price: 24, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_cap", displayName: "Backwards Cap", price: 18, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_crown", displayName: "Crown", price: 30, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_flower", displayName: "Flower", price: 18, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_wizard", displayName: "Wizard", price: 28, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_pirate", displayName: "Pirate", price: 22, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_chef", displayName: "Chef", price: 20, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_cowboy", displayName: "Cowboy", price: 22, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_beanie", displayName: "Beanie", price: 16, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_halo", displayName: "Halo", price: 35, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_horns", displayName: "Devil Horns", price: 28, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_party", displayName: "Party Hat", price: 14, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_bow", displayName: "Bow", price: 12, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_mushroom", displayName: "Mushroom", price: 20, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_leaf", displayName: "Leaf", price: 10, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_gem", displayName: "Gem Crown", price: 50, tab: .hats, color: nil, isSparkly: true),
        // === SHOES (16) ===
        ShopItem(id: "shoe_pink", displayName: "Pink", price: 12, tab: .shoes, color: UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_purple", displayName: "Purple", price: 12, tab: .shoes, color: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_gold", displayName: "Gold", price: 18, tab: .shoes, color: UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_silver", displayName: "Silver", price: 18, tab: .shoes, color: UIColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_blue", displayName: "Blue", price: 12, tab: .shoes, color: UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_magenta", displayName: "Magenta", price: 12, tab: .shoes, color: UIColor(red: 0.85, green: 0.15, blue: 0.55, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_lime", displayName: "Lime", price: 10, tab: .shoes, color: UIColor(red: 0.45, green: 0.85, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_orange", displayName: "Orange", price: 10, tab: .shoes, color: UIColor(red: 0.95, green: 0.55, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_teal", displayName: "Teal", price: 14, tab: .shoes, color: UIColor(red: 0.15, green: 0.75, blue: 0.70, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_black", displayName: "Midnight", price: 16, tab: .shoes, color: UIColor(red: 0.12, green: 0.10, blue: 0.18, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_white", displayName: "Snow", price: 16, tab: .shoes, color: UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_red", displayName: "Red", price: 8, tab: .shoes, color: UIColor(red: 0.85, green: 0.12, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_sparkpink", displayName: "Sparkly Pink", price: 20, tab: .shoes, color: UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_sparkblue", displayName: "Sparkly Blue", price: 20, tab: .shoes, color: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_sparkgold", displayName: "Sparkly Gold", price: 24, tab: .shoes, color: UIColor(red: 1.0, green: 0.82, blue: 0.25, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_sparkpurple", displayName: "Sparkly Purple", price: 24, tab: .shoes, color: UIColor(red: 0.70, green: 0.30, blue: 0.95, alpha: 1), isSparkly: true),
        // === WINGS (16) ===
        ShopItem(id: "wing_white", displayName: "White", price: 8, tab: .wings, color: UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_blue", displayName: "Blue", price: 10, tab: .wings, color: UIColor(red: 0.40, green: 0.60, blue: 0.95, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_pink", displayName: "Pink", price: 10, tab: .wings, color: UIColor(red: 1.0, green: 0.55, blue: 0.70, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_green", displayName: "Green", price: 10, tab: .wings, color: UIColor(red: 0.35, green: 0.80, blue: 0.40, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_gold", displayName: "Gold", price: 14, tab: .wings, color: UIColor(red: 0.95, green: 0.80, blue: 0.30, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_purple", displayName: "Purple", price: 12, tab: .wings, color: UIColor(red: 0.65, green: 0.35, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_orange", displayName: "Orange", price: 10, tab: .wings, color: UIColor(red: 0.95, green: 0.60, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_red", displayName: "Red", price: 12, tab: .wings, color: UIColor(red: 0.90, green: 0.20, blue: 0.15, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_teal", displayName: "Teal", price: 12, tab: .wings, color: UIColor(red: 0.20, green: 0.78, blue: 0.75, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_silver", displayName: "Silver", price: 14, tab: .wings, color: UIColor(red: 0.80, green: 0.82, blue: 0.88, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_black", displayName: "Shadow", price: 18, tab: .wings, color: UIColor(red: 0.15, green: 0.12, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "wing_rainbow", displayName: "Rainbow", price: 30, tab: .wings, color: UIColor(red: 0.90, green: 0.40, blue: 0.60, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_sparkblue", displayName: "Sparkly Blue", price: 22, tab: .wings, color: UIColor(red: 0.30, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_sparkpink", displayName: "Sparkly Pink", price: 22, tab: .wings, color: UIColor(red: 1.0, green: 0.45, blue: 0.75, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_sparkgold", displayName: "Sparkly Gold", price: 28, tab: .wings, color: UIColor(red: 1.0, green: 0.85, blue: 0.30, alpha: 1), isSparkly: true),
        ShopItem(id: "wing_crystal", displayName: "Crystal", price: 35, tab: .wings, color: UIColor(red: 0.70, green: 0.85, blue: 1.0, alpha: 1), isSparkly: true),
        // === SPOTS (16) — unique colors, none matching body colors ===
        ShopItem(id: "spot_default", displayName: "Classic", price: 0, tab: .spots, color: UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_navy", displayName: "Navy", price: 8, tab: .spots, color: UIColor(red: 0.08, green: 0.12, blue: 0.32, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_forest", displayName: "Forest", price: 8, tab: .spots, color: UIColor(red: 0.05, green: 0.28, blue: 0.12, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_maroon", displayName: "Maroon", price: 10, tab: .spots, color: UIColor(red: 0.38, green: 0.05, blue: 0.08, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_charcoal", displayName: "Charcoal", price: 8, tab: .spots, color: UIColor(red: 0.22, green: 0.22, blue: 0.25, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_plum", displayName: "Plum", price: 10, tab: .spots, color: UIColor(red: 0.35, green: 0.10, blue: 0.38, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_bronze", displayName: "Bronze", price: 12, tab: .spots, color: UIColor(red: 0.45, green: 0.30, blue: 0.12, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_crimson", displayName: "Crimson", price: 10, tab: .spots, color: UIColor(red: 0.55, green: 0.02, blue: 0.15, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_olive", displayName: "Olive", price: 8, tab: .spots, color: UIColor(red: 0.30, green: 0.32, blue: 0.08, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_wine", displayName: "Wine", price: 12, tab: .spots, color: UIColor(red: 0.42, green: 0.08, blue: 0.22, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_slate", displayName: "Slate", price: 10, tab: .spots, color: UIColor(red: 0.28, green: 0.30, blue: 0.38, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_cocoa", displayName: "Cocoa", price: 10, tab: .spots, color: UIColor(red: 0.28, green: 0.18, blue: 0.10, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_ivory", displayName: "Ivory", price: 14, tab: .spots, color: UIColor(red: 0.88, green: 0.85, blue: 0.75, alpha: 1), isSparkly: false),
        ShopItem(id: "spot_sparkwhite", displayName: "Sparkly White", price: 22, tab: .spots, color: UIColor(red: 0.92, green: 0.90, blue: 0.95, alpha: 1), isSparkly: true),
        ShopItem(id: "spot_sparkgold", displayName: "Sparkly Gold", price: 24, tab: .spots, color: UIColor(red: 0.72, green: 0.58, blue: 0.15, alpha: 1), isSparkly: true),
        ShopItem(id: "spot_sparkviolet", displayName: "Sparkly Violet", price: 24, tab: .spots, color: UIColor(red: 0.40, green: 0.15, blue: 0.55, alpha: 1), isSparkly: true),
    ]

    // Persistence
    private static let ownedKey = "OwnedShopItems"
    private static let equippedColorKey = "EquippedColor"
    private static let equippedHatKey = "EquippedHat"
    private static let equippedShoesKey = "EquippedShoes"
    private static let equippedWingsKey = "EquippedWings"
    private static let equippedSpotsKey = "EquippedSpots"

    static var ownedItems: [String] {
        get { UserDefaults.standard.stringArray(forKey: ownedKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: ownedKey) }
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
    private var gemLabel: SKLabelNode!
    private var storeStatusLabel: SKLabelNode?
    private var isStoreOperationInProgress = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.10, green: 0.08, blue: 0.18, alpha: 1.0)
        showTab(.colors)
        Task { @MainActor [weak self] in
            await AppServices.shared.purchases.prepare()
            guard let self,
                  self.childNode(withName: "monetizationOverlay") != nil else { return }
            self.showMonetizationStore()
        }
    }

    private func showTab(_ tab: Tab) {
        currentTab = tab
        removeAllChildren()

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Shop"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height - 32)
        title.zPosition = 10
        addChild(title)

        // Back
        let back = SKLabelNode(fontNamed: "AvenirNext-Bold")
        back.text = "< Back"
        back.fontSize = 16
        back.fontColor = SKColor(white: 0.7, alpha: 1)
        back.horizontalAlignmentMode = .left
        back.position = CGPoint(x: 20, y: size.height - 32)
        back.zPosition = 10
        back.name = "back"
        addChild(back)

        // Gem count
        let gemIcon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemIcon.text = "💎"
        gemIcon.fontSize = 14
        gemIcon.horizontalAlignmentMode = .right
        gemIcon.position = CGPoint(x: size.width - 55, y: size.height - 32)
        gemIcon.zPosition = 10
        addChild(gemIcon)

        gemLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemLabel.text = "\(GameScene.gemCount)"
        gemLabel.fontSize = 16
        gemLabel.fontColor = SKColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1.0)
        gemLabel.horizontalAlignmentMode = .right
        gemLabel.position = CGPoint(x: size.width - 20, y: size.height - 32)
        gemLabel.zPosition = 10
        addChild(gemLabel)

        let gemStoreButton = SKShapeNode(rectOf: CGSize(width: 88, height: 24), cornerRadius: 7)
        gemStoreButton.fillColor = SKColor(red: 0.48, green: 0.28, blue: 0.76, alpha: 1)
        gemStoreButton.strokeColor = SKColor(white: 1, alpha: 0.25)
        gemStoreButton.position = CGPoint(x: size.width - 66, y: size.height - 60)
        gemStoreButton.zPosition = 12
        gemStoreButton.name = "openMonetizationStore"
        addChild(gemStoreButton)

        let gemStoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gemStoreLabel.text = "Get Gems"
        gemStoreLabel.fontSize = 11
        gemStoreLabel.fontColor = .white
        gemStoreLabel.verticalAlignmentMode = .center
        gemStoreLabel.name = "openMonetizationStore"
        gemStoreButton.addChild(gemStoreLabel)

        // Tabs
        let tabs: [(Tab, String, SKColor)] = [
            (.colors, "Colors", SKColor(red: 0.75, green: 0.25, blue: 0.25, alpha: 1)),
            (.hats, "Hats", SKColor(red: 0.25, green: 0.55, blue: 0.75, alpha: 1)),
            (.shoes, "Shoes", SKColor(red: 0.55, green: 0.65, blue: 0.25, alpha: 1)),
            (.wings, "Wings", SKColor(red: 0.55, green: 0.35, blue: 0.75, alpha: 1)),
            (.spots, "Spots", SKColor(red: 0.40, green: 0.30, blue: 0.20, alpha: 1)),
        ]
        for (i, (t, label, color)) in tabs.enumerated() {
            let tabBg = SKShapeNode(rectOf: CGSize(width: 58, height: 24), cornerRadius: 6)
            tabBg.fillColor = t == tab ? color : SKColor(white: 0.20, alpha: 1)
            tabBg.strokeColor = .clear
            tabBg.position = CGPoint(x: size.width / 2 + CGFloat(i) * 64 - CGFloat(tabs.count - 1) * 32, y: size.height - 62)
            tabBg.zPosition = 10
            tabBg.name = "tab_\(t.rawValue)"
            addChild(tabBg)
            let tl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            tl.text = label
            tl.fontSize = 12
            tl.fontColor = .white
            tl.verticalAlignmentMode = .center
            tl.name = "tab_\(t.rawValue)"
            tabBg.addChild(tl)
        }

        // Items grid
        let items = ShopScene.allItems.filter { $0.tab == tab }
        let cols = 4
        let cellW: CGFloat = 72
        let cellH: CGFloat = 80
        let gridW = CGFloat(min(cols, items.count)) * cellW
        let startX = (size.width - gridW) / 2 + cellW / 2
        let startY = size.height - 100

        for (i, item) in items.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cellW
            let y = startY - CGFloat(row) * cellH

            // Item icon
            let iconBg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 6)
            let isOwned = ShopScene.isOwned(item.id)
            let isEquipped = ShopScene.isEquipped(item.id)
            iconBg.fillColor = SKColor(white: 0.15, alpha: 1)
            iconBg.strokeColor = isEquipped ? SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1) :
                                 isOwned ? SKColor(white: 0.4, alpha: 1) : SKColor(white: 0.2, alpha: 1)
            iconBg.lineWidth = isEquipped ? 2 : 1
            iconBg.position = CGPoint(x: x, y: y)
            iconBg.zPosition = 5
            iconBg.name = "item_\(item.id)"
            addChild(iconBg)

            // Preview circle (color) or hat icon
            if let c = item.color {
                let preview = SKShapeNode(circleOfRadius: 12)
                preview.fillColor = SKColor(cgColor: c.cgColor)
                preview.strokeColor = .clear
                preview.name = "item_\(item.id)"
                iconBg.addChild(preview)
                if item.isSparkly {
                    let sparkle = SKLabelNode(text: "✦")
                    sparkle.fontSize = 8
                    sparkle.fontColor = .white
                    sparkle.position = CGPoint(x: 8, y: 6)
                    sparkle.name = "item_\(item.id)"
                    iconBg.addChild(sparkle)
                }
            } else {
                // Hat icon text
                let hatEmoji: String
                switch item.id {
                case "hat_tophat": hatEmoji = "🎩"
                case "hat_cap": hatEmoji = "🧢"
                case "hat_crown": hatEmoji = "👑"
                case "hat_flower": hatEmoji = "🌸"
                case "hat_wizard": hatEmoji = "🧙"
                case "hat_pirate": hatEmoji = "🏴‍☠️"
                case "hat_chef": hatEmoji = "👨‍🍳"
                case "hat_cowboy": hatEmoji = "🤠"
                case "hat_beanie": hatEmoji = "🧶"
                case "hat_halo": hatEmoji = "😇"
                case "hat_horns": hatEmoji = "😈"
                case "hat_party": hatEmoji = "🎉"
                case "hat_bow": hatEmoji = "🎀"
                case "hat_mushroom": hatEmoji = "🍄"
                case "hat_leaf": hatEmoji = "🍃"
                case "hat_gem": hatEmoji = "💎"
                default: hatEmoji = "🎭"
                }
                let hl = SKLabelNode(text: hatEmoji)
                hl.fontSize = 20
                hl.verticalAlignmentMode = .center
                hl.name = "item_\(item.id)"
                iconBg.addChild(hl)
            }

            // Name
            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            nameLabel.text = item.displayName
            nameLabel.fontSize = 8
            nameLabel.fontColor = .white
            nameLabel.position = CGPoint(x: x, y: y - 24)
            nameLabel.zPosition = 5
            addChild(nameLabel)

            // Price / status
            let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            if isEquipped {
                statusLabel.text = "Equipped"
                statusLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
            } else if isOwned {
                statusLabel.text = "Owned"
                statusLabel.fontColor = SKColor(white: 0.6, alpha: 1)
            } else {
                statusLabel.text = "💎\(item.price)"
                statusLabel.fontColor = SKColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1)
            }
            statusLabel.fontSize = 8
            statusLabel.position = CGPoint(x: x, y: y - 33)
            statusLabel.zPosition = 5
            statusLabel.name = "item_\(item.id)"
            addChild(statusLabel)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let nodes = self.nodes(at: touch.location(in: self))

        if childNode(withName: "monetizationOverlay") != nil {
            for node in nodes {
                guard let name = node.name else { continue }
                if name == "closeMonetizationStore" {
                    if !isStoreOperationInProgress {
                        childNode(withName: "monetizationOverlay")?.removeFromParent()
                    }
                    return
                }
                if name == "watchDailyBonus" {
                    beginDailyBonusAd()
                    return
                }
                if name == "restorePurchases" {
                    beginRestorePurchases()
                    return
                }
                if name.hasPrefix("purchase_") {
                    let rawID = String(name.dropFirst("purchase_".count))
                    if let productID = PurchaseProductID(rawValue: rawID) {
                        beginPurchase(productID)
                    }
                    return
                }
            }
            return
        }

        for node in nodes {
            if node.name == "openMonetizationStore" {
                showMonetizationStore()
                return
            }
            if node.name == "back" {
                let menu = MenuScene(size: size)
                menu.scaleMode = scaleMode
                view?.presentScene(menu, transition: .fade(withDuration: 0.3))
                return
            }
            if let name = node.name, name.hasPrefix("tab_") {
                let tabName = String(name.dropFirst(4))
                if let tab = Tab(rawValue: tabName) { showTab(tab) }
                return
            }
            if let name = node.name, name.hasPrefix("item_") {
                let itemId = String(name.dropFirst(5))
                handleItemTap(itemId)
                return
            }
        }
    }

    private var storePresenter: UIViewController? {
        var presenter = view?.window?.rootViewController
        while let presented = presenter?.presentedViewController {
            presenter = presented
        }
        return presenter
    }

    private func showMonetizationStore(status: String? = nil) {
        childNode(withName: "monetizationOverlay")?.removeFromParent()

        let overlay = SKNode()
        overlay.name = "monetizationOverlay"
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 200
        addChild(overlay)

        let shade = SKShapeNode(rectOf: size)
        shade.fillColor = SKColor(white: 0, alpha: 0.82)
        shade.strokeColor = .clear
        shade.name = "monetizationBackdrop"
        overlay.addChild(shade)

        let panelWidth = min(size.width - 32, 610)
        let panelHeight = min(size.height - 24, 340)
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 18)
        panel.fillColor = SKColor(red: 0.10, green: 0.08, blue: 0.18, alpha: 0.98)
        panel.strokeColor = SKColor(red: 0.64, green: 0.44, blue: 0.96, alpha: 0.9)
        panel.lineWidth = 2
        panel.name = "monetizationPanel"
        overlay.addChild(panel)

        let halfHeight = panelHeight / 2
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Gem Store"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: halfHeight - 38)
        panel.addChild(title)

        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.text = "×"
        close.fontSize = 28
        close.fontColor = SKColor(white: 0.75, alpha: 1)
        close.position = CGPoint(x: panelWidth / 2 - 25, y: halfHeight - 34)
        close.name = "closeMonetizationStore"
        panel.addChild(close)

        let testNotice = SKLabelNode(fontNamed: "AvenirNext-Bold")
        testNotice.text = MonetizationConfiguration.usesSimulatedAds
            ? "TEST ADS ON  •  blank screen for 5 seconds"
            : "Optional rewards • purchases never expire"
        testNotice.fontSize = 10
        testNotice.fontColor = MonetizationConfiguration.usesSimulatedAds
            ? SKColor(red: 1.0, green: 0.76, blue: 0.20, alpha: 1)
            : SKColor(white: 0.68, alpha: 1)
        testNotice.position = CGPoint(x: 0, y: halfHeight - 58)
        panel.addChild(testNotice)

        let columnX = panelWidth * 0.24
        let buttonWidth = panelWidth * 0.43
        addStoreProductButton(
            .starterPack,
            title: "Starter Pack",
            detail: "+80 Gems • one time",
            x: -columnX,
            y: 54,
            width: buttonWidth,
            parent: panel
        )
        addStoreProductButton(
            .gemsSmall,
            title: "Gem Pouch",
            detail: "+50 Gems",
            x: -columnX,
            y: 8,
            width: buttonWidth,
            parent: panel
        )
        addStoreProductButton(
            .gemsMedium,
            title: "Gem Chest",
            detail: "+300 Gems",
            x: -columnX,
            y: -38,
            width: buttonWidth,
            parent: panel
        )
        addStoreProductButton(
            .gemsLarge,
            title: "Gem Vault",
            detail: "+800 Gems",
            x: columnX,
            y: 54,
            width: buttonWidth,
            parent: panel
        )
        addStoreProductButton(
            .removeAds,
            title: "Remove Ads",
            detail: "No interstitial breaks",
            x: columnX,
            y: 8,
            width: buttonWidth,
            parent: panel
        )
        addStoreActionButton(
            title: "Restore Purchases",
            name: "restorePurchases",
            x: columnX,
            y: -38,
            width: buttonWidth,
            color: SKColor(white: 0.25, alpha: 1),
            parent: panel
        )

        let bonusAvailable = MonetizationStateStore.shared.canClaimDailyBonus
            && AppServices.shared.ads.isRewardedReady
        let bonusTitle = bonusAvailable
            ? "\(MonetizationConfiguration.usesSimulatedAds ? "Test Ad" : "Watch Ad")  •  +\(MonetizationStateStore.dailyBonusGems) Gems"
            : "Daily Ad Bonus Claimed"
        addStoreActionButton(
            title: bonusTitle,
            name: "watchDailyBonus",
            x: 0,
            y: -91,
            width: min(270, panelWidth * 0.55),
            color: bonusAvailable
                ? SKColor(red: 0.25, green: 0.64, blue: 0.38, alpha: 1)
                : SKColor(white: 0.22, alpha: 1),
            parent: panel
        )

        let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        statusLabel.text = status ?? "Balance: \(GameScene.gemCount) Gems"
        statusLabel.fontSize = 11
        statusLabel.fontColor = status == nil
            ? SKColor(red: 0.78, green: 0.62, blue: 1.0, alpha: 1)
            : SKColor(white: 0.84, alpha: 1)
        statusLabel.position = CGPoint(x: 0, y: -halfHeight + 13)
        statusLabel.name = "storeStatus"
        panel.addChild(statusLabel)
        storeStatusLabel = statusLabel
    }

    private func addStoreProductButton(
        _ id: PurchaseProductID,
        title: String,
        detail: String,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        parent: SKNode
    ) {
        let isOwned = !id.isConsumable && AppServices.shared.purchases.entitlements.contains(id)
        let product = AppServices.shared.purchases.products[id]
        let price = isOwned ? "Owned" : (product?.displayPrice ?? "Unavailable")
        let name = "purchase_\(id.rawValue)"

        let button = SKShapeNode(rectOf: CGSize(width: width, height: 38), cornerRadius: 8)
        button.fillColor = isOwned
            ? SKColor(red: 0.20, green: 0.48, blue: 0.30, alpha: 1)
            : SKColor(red: 0.22, green: 0.18, blue: 0.34, alpha: 1)
        button.strokeColor = SKColor(white: 1, alpha: 0.16)
        button.position = CGPoint(x: x, y: y)
        button.name = name
        parent.addChild(button)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = title
        titleLabel.fontSize = 12
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: -width / 2 + 10, y: 3)
        titleLabel.name = name
        button.addChild(titleLabel)

        let detailLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        detailLabel.text = detail
        detailLabel.fontSize = 8
        detailLabel.fontColor = SKColor(white: 0.68, alpha: 1)
        detailLabel.horizontalAlignmentMode = .left
        detailLabel.position = CGPoint(x: -width / 2 + 10, y: -10)
        detailLabel.name = name
        button.addChild(detailLabel)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        priceLabel.text = price
        priceLabel.fontSize = product == nil && !isOwned ? 8 : 11
        priceLabel.fontColor = isOwned
            ? SKColor(red: 0.65, green: 1.0, blue: 0.72, alpha: 1)
            : SKColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1)
        priceLabel.horizontalAlignmentMode = .right
        priceLabel.position = CGPoint(x: width / 2 - 10, y: -2)
        priceLabel.name = name
        button.addChild(priceLabel)
    }

    private func addStoreActionButton(
        title: String,
        name: String,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        color: SKColor,
        parent: SKNode
    ) {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: 36), cornerRadius: 8)
        button.fillColor = color
        button.strokeColor = SKColor(white: 1, alpha: 0.16)
        button.position = CGPoint(x: x, y: y)
        button.name = name
        parent.addChild(button)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = title
        label.fontSize = 11
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        button.addChild(label)
    }

    private func beginPurchase(_ id: PurchaseProductID) {
        guard !isStoreOperationInProgress else { return }
        if !id.isConsumable, AppServices.shared.purchases.entitlements.contains(id) {
            showMonetizationStore(status: "Already owned.")
            return
        }

        isStoreOperationInProgress = true
        showMonetizationStore(status: "Contacting the App Store…")
        AppServices.shared.analytics.track(.purchaseStarted(productID: id.rawValue))

        Task { @MainActor [weak self] in
            guard let self else { return }
            if AppServices.shared.purchases.products[id] == nil {
                await AppServices.shared.purchases.prepare()
            }
            let outcome = await AppServices.shared.purchases.purchase(id)
            self.isStoreOperationInProgress = false

            let status: String
            switch outcome {
            case .purchased:
                AppServices.shared.analytics.track(.purchaseCompleted(productID: id.rawValue))
                status = "Purchase complete. Thank you!"
                SoundManager.shared.play("powerup")
            case .pending:
                status = "Purchase pending approval."
            case .cancelled:
                AppServices.shared.analytics.track(.purchaseFailed(productID: id.rawValue, reason: "cancelled"))
                status = "Purchase cancelled."
            case .unavailable:
                AppServices.shared.analytics.track(.purchaseFailed(productID: id.rawValue, reason: "unavailable"))
                status = "This item is not configured in the App Store yet."
            case let .failed(reason):
                AppServices.shared.analytics.track(.purchaseFailed(productID: id.rawValue, reason: reason))
                status = "Purchase failed. Please try again."
            }

            self.gemLabel.text = "\(GameScene.gemCount)"
            self.showMonetizationStore(status: status)
        }
    }

    private func beginRestorePurchases() {
        guard !isStoreOperationInProgress else { return }
        isStoreOperationInProgress = true
        showMonetizationStore(status: "Restoring purchases…")

        Task { @MainActor [weak self] in
            guard let self else { return }
            let restored = await AppServices.shared.purchases.restorePurchases()
            self.isStoreOperationInProgress = false
            AppServices.shared.analytics.track(.purchasesRestored(success: restored))
            self.gemLabel.text = "\(GameScene.gemCount)"
            self.showMonetizationStore(
                status: restored ? "Purchases restored." : "Restore failed. Please try again."
            )
        }
    }

    private func beginDailyBonusAd() {
        guard !isStoreOperationInProgress,
              MonetizationStateStore.shared.canClaimDailyBonus,
              AppServices.shared.ads.isRewardedReady,
              let presenter = storePresenter else { return }

        isStoreOperationInProgress = true
        showMonetizationStore(status: "Opening the test ad…")
        SoundManager.shared.stopMusic()
        AppServices.shared.analytics.track(
            .adStarted(format: "rewarded", placement: RewardedAdPlacement.dailyBonus.rawValue)
        )

        Task { @MainActor [weak self] in
            guard let self else { return }
            let completed = await AppServices.shared.ads.showRewarded(
                from: presenter,
                placement: .dailyBonus
            )
            self.isStoreOperationInProgress = false
            SoundManager.shared.startMusic()

            guard completed else {
                self.showMonetizationStore(status: "Ad not completed. No reward was used.")
                return
            }

            AppServices.shared.analytics.track(
                .adCompleted(format: "rewarded", placement: RewardedAdPlacement.dailyBonus.rawValue)
            )
            let reward = MonetizationStateStore.shared.claimDailyBonusIfAvailable()
            if reward > 0 {
                PlayerWallet.shared.addGems(reward)
                self.gemLabel.text = "\(GameScene.gemCount)"
                SoundManager.shared.play("powerup")
            }
            self.showMonetizationStore(
                status: reward > 0 ? "+\(reward) Gems added!" : "Daily bonus already claimed."
            )
        }
    }
    private func handleItemTap(_ itemId: String) {
        guard let item = ShopScene.allItems.first(where: { $0.id == itemId }) else { return }

        if ShopScene.isEquipped(itemId) {
            // Unequip
            switch item.tab {
            case .colors: ShopScene.equippedColor = nil
            case .hats: ShopScene.equippedHat = nil
            case .shoes: ShopScene.equippedShoes = nil
            case .wings: ShopScene.equippedWings = nil
            case .spots: ShopScene.equippedSpots = nil
            }
            showTab(currentTab)
        } else if ShopScene.isOwned(itemId) {
            // Equip
            switch item.tab {
            case .colors: ShopScene.equippedColor = itemId
            case .hats: ShopScene.equippedHat = itemId
            case .shoes: ShopScene.equippedShoes = itemId
            case .wings: ShopScene.equippedWings = itemId
            case .spots: ShopScene.equippedSpots = itemId
            }
            showTab(currentTab)
        } else if PlayerWallet.shared.spendGems(item.price) {
            // Buy
            AppServices.shared.analytics.track(.economySpend(itemID: itemId, gems: item.price))
            var owned = ShopScene.ownedItems
            owned.append(itemId)
            ShopScene.ownedItems = owned
            // Auto-equip
            switch item.tab {
            case .colors: ShopScene.equippedColor = itemId
            case .hats: ShopScene.equippedHat = itemId
            case .shoes: ShopScene.equippedShoes = itemId
            case .wings: ShopScene.equippedWings = itemId
            case .spots: ShopScene.equippedSpots = itemId
            }
            SoundManager.shared.play("powerup")
            showTab(currentTab)
        } else {
            // Not enough gems — flash the gem label red briefly
            gemLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
            gemLabel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.4),
                SKAction.run { [weak self] in
                    self?.gemLabel.fontColor = SKColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1.0)
                }
            ]))
        }
    }
}
