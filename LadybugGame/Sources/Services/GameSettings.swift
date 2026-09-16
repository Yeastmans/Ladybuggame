import UIKit

/// Local preferences. Defaults preserve existing flight controls and saved difficulty.
@MainActor
enum GameSettings {
    private static let defaults = UserDefaults.standard
    static var music: Bool {
        get { (defaults.object(forKey: "SettingsMusic") as? Bool) ?? true }
        set { defaults.set(newValue, forKey: "SettingsMusic") }
    }
    static var sound: Bool {
        get { (defaults.object(forKey: "SettingsSound") as? Bool) ?? true }
        set { defaults.set(newValue, forKey: "SettingsSound") }
    }
    static var haptics: Bool {
        get { (defaults.object(forKey: "SettingsHaptics") as? Bool) ?? true }
        set { defaults.set(newValue, forKey: "SettingsHaptics") }
    }
    static var reducedEffects: Bool {
        get { UIAccessibility.isReduceMotionEnabled || defaults.bool(forKey: "SettingsReducedEffects") }
        set { defaults.set(newValue, forKey: "SettingsReducedEffects") }
    }
    static var relativeDrag: Bool {
        get { defaults.bool(forKey: "SettingsRelativeDrag") }
        set { defaults.set(newValue, forKey: "SettingsRelativeDrag") }
    }
    static var completedFlightSchool: Bool {
        get { defaults.bool(forKey: "FlightSchoolCompletedV1") }
        set { defaults.set(newValue, forKey: "FlightSchoolCompletedV1") }
    }

    static func feedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard haptics else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
