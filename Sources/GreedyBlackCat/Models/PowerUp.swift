import Foundation
import SwiftUI

enum PowerUpType: CaseIterable {
    case speedBoost
    case doublePoints
    case invincibility
    case slowMotion

    var duration: TimeInterval {
        switch self {
        case .speedBoost: return 5.0
        case .doublePoints: return 8.0
        case .invincibility: return 3.0
        case .slowMotion: return 6.0
        }
    }

    var color: Color {
        switch self {
        case .speedBoost: return Color(hex: "00CED1") // Dark Turquoise
        case .doublePoints: return Color(hex: "FF69B4") // Hot Pink
        case .invincibility: return Color(hex: "9370DB") // Medium Purple
        case .slowMotion: return Color(hex: "32CD32") // Lime Green
        }
    }

    var icon: String {
        switch self {
        case .speedBoost: return "⚡"
        case .doublePoints: return "✨"
        case .invincibility: return "🛡️"
        case .slowMotion: return "🐌"
        }
    }

    var name: String {
        switch self {
        case .speedBoost: return "Speed Boost"
        case .doublePoints: return "Double Points"
        case .invincibility: return "Invincibility"
        case .slowMotion: return "Slow Motion"
        }
    }

    var spawnChance: Double {
        switch self {
        case .speedBoost: return 0.08
        case .doublePoints: return 0.10
        case .invincibility: return 0.05
        case .slowMotion: return 0.06
        }
    }
}

struct PowerUp: Identifiable {
    let id = UUID()
    let type: PowerUpType
    let position: Position
    let createdAt = Date()

    var isExpired: Bool {
        // Power-ups expire after 10 seconds if not collected
        Date().timeIntervalSince(createdAt) > 10.0
    }
}

struct ActivePowerUp: Identifiable {
    let id = UUID()
    let type: PowerUpType
    let startTime = Date()
    let duration: TimeInterval

    var remainingTime: TimeInterval {
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, duration - elapsed)
    }

    var isActive: Bool {
        remainingTime > 0
    }

    var progress: Double {
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, min(1, elapsed / duration))
    }

    var isExpiringSoon: Bool {
        remainingTime < 3.0 && remainingTime > 0
    }
}
