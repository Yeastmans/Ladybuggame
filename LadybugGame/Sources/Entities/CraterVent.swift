import SpriteKit

/// A telegraphed Mars hazard. The crater and its temporary blast share one
/// scrolling parent so the warning always stays aligned with the danger.
final class CraterVent: SKNode {
    private let warningRing: SKShapeNode
    private let warningMark: SKLabelNode
    private let plume: SKShapeNode
    private(set) var isErupting = false
    private var hasDamagedPlayer = false

    override init() {
        let crater = SKShapeNode(ellipseOf: CGSize(width: 72, height: 20))
        crater.fillColor = SKColor(red: 0.20, green: 0.07, blue: 0.05, alpha: 1)
        crater.strokeColor = SKColor(red: 0.82, green: 0.28, blue: 0.12, alpha: 1)
        crater.lineWidth = 3
        crater.zPosition = 1

        warningRing = SKShapeNode(ellipseOf: CGSize(width: 84, height: 30))
        warningRing.fillColor = .clear
        warningRing.strokeColor = SKColor(red: 1.0, green: 0.78, blue: 0.18, alpha: 1)
        warningRing.lineWidth = 3
        warningRing.alpha = 0.20
        warningRing.zPosition = 2

        warningMark = SKLabelNode(fontNamed: "AvenirNext-Bold")
        warningMark.text = "!"
        warningMark.fontSize = 28
        warningMark.fontColor = SKColor(red: 1.0, green: 0.82, blue: 0.20, alpha: 1)
        warningMark.position = CGPoint(x: 0, y: 35)
        warningMark.alpha = 0.20
        warningMark.zPosition = 4

        let plumePath = CGMutablePath()
        plumePath.move(to: CGPoint(x: -15, y: 2))
        plumePath.addCurve(to: CGPoint(x: -10, y: 82),
                           control1: CGPoint(x: -28, y: 25),
                           control2: CGPoint(x: -22, y: 62))
        plumePath.addQuadCurve(to: CGPoint(x: 0, y: 104), control: CGPoint(x: -8, y: 96))
        plumePath.addQuadCurve(to: CGPoint(x: 11, y: 82), control: CGPoint(x: 8, y: 96))
        plumePath.addCurve(to: CGPoint(x: 15, y: 2),
                           control1: CGPoint(x: 24, y: 62),
                           control2: CGPoint(x: 28, y: 25))
        plumePath.closeSubpath()
        plume = SKShapeNode(path: plumePath)
        plume.fillColor = SKColor(red: 1.0, green: 0.28, blue: 0.06, alpha: 0.88)
        plume.strokeColor = SKColor(red: 1.0, green: 0.78, blue: 0.16, alpha: 1)
        plume.lineWidth = 3
        plume.glowWidth = 7
        plume.alpha = 0
        plume.yScale = 0.05
        plume.zPosition = 3
        plume.name = "craterVentBlast"

        super.init()
        name = "craterVent"
        zPosition = 3
        addChild(warningRing)
        addChild(crater)
        addChild(plume)
        addChild(warningMark)

        for x in [-28.0, -18.0, 20.0, 30.0] as [CGFloat] {
            let rock = SKShapeNode(circleOfRadius: x.magnitude > 25 ? 5 : 4)
            rock.fillColor = SKColor(red: 0.43, green: 0.14, blue: 0.09, alpha: 1)
            rock.strokeColor = SKColor(red: 0.24, green: 0.07, blue: 0.05, alpha: 1)
            rock.lineWidth = 1
            rock.position = CGPoint(x: x, y: x.magnitude > 25 ? 1 : 4)
            rock.zPosition = 2
            addChild(rock)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startEruption() {
        hasDamagedPlayer = false
        SoundManager.shared.play("hiss")
        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 0.18),
                SKAction.scale(to: 1.10, duration: 0.18),
            ]),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.22, duration: 0.18),
                SKAction.scale(to: 0.94, duration: 0.18),
            ]),
        ])
        warningRing.run(SKAction.repeat(pulse, count: 6), withKey: "ventWarning")
        warningMark.run(SKAction.repeat(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.18),
            SKAction.fadeAlpha(to: 0.20, duration: 0.18),
        ]), count: 6), withKey: "ventWarning")

        let activate = SKAction.run { [weak self] in
            guard let self else { return }
            self.isErupting = true
            let body = SKPhysicsBody(rectangleOf: CGSize(width: 38, height: 96),
                                     center: CGPoint(x: 0, y: 50))
            body.isDynamic = false
            body.categoryBitMask = GameScene.PhysicsCategory.bird
            body.contactTestBitMask = GameScene.PhysicsCategory.ladybug
            body.collisionBitMask = GameScene.PhysicsCategory.none
            self.plume.physicsBody = body
            self.warningRing.strokeColor = SKColor(red: 1.0, green: 0.18, blue: 0.08, alpha: 1)
            SoundManager.shared.play("whoosh")
        }
        let rise = SKAction.group([
            SKAction.fadeAlpha(to: 1.0, duration: 0.14),
            SKAction.scaleY(to: 1.0, duration: 0.14),
        ])
        rise.timingMode = .easeOut
        let fall = SKAction.group([
            SKAction.fadeOut(withDuration: 0.22),
            SKAction.scaleY(to: 0.05, duration: 0.22),
        ])
        fall.timingMode = .easeIn
        let finish = SKAction.run { [weak self] in
            self?.endBlast()
        }
        plume.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            activate,
            rise,
            SKAction.wait(forDuration: 2.4),
            fall,
            finish,
        ]), withKey: "eruption")
    }

    /// Allows at most one unshielded damage event per eruption, then disables
    /// the blast body immediately so leaving and re-entering cannot cost a life.
    func consumeUnshieldedHit() -> Bool {
        guard isErupting, !hasDamagedPlayer else { return false }
        hasDamagedPlayer = true
        plume.physicsBody = nil
        return true
    }

    func deactivate() {
        removeAllActions()
        warningRing.removeAllActions()
        warningMark.removeAllActions()
        plume.removeAllActions()
        endBlast()
        warningRing.alpha = 0.18
        warningMark.alpha = 0
    }

    private func endBlast() {
        isErupting = false
        plume.physicsBody = nil
        plume.alpha = 0
        plume.yScale = 0.05
        warningRing.strokeColor = SKColor(red: 0.55, green: 0.18, blue: 0.10, alpha: 1)
        warningRing.alpha = 0.18
        warningMark.alpha = 0
    }
}
