import SpriteKit

/// VoiceOver activation uses the same action as a released touch.
final class GameActionButton: SKShapeNode {
    var onActivate: (() -> Void)?
    override func accessibilityActivate() -> Bool {
        guard let onActivate else { return false }
        onActivate()
        return true
    }
}

/// Shared visual language for menus, overlays, HUD cards, and buttons.
@MainActor
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
    ) -> GameActionButton {
        let button = GameActionButton(rectOf: size, cornerRadius: min(13, size.height * 0.30))
        button.fillColor = color
        button.strokeColor = shifted(color, by: 0.22)
        button.lineWidth = 1.5
        button.name = name
        button.isAccessibilityElement = true
        button.accessibilityLabel = title
        button.accessibilityTraits = .button

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
        if !title.isEmpty { button.addChild(sheen) }

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = title
        label.fontSize = fontSize
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        label.fontColor = red * 0.2126 + green * 0.7152 + blue * 0.0722 > 0.55 ? ink : .white
        label.verticalAlignmentMode = .center
        label.name = name
        label.zPosition = 2
        button.addChild(label)
        if label.frame.width > size.width - 22 {
            label.fontSize *= (size.width - 22) / label.frame.width
        }
        return button
    }

    /// Smooth, generated sky; no bundled bitmap or visible color bands.
    static func gardenSky(size: CGSize) -> SKSpriteNode {
        sky(size: size, top: UIColor(red: 0.27, green: 0.59, blue: 0.84, alpha: 1),
            bottom: UIColor(red: 0.75, green: 0.91, blue: 0.92, alpha: 1))
    }

    static func habitatSky(size: CGSize, biome: Biome) -> SKSpriteNode {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        biome.skyColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let haze: CGFloat = [.meadowNight, .cave, .space].contains(biome) ? 0.025 : 0.15
        let bottom = UIColor(red: r + (1-r) * haze, green: g + (1-g) * haze, blue: b + (1-b) * haze, alpha: 1)
        return sky(size: size, top: biome.skyColor, bottom: bottom)
    }

    private static func sky(size: CGSize, top: UIColor, bottom: UIColor) -> SKSpriteNode {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 256)).image { renderer in
            let colors = [top.cgColor, bottom.cgColor]
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1]) {
                renderer.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: 256), options: [])
            }
        }
        let node = SKSpriteNode(texture: SKTexture(image: image), size: size)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.zPosition = -20
        return node
    }

    static func addAmbientSparkles(to parent: SKNode, size: CGSize, count: Int = 14, zPosition: CGFloat = -5) {
        guard count > 0, !GameSettings.reducedEffects else { return }
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
