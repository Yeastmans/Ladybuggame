import SpriteKit

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

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.10, green: 0.08, blue: 0.18, alpha: 1.0)
        showTab(.colors)
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

        for node in nodes {
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
        } else if GameScene.gemCount >= item.price {
            // Buy
            GameScene.gemCount -= item.price
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
