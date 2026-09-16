import SpriteKit
import UIKit

extension SKScene {
    /// Convert UIKit's safe area into the scene's coordinate space.
    var safeContentFrame: CGRect {
        guard let view else { return frame.insetBy(dx: 16, dy: 12) }
        let safe = view.bounds.inset(by: view.safeAreaInsets).insetBy(dx: 14, dy: 10)
        let a = convertPoint(fromView: CGPoint(x: safe.minX, y: safe.maxY))
        let b = convertPoint(fromView: CGPoint(x: safe.maxX, y: safe.minY))
        return CGRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(b.x - a.x), height: abs(b.y - a.y))
    }
}

/// Shared navigation and accessible, release-on-touch buttons for non-game screens.
class GameScreenScene: SKScene {
    private var pressedButton: SKNode?
    private var ready = false

    override func didMove(to view: SKView) {
        ready = true
        rebuild()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        if ready { rebuild() }
    }

    func rebuild() { }
    func activate(_ name: String) { }

    func show(_ scene: SKScene) {
        scene.scaleMode = .resizeFill
        view?.presentScene(scene, transition: .fade(withDuration: GameSettings.reducedEffects ? 0 : 0.25))
    }

    @discardableResult
    func label(_ text: String, at point: CGPoint, fontSize: CGFloat = 16,
               color: SKColor = .white, width: CGFloat? = nil,
               parent: SKNode? = nil) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        node.text = text
        node.fontSize = fontSize
        node.fontColor = color
        node.verticalAlignmentMode = .center
        node.position = point
        node.zPosition = 2
        if let width {
            node.preferredMaxLayoutWidth = width
            node.numberOfLines = 0
        }
        (parent ?? self).addChild(node)
        return node
    }

    @discardableResult
    func button(_ text: String, name: String, at point: CGPoint, width: CGFloat = 120,
                height: CGFloat = 46, color: SKColor = GameUITheme.violet,
                parent: SKNode? = nil) -> SKShapeNode {
        let node = GameUITheme.makeButton(title: text, name: name,
            size: CGSize(width: width, height: height), color: color, fontSize: 15)
        node.position = point
        node.zPosition = 5
        node.userData = ["action": name]
        node.isAccessibilityElement = true
        node.accessibilityLabel = text
        node.accessibilityTraits = .button
        node.onActivate = { [weak self] in
            GameSettings.feedback()
            self?.activate(name)
        }
        (parent ?? self).addChild(node)
        return node
    }

    private func button(at point: CGPoint) -> SKNode? {
        for hit in nodes(at: point) {
            var candidate: SKNode? = hit
            while let node = candidate, node !== self {
                if node.userData?["action"] is String { return node }
                candidate = node.parent
            }
        }
        return nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard pressedButton == nil, let touch = touches.first else { return }
        pressedButton = button(at: touch.location(in: self))
        pressedButton?.alpha = 0.72
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { pressedButton?.alpha = 1; pressedButton = nil }
        guard let pressed = pressedButton, let touch = touches.first,
              button(at: touch.location(in: self)) === pressed,
              let action = pressed.userData?["action"] as? String else { return }
        GameSettings.feedback()
        activate(action)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressedButton?.alpha = 1
        pressedButton = nil
    }
}
