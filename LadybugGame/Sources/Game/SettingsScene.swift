import SpriteKit

final class SettingsScene: GameScreenScene {
    private var showingControls = false

    override func rebuild() {
        removeAllChildren()
        backgroundColor = GameUITheme.ink
        if showingControls { buildControls(); return }
        let area = safeContentFrame
        label("Make yourself at home", at: CGPoint(x: area.midX, y: area.maxY - 23), fontSize: 25)
        button("Back", name: "back", at: CGPoint(x: area.minX + 45, y: area.maxY - 23), width: 90)

        let width = min(286, (area.width - 24) / 2)
        let left = area.midX - width / 2 - 8
        let right = area.midX + width / 2 + 8
        let top = area.maxY - 89
        let gap: CGFloat = min(59, (area.height - 128) / 3)
        let entries: [(String, String)] = [
            ("Music: \(GameSettings.music ? "On" : "Off")", "music"),
            ("Sound: \(GameSettings.sound ? "On" : "Off")", "sound"),
            ("Haptics: \(GameSettings.haptics ? "On" : "Off")", "haptics"),
            ("Effects: \(GameSettings.reducedEffects ? "Gentle" : "Full")", "effects"),
            ("Control: \(GameSettings.relativeDrag ? "Relative drag" : "Follow finger")", "control"),
            ("Difficulty: \(MenuScene.difficulty.name)", "difficulty"),
            ("Practice flying", "tutorial"),
            ("How to play", "help"),
        ]
        for (index, entry) in entries.enumerated() {
            button(entry.0, name: entry.1,
                   at: CGPoint(x: index.isMultiple(of: 2) ? left : right, y: top - CGFloat(index / 2) * gap),
                   width: width, height: 46)
        }
    }

    override func activate(_ name: String) {
        switch name {
        case "back": show(MenuScene(size: size)); return
        case "music":
            GameSettings.music.toggle()
            if !GameSettings.music { SoundManager.shared.stopMusic() }
        case "sound": GameSettings.sound.toggle()
        case "haptics": GameSettings.haptics.toggle()
        case "effects": GameSettings.reducedEffects.toggle()
        case "control": showingControls = true
        case "controlBack": showingControls = false
        case "controlMode": GameSettings.relativeDrag.toggle()
        case "controlOffset":
            let values = GameSettings.controlOffsets
            let index = values.firstIndex(of: Int(GameSettings.controlOffset)) ?? 2
            GameSettings.controlOffset = CGFloat(values[(index + 1) % values.count])
        case "difficulty":
            MenuScene.difficulty = MenuScene.Difficulty(rawValue: (MenuScene.difficulty.rawValue + 1) % 3) ?? .easy
        case "tutorial": show(FlightSchoolScene(size: size)); return
        case "help":
            removeAllChildren()
            let area = safeContentFrame
            label("Little wings. Big adventure.", at: CGPoint(x: area.midX, y: area.maxY - 25), fontSize: 26)
            label("Hold and move your finger up or down to fly. Release to land.\n\nEat friendly snacks. Land inside bushes to hide from birds.\n\nBoss arenas let you move in every direction.\n\nStars: finish the stage, reach its score target, take at most one hit.",
                  at: CGPoint(x: area.midX, y: area.midY + 10), fontSize: 16, width: min(530, area.width - 20))
            button("Got it", name: "dismiss", at: CGPoint(x: area.midX, y: area.minY + 24))
            return
        default: break
        }
        rebuild()
    }

    private func buildControls() {
        let area = safeContentFrame
        label("Flight controls", at: CGPoint(x: area.midX, y: area.maxY - 23), fontSize: 25)
        button("Back", name: "controlBack", at: CGPoint(x: area.minX + 45, y: area.maxY - 23), width: 90)
        let width = min(330, area.width - 20)
        button("Control: \(GameSettings.relativeDrag ? "Relative drag" : "Follow finger")", name: "controlMode",
               at: CGPoint(x: area.midX, y: area.maxY - 90), width: width)
        let offset = Int(GameSettings.controlOffset)
        button("Finger offset: \(offset == 0 ? "Off" : "\(offset) pt")", name: "controlOffset",
               at: CGPoint(x: area.midX, y: area.maxY - 147), width: width)
        label(GameSettings.relativeDrag
              ? "Drag anywhere to steer without covering your bug.\nFinger offset applies in boss arenas. Release to land."
              : "Your bug flies above your finger by this amount.\nTap to change the gap. Release to land.",
              at: CGPoint(x: area.midX, y: area.minY + 46), fontSize: 14,
              color: SKColor(white: 0.85, alpha: 1), width: min(470, area.width - 20))
    }
}
