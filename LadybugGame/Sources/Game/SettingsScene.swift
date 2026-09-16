import SpriteKit

final class SettingsScene: GameScreenScene {
    override func rebuild() {
        removeAllChildren()
        backgroundColor = GameUITheme.ink
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
        case "control": GameSettings.relativeDrag.toggle()
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
}
