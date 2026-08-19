import SpriteKit

/// Shared visual grammar layered beneath biome-specific art. Snacks use a calm
/// mint halo; threats use a red warning shadow and an exclamation chevron.
enum CreatureReadability {
    static func applyCue(to node: SKNode, category: UInt32) {
        guard node.childNode(withName: "roleCue") == nil, node.name != "boss" else { return }

        let dimensions: CGSize
        if let sprite = node as? SKSpriteNode {
            dimensions = sprite.size
        } else {
            let frame = node.calculateAccumulatedFrame()
            dimensions = CGSize(width: max(24, frame.width), height: max(24, frame.height))
        }

        if category == GameScene.PhysicsCategory.aphid || category == GameScene.PhysicsCategory.fruitfly {
            addFoodCue(to: node, size: dimensions)
        } else if category == GameScene.PhysicsCategory.bird {
            addThreatCue(to: node, size: dimensions)
        }
    }

    private static func addFoodCue(to node: SKNode, size: CGSize) {
        let root = SKNode()
        root.name = "roleCue"
        root.zPosition = -4
        node.addChild(root)

        let halo = SKShapeNode(ellipseOf: CGSize(width: max(22, size.width * 1.05), height: max(10, size.height * 0.42)))
        halo.fillColor = SKColor(red: 0.35, green: 1.0, blue: 0.62, alpha: 0.13)
        halo.strokeColor = SKColor(red: 0.55, green: 1.0, blue: 0.72, alpha: 0.48)
        halo.lineWidth = 1.2
        halo.position.y = -size.height * 0.22
        root.addChild(halo)
        halo.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.12, duration: 0.7), SKAction.fadeAlpha(to: 0.55, duration: 0.7)]),
            SKAction.group([SKAction.scale(to: 0.92, duration: 0.7), SKAction.fadeAlpha(to: 1.0, duration: 0.7)]),
        ])))
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
