import SpriteKit

/// Shared visual language for menus, overlays, HUD cards, and buttons.
enum GameUITheme {
    static let ink = SKColor(red: 0.075, green: 0.055, blue: 0.14, alpha: 1)
    static let panel = SKColor(red: 0.12, green: 0.09, blue: 0.21, alpha: 0.96)
    static let violet = SKColor(red: 0.51, green: 0.30, blue: 0.86, alpha: 1)
    static let gold = SKColor(red: 1.0, green: 0.79, blue: 0.20, alpha: 1)
    static let mint = SKColor(red: 0.30, green: 0.82, blue: 0.52, alpha: 1)
    static let coral = SKColor(red: 0.94, green: 0.25, blue: 0.28, alpha: 1)

    static func makePanel(
        size: CGSize,
        cornerRadius: CGFloat = 14,
        fillColor: SKColor = panel,
        strokeColor: SKColor = SKColor(white: 1, alpha: 0.16),
        name: String? = nil
    ) -> SKShapeNode {
        let panel = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        panel.fillColor = fillColor
        panel.strokeColor = strokeColor
        panel.lineWidth = 1.5
        panel.name = name

        let shadow = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        shadow.fillColor = SKColor(white: 0, alpha: 0.30)
        shadow.strokeColor = .clear
        shadow.position.y = -4
        shadow.zPosition = -2
        panel.addChild(shadow)

        let rim = SKShapeNode(rectOf: CGSize(width: max(1, size.width - 5), height: max(1, size.height - 5)), cornerRadius: max(1, cornerRadius - 2))
        rim.fillColor = .clear
        rim.strokeColor = SKColor(white: 1, alpha: 0.07)
        rim.lineWidth = 1
        rim.zPosition = 1
        panel.addChild(rim)
        return panel
    }

    static func makeButton(
        title: String,
        name: String,
        size: CGSize,
        color: SKColor,
        fontSize: CGFloat = 16
    ) -> SKShapeNode {
        let button = SKShapeNode(rectOf: size, cornerRadius: min(13, size.height * 0.30))
        button.fillColor = color
        button.strokeColor = shifted(color, by: 0.22)
        button.lineWidth = 1.5
        button.name = name

        let shadow = SKShapeNode(rectOf: size, cornerRadius: min(13, size.height * 0.30))
        shadow.fillColor = SKColor(white: 0, alpha: 0.28)
        shadow.strokeColor = .clear
        shadow.position.y = -4
        shadow.zPosition = -2
        button.addChild(shadow)

        let sheen = SKShapeNode(
            rectOf: CGSize(width: max(1, size.width - 7), height: max(4, size.height * 0.32)),
            cornerRadius: min(8, size.height * 0.13)
        )
        sheen.fillColor = SKColor(white: 1, alpha: 0.10)
        sheen.strokeColor = .clear
        sheen.position.y = size.height * 0.22
        sheen.zPosition = 1
        button.addChild(sheen)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = title
        label.fontSize = fontSize
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        label.zPosition = 2
        button.addChild(label)
        return button
    }

    static func addAmbientSparkles(to parent: SKNode, size: CGSize, count: Int = 14, zPosition: CGFloat = -5) {
        guard count > 0 else { return }
        for index in 0..<count {
            let radius = CGFloat(1 + index % 3)
            let sparkle = SKShapeNode(circleOfRadius: radius)
            sparkle.fillColor = index.isMultiple(of: 3)
                ? SKColor(red: 1.0, green: 0.87, blue: 0.38, alpha: 0.55)
                : SKColor(white: 1.0, alpha: 0.42)
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(
                x: CGFloat((index * 83 + 37) % max(1, Int(size.width))),
                y: CGFloat((index * 47 + 71) % max(1, Int(size.height)))
            )
            sparkle.zPosition = zPosition
            parent.addChild(sparkle)

            let rise = CGFloat(7 + index % 8)
            let duration = 1.4 + Double(index % 5) * 0.24
            sparkle.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: 0, y: rise, duration: duration),
                    SKAction.fadeAlpha(to: 0.18, duration: duration),
                ]),
                SKAction.group([
                    SKAction.moveBy(x: 0, y: -rise, duration: duration),
                    SKAction.fadeAlpha(to: 0.75, duration: duration),
                ]),
            ])))
        }
    }

    private static func shifted(_ color: SKColor, by amount: CGFloat) -> SKColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return .white }
        return SKColor(
            red: min(1, max(0, red + amount)),
            green: min(1, max(0, green + amount)),
            blue: min(1, max(0, blue + amount)),
            alpha: alpha
        )
    }
}
