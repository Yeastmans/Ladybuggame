import SpriteKit

/// Shared visual grammar layered beneath biome-specific art. Food relies on its
/// friendly creature art; threats receive a red warning shadow and exclamation.
enum CreatureReadability {
    static func applyCue(to node: SKNode, category: UInt32) {
        guard category == GameScene.PhysicsCategory.bird else { return }
        applyThreatCue(to: node)
    }

    static func applyThreatCue(to node: SKNode) {
        guard node.childNode(withName: "roleCue") == nil, node.name != "boss" else { return }

        let dimensions: CGSize
        if let sprite = node as? SKSpriteNode {
            dimensions = sprite.size
        } else {
            let frame = node.calculateAccumulatedFrame()
            dimensions = CGSize(width: max(24, frame.width), height: max(24, frame.height))
        }
        addThreatCue(to: node, size: dimensions)
    }

    private static func addThreatCue(to node: SKNode, size: CGSize) {
        let root = SKNode()
        root.name = "roleCue"
        root.zPosition = -4
        node.addChild(root)

        let shadow = SKShapeNode(ellipseOf: CGSize(width: max(26, size.width * 1.12), height: max(10, size.height * 0.38)))
        shadow.fillColor = SKColor(red: 1.0, green: 0.08, blue: 0.18, alpha: 0.16)
        shadow.strokeColor = SKColor(red: 1.0, green: 0.20, blue: 0.26, alpha: 0.62)
        shadow.lineWidth = 1.4
        shadow.position.y = -size.height * 0.24
        root.addChild(shadow)

        let warning = SKLabelNode(fontNamed: "AvenirNext-Bold")
        warning.text = "!"
        warning.fontSize = min(15, max(10, size.height * 0.32))
        warning.fontColor = SKColor(red: 1.0, green: 0.30, blue: 0.25, alpha: 0.9)
        warning.verticalAlignmentMode = .center
        warning.position.y = size.height * 0.58
        warning.zPosition = 3
        root.addChild(warning)

        root.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.45, duration: 0.34),
            SKAction.fadeAlpha(to: 1.0, duration: 0.34),
        ])))
    }
}
