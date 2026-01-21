import Foundation
import SwiftUI

enum GameMode: String, CaseIterable {
    case classic
    case zen
    case timeAttack
    case hardcore

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .zen: return "Zen Mode"
        case .timeAttack: return "Time Attack"
        case .hardcore: return "Hardcore"
        }
    }

    var description: String {
        switch self {
        case .classic: return "Traditional snake gameplay"
        case .zen: return "No obstacles, relax and play"
        case .timeAttack: return "Get highest score in 2 minutes"
        case .hardcore: return "Maximum obstacles and speed"
        }
    }

    var icon: String {
        switch self {
        case .classic: return "🐱"
        case .zen: return "🧘"
        case .timeAttack: return "⏱️"
        case .hardcore: return "💀"
        }
    }

    var hasObstacles: Bool {
        switch self {
        case .classic, .timeAttack, .hardcore: return true
        case .zen: return false
        }
    }

    var hasPowerUps: Bool {
        switch self {
        case .classic, .zen, .timeAttack: return true
        case .hardcore: return false
        }
    }

    var hasTimeLimit: Bool {
        return self == .timeAttack
    }

    var timeLimit: TimeInterval? {
        if hasTimeLimit {
            return 120.0 // 2 minutes
        }
        return nil
    }

    var speedMultiplier: Double {
        switch self {
        case .classic: return 1.0
        case .zen: return 0.8
        case .timeAttack: return 1.2
        case .hardcore: return 1.5
        }
    }

    var obstacleSpawnRate: Int {
        switch self {
        case .classic: return 50
        case .zen: return 9999 // Never spawn
        case .timeAttack: return 40
        case .hardcore: return 25
        }
    }

    var maxObstacles: Int {
        switch self {
        case .classic: return 5
        case .zen: return 0
        case .timeAttack: return 8
        case .hardcore: return 15
        }
    }
}
