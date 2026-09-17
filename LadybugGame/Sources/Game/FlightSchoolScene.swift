import SpriteKit

/// A safe, replayable lesson using the real player movement and generated sprites.
final class FlightSchoolScene: GameScreenScene {
    var startAdventureWhenFinished = false
    private var bug: Ladybug!
    private var caption: SKLabelNode!
    private var progress: SKLabelNode!
    private var snack: SKSpriteNode?
    private var step = 0
    private var heldTime: TimeInterval = 0
    private var lastTime: TimeInterval = 0
    private var target: CGFloat?
    private var dragStart: CGFloat = 0
    private var bugStart: CGFloat = 0
    private var pointer: UITouch?
    private var floorY: CGFloat = 0
    private var lessonFinished = false

    override func rebuild() {
        removeAllChildren()
        step = 0
        heldTime = 0
        lastTime = 0
        target = nil
        pointer = nil
        snack = nil
        lessonFinished = false
        backgroundColor = SKColor(red: 0.62, green: 0.83, blue: 0.92, alpha: 1)
        addChild(GameUITheme.gardenSky(size: size))
        let area = safeContentFrame
        floorY = area.minY + 38
        let ground = SKSpriteNode(color: SKColor(red: 0.28, green: 0.56, blue: 0.29, alpha: 1),
                                  size: CGSize(width: size.width, height: floorY))
        ground.anchorPoint = .zero
        ground.position = .zero
        addChild(ground)
        for index in 0..<7 {
            let hill = SKShapeNode(ellipseOf: CGSize(width: 210, height: 50 + CGFloat(index % 3) * 13))
            hill.fillColor = SKColor(red: 0.43, green: 0.69, blue: 0.38, alpha: 0.55)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: CGFloat(index) * size.width / 5, y: floorY - 8)
            hill.zPosition = -1
            addChild(hill)
        }
        let dimensions = CGSize(width: 48, height: 48)
        bug = Ladybug(walkTexture: TextureGenerator.generateLadybugTexture(size: dimensions),
            blinkTexture: TextureGenerator.generateLadybugBlinkTexture(size: dimensions),
            flyFrames: TextureGenerator.generateLadybugFlyFrames(size: dimensions),
            walkFrames: TextureGenerator.generateLadybugWalkFrames(size: dimensions))
        bug.position = CGPoint(x: area.minX + area.width * 0.23, y: floorY + 24)
        addChild(bug)
        let panel = GameUITheme.makePanel(size: CGSize(width: min(500, area.width - 108), height: 74))
        panel.position = CGPoint(x: area.midX - 45, y: area.maxY - 40)
        panel.zPosition = 30
        addChild(panel)
        progress = label("", at: CGPoint(x: 0, y: 17), fontSize: 11, color: GameUITheme.gold, parent: panel)
        caption = label("", at: CGPoint(x: 0, y: -12), fontSize: 15, width: min(470, area.width - 140), parent: panel)
        button("Skip", name: "skip", at: CGPoint(x: area.maxX - 42, y: area.maxY - 35), width: 84).zPosition = 35
        showInstruction()
    }

    private func showInstruction() {
        let messages = [
            GameSettings.relativeDrag ? "Touch anywhere. Drag upward to lift off."
                : GameSettings.controlOffset > 0 ? "Hold and move your finger to fly. Your bug flies above it!"
                : "Hold a finger above the ladybug to fly. Either side works!",
            "Let go of the screen to float back down and land.",
            "Fly into the green snack. Friendly bugs give you points!",
        ]
        progress.text = "FLIGHT SCHOOL  ·  \(step + 1) / 3"
        caption.text = messages[step]
        UIAccessibility.post(notification: .announcement, argument: messages[step])
    }

    private func advance() {
        heldTime = 0
        GameSettings.feedback()
        SoundManager.shared.play("eat")
        step += 1
        if step >= 3 {
            lessonFinished = true
            GameSettings.completedFlightSchool = true
            target = nil
            bug.targetY = nil
            caption.text = "You're ready. A whole garden is waiting!"
            progress.text = "FLIGHT SCHOOL COMPLETE"
            childNode(withName: "skip")?.removeFromParent()
            button(startAdventureWhenFinished ? "Explore the Meadow" : "Back to the garden", name: "finish",
                   at: CGPoint(x: safeContentFrame.midX, y: safeContentFrame.midY), width: 235,
                   color: GameUITheme.mint).zPosition = 40
            return
        }
        if step == 2 { spawnSnack() }
        showInstruction()
    }

    private func spawnSnack() {
        let node = SKSpriteNode(texture: TextureGenerator.generateAphidWalkFrames(size: CGSize(width: 30, height: 30), color: .green)[0])
        node.position = CGPoint(x: safeContentFrame.maxX - 24, y: floorY + 85)
        addChild(node)
        snack = node
    }

    override func update(_ currentTime: TimeInterval) {
        guard bug != nil else { return }
        defer { lastTime = currentTime }
        guard lastTime > 0 else { return }
        let dt = min(1.0 / 30.0, max(0, currentTime - lastTime))
        bug.targetY = lessonFinished ? nil : target
        bug.updatePhysics(dt: dt, groundY: floorY + 24, ceilingY: safeContentFrame.maxY - 110)
        guard !lessonFinished else { return }
        switch step {
        case 0:
            if bug.position.y > floorY + 58 { heldTime += dt }
            if heldTime > 0.45 { advance() }
        case 1:
            if target == nil, bug.isOnGround { advance() }
        case 2:
            if let snack {
                snack.position.x -= CGFloat(dt) * 90
                if abs(snack.position.x - bug.position.x) < 30, abs(snack.position.y - bug.position.y) < 30 {
                    snack.removeFromParent()
                    self.snack = nil
                    bug.pulse()
                    advance()
                } else if snack.position.x < safeContentFrame.minX {
                    snack.removeFromParent()
                    spawnSnack()
                }
            }
        default: break
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !lessonFinished, pointer == nil, let touch = touches.first else { return }
        let position = touch.location(in: self)
        guard position.y < safeContentFrame.maxY - 82 else { return }
        pointer = touch
        dragStart = position.y
        bugStart = bug.position.y
        target = flightTarget(at: position.y)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pointer, touches.contains(pointer) else { return }
        let y = pointer.location(in: self).y
        target = flightTarget(at: y)
    }

    private func flightTarget(at y: CGFloat) -> CGFloat {
        FlightControls.targetY(fingerY: y, startFingerY: dragStart, startBugY: bugStart,
                              relative: GameSettings.relativeDrag, offset: GameSettings.controlOffset)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let pointer, touches.contains(pointer) { self.pointer = nil; target = nil }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pointer = nil
        target = nil
    }

    override func activate(_ name: String) {
        guard name == "skip" || name == "finish" else { return }
        GameSettings.completedFlightSchool = true
        if startAdventureWhenFinished {
            let game = GameScene(size: size)
            game.campaignStageID = 0
            show(game)
        } else { show(MenuScene(size: size)) }
    }
}
