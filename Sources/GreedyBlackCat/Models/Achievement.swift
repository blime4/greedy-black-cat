import Foundation
import SwiftUI

enum Achievement: String, CaseIterable {
    case firstCatch
    case comboStarter
    case speedDemon
    case collector
    case survivor
    case centurion
    case perfectionist
    case dashMaster

    var name: String {
        switch self {
        case .firstCatch: return "First Catch"
        case .comboStarter: return "Combo Starter"
        case .speedDemon: return "Speed Demon"
        case .collector: return "Collector"
        case .survivor: return "Survivor"
        case .centurion: return "Centurion"
        case .perfectionist: return "Perfectionist"
        case .dashMaster: return "Dash Master"
        }
    }

    var description: String {
        switch self {
        case .firstCatch: return "Catch your first fish"
        case .comboStarter: return "Reach a 3x combo"
        case .speedDemon: return "Score 100 points in Time Attack"
        case .collector: return "Collect 10 power-ups"
        case .survivor: return "Reach a length of 20"
        case .centurion: return "Score 100 points in any mode"
        case .perfectionist: return "Reach 5x combo"
        case .dashMaster: return "Use dash 10 times"
        }
    }

    var icon: String {
        switch self {
        case .firstCatch: return "🐟"
        case .comboStarter: return "🔥"
        case .speedDemon: return "⚡"
        case .collector: return "⭐"
        case .survivor: return "💪"
        case .centurion: return "💯"
        case .perfectionist: return "👑"
        case .dashMaster: return "💨"
        }
    }

    func isUnlocked(stats: GameStats) -> Bool {
        switch self {
        case .firstCatch:
            return stats.totalFoodEaten >= 1
        case .comboStarter:
            return stats.maxCombo >= 3
        case .speedDemon:
            return stats.timeAttackHighScore >= 100
        case .collector:
            return stats.totalPowerUpsCollected >= 10
        case .survivor:
            return stats.maxLength >= 20
        case .centurion:
            return stats.totalHighScore >= 100
        case .perfectionist:
            return stats.maxCombo >= 5
        case .dashMaster:
            return stats.totalDashesUsed >= 10
        }
    }
}

struct GameStats: Codable {
    var totalFoodEaten: Int = 0
    var totalPowerUpsCollected: Int = 0
    var totalDashesUsed: Int = 0
    var maxCombo: Int = 0
    var maxLength: Int = 0
    var totalHighScore: Int = 0
    var timeAttackHighScore: Int = 0
    var gamesPlayed: Int = 0

    // Persistence keys
    private static let key = "GreedyBlackCatGameStats"

    static func load() -> GameStats {
        guard let data = UserDefaults.standard.data(forKey: key),
              let stats = try? JSONDecoder().decode(GameStats.self, from: data) else {
            return GameStats()
        }
        return stats
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: GameStats.key)
        }
    }

    mutating func updateFromGame(score: Int, foodEaten: Int, powerUpsCollected: Int, dashesUsed: Int, comboCount: Int, length: Int, gameMode: GameMode) {
        gamesPlayed += 1
        totalFoodEaten += foodEaten
        totalPowerUpsCollected += powerUpsCollected
        totalDashesUsed += dashesUsed
        maxCombo = max(maxCombo, comboCount)
        maxLength = max(maxCombo, length)

        // Update high score for mode
        let modeKey = "GreedyBlackCatHighScore_\(gameMode.rawValue)"
        let currentHighScore = UserDefaults.standard.integer(forKey: modeKey)
        if score > currentHighScore {
            totalHighScore += score - currentHighScore
            if gameMode == .timeAttack {
                timeAttackHighScore = score
            }
        }

        save()
    }
}
