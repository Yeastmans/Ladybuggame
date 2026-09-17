import UIKit

/// Local preferences, including finger clearance for direct flight controls.
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
    static let controlOffsets = [0, 40, 60, 80]
    static var controlOffset: CGFloat {
        get {
            let value = (defaults.object(forKey: "SettingsControlOffset") as? Int) ?? 60
            return CGFloat(controlOffsets.contains(value) ? value : 60)
        }
        set { defaults.set(Int(newValue), forKey: "SettingsControlOffset") }
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

/// Relative dragging is anchored at touch-down, so it needs no extra displacement.
enum FlightControls {
    static func targetY(fingerY: CGFloat, startFingerY: CGFloat, startBugY: CGFloat,
                        relative: Bool, offset: CGFloat) -> CGFloat {
        relative ? startBugY + fingerY - startFingerY : fingerY + offset
    }
}
