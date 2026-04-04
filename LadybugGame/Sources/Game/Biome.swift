import SpriteKit

/// Defines the current biome and its properties
enum Biome: Int, CaseIterable {
    case meadowDay = 0
    case meadowNight = 1
    case desert = 2
    case snow = 3
    case jungle = 4
    case cave = 5

    var name: String {
        switch self {
        case .meadowDay: return "Meadow"
        case .meadowNight: return "Nightfall"
        case .desert: return "Desert"
        case .snow: return "Tundra"
        case .jungle: return "Jungle"
        case .cave: return "Cave"
        }
    }

    var scoreThreshold: Int {
        switch self {
        case .meadowDay: return 0
        case .meadowNight: return 1000
        case .desert: return 2000
        case .snow: return 3000
        case .jungle: return 4000
        case .cave: return 5000
        }
    }

    var skyColor: SKColor {
        switch self {
        case .meadowDay: return SKColor(red: 0.55, green: 0.80, blue: 0.95, alpha: 1.0)
        case .meadowNight: return SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        case .desert: return SKColor(red: 0.62, green: 0.18, blue: 0.05, alpha: 1.0)
        case .snow: return SKColor(red: 0.78, green: 0.85, blue: 0.92, alpha: 1.0)
        case .jungle: return SKColor(red: 0.30, green: 0.65, blue: 0.40, alpha: 1.0)
        case .cave: return SKColor(red: 0.08, green: 0.06, blue: 0.10, alpha: 1.0)
        }
    }

    var groundColor: SKColor {
        switch self {
        case .meadowDay: return SKColor(red: 0.42, green: 0.68, blue: 0.28, alpha: 1.0)
        case .meadowNight: return SKColor(red: 0.18, green: 0.32, blue: 0.12, alpha: 1.0)
        case .desert: return SKColor(red: 0.85, green: 0.72, blue: 0.45, alpha: 1.0)
        case .snow: return SKColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
        case .jungle: return SKColor(red: 0.25, green: 0.50, blue: 0.18, alpha: 1.0)
        case .cave: return SKColor(red: 0.35, green: 0.30, blue: 0.28, alpha: 1.0)
        }
    }

    var dirtColor: SKColor {
        switch self {
        case .meadowDay: return SKColor(red: 0.50, green: 0.35, blue: 0.18, alpha: 1.0)
        case .meadowNight: return SKColor(red: 0.25, green: 0.18, blue: 0.08, alpha: 1.0)
        case .desert: return SKColor(red: 0.75, green: 0.60, blue: 0.35, alpha: 1.0)
        case .snow: return SKColor(red: 0.55, green: 0.50, blue: 0.45, alpha: 1.0)
        case .jungle: return SKColor(red: 0.35, green: 0.25, blue: 0.10, alpha: 1.0)
        case .cave: return SKColor(red: 0.25, green: 0.20, blue: 0.18, alpha: 1.0)
        }
    }

    var grassLineColor: SKColor {
        switch self {
        case .meadowDay: return SKColor(red: 0.32, green: 0.55, blue: 0.20, alpha: 1.0)
        case .meadowNight: return SKColor(red: 0.15, green: 0.28, blue: 0.10, alpha: 1.0)
        case .desert: return SKColor(red: 0.78, green: 0.65, blue: 0.38, alpha: 1.0)
        case .snow: return SKColor(red: 0.82, green: 0.85, blue: 0.90, alpha: 1.0)
        case .jungle: return SKColor(red: 0.20, green: 0.42, blue: 0.14, alpha: 1.0)
        case .cave: return SKColor(red: 0.30, green: 0.26, blue: 0.24, alpha: 1.0)
        }
    }

    var ceilingColor: SKColor {
        switch self {
        case .cave: return SKColor(red: 0.22, green: 0.18, blue: 0.16, alpha: 1.0)
        default: return .clear
        }
    }

    static func biome(for score: Int) -> Biome {
        for b in allCases.reversed() {
            if score >= b.scoreThreshold { return b }
        }
        return .meadowDay
    }
}
