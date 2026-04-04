import SpriteKit

class ShopScene: SKScene {

    enum Tab: String { case colors = "Colors", hats = "Hats", shoes = "Shoes" }

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
        ShopItem(id: "color_pink", displayName: "Pink", price: 1, tab: .colors,
                 color: UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1), isSparkly: false),
        ShopItem(id: "color_purple", displayName: "Purple", price: 1, tab: .colors,
                 color: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), isSparkly: false),
        ShopItem(id: "color_gold", displayName: "Gold", price: 2, tab: .colors,
                 color: UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "color_silver", displayName: "Silver", price: 2, tab: .colors,
                 color: UIColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1), isSparkly: false),
        ShopItem(id: "color_blue", displayName: "Blue", price: 1, tab: .colors,
                 color: UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "color_sparkpink", displayName: "Sparkly Pink", price: 3, tab: .colors,
                 color: UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1), isSparkly: true),
        ShopItem(id: "color_magenta", displayName: "Magenta", price: 2, tab: .colors,
                 color: UIColor(red: 0.85, green: 0.15, blue: 0.55, alpha: 1), isSparkly: false),
        ShopItem(id: "color_sparkblue", displayName: "Sparkly Blue", price: 3, tab: .colors,
                 color: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
        // Hats
        ShopItem(id: "hat_tophat", displayName: "Top Hat", price: 4, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_cap", displayName: "Backwards Cap", price: 3, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_crown", displayName: "Crown", price: 5, tab: .hats, color: nil, isSparkly: false),
        ShopItem(id: "hat_flower", displayName: "Flower", price: 3, tab: .hats, color: nil, isSparkly: false),
        // Shoes (same colors)
        ShopItem(id: "shoe_pink", displayName: "Pink", price: 2, tab: .shoes,
                 color: UIColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_purple", displayName: "Purple", price: 2, tab: .shoes,
                 color: UIColor(red: 0.60, green: 0.30, blue: 0.80, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_gold", displayName: "Gold", price: 3, tab: .shoes,
                 color: UIColor(red: 0.90, green: 0.75, blue: 0.20, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_silver", displayName: "Silver", price: 3, tab: .shoes,
                 color: UIColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_blue", displayName: "Blue", price: 2, tab: .shoes,
                 color: UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_sparkpink", displayName: "Sparkly Pink", price: 3, tab: .shoes,
                 color: UIColor(red: 1.0, green: 0.45, blue: 0.70, alpha: 1), isSparkly: true),
        ShopItem(id: "shoe_magenta", displayName: "Magenta", price: 2, tab: .shoes,
                 color: UIColor(red: 0.85, green: 0.15, blue: 0.55, alpha: 1), isSparkly: false),
        ShopItem(id: "shoe_sparkblue", displayName: "Sparkly Blue", price: 3, tab: .shoes,
                 color: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1), isSparkly: true),
    ]

    // Persistence
    private static let ownedKey = "OwnedShopItems"
    private static let equippedColorKey = "EquippedColor"
    private static let equippedHatKey = "EquippedHat"
    private static let equippedShoesKey = "EquippedShoes"

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

    static func isOwned(_ id: String) -> Bool { ownedItems.contains(id) }
    static func isEquipped(_ id: String) -> Bool {
        id == equippedColor || id == equippedHat || id == equippedShoes
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
        ]
        for (i, (t, label, color)) in tabs.enumerated() {
            let tabBg = SKShapeNode(rectOf: CGSize(width: 80, height: 26), cornerRadius: 6)
            tabBg.fillColor = t == tab ? color : SKColor(white: 0.20, alpha: 1)
            tabBg.strokeColor = .clear
            tabBg.position = CGPoint(x: size.width / 2 + CGFloat(i - 1) * 100, y: size.height - 62)
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
                default: hatEmoji = "?"
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
            }
            showTab(currentTab)
        } else if ShopScene.isOwned(itemId) {
            // Equip
            switch item.tab {
            case .colors: ShopScene.equippedColor = itemId
            case .hats: ShopScene.equippedHat = itemId
            case .shoes: ShopScene.equippedShoes = itemId
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
