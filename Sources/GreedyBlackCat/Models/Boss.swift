import Foundation
import SwiftUI

enum BossType: String, CaseIterable {
    case giantFish = "Giant Fish"
    case ghostCat = "Ghost Cat"
    case shadowBeast = "Shadow Beast"
    case goldenDragon = "Golden Dragon"

    var emoji: String {
        switch self {
        case .giantFish: return "🐋"
        case .ghostCat: return "👻"
        case .shadowBeast: return "👾"
        case .goldenDragon: return "🐉"
        }
    }

    var color: Color {
        switch self {
        case .giantFish: return Color(hex: "1E90FF")
        case .ghostCat: return Color(hex: "E6E6FA")
        case .shadowBeast: return Color(hex: "4B0082")
        case .goldenDragon: return Color(hex: "FFD700")
        }
    }

    var health: Int {
        switch self {
        case .giantFish: return 5
        case .ghostCat: return 8
        case .shadowBeast: return 10
        case .goldenDragon: return 15
        }
    }

    var spawnScore: Int {
        switch self {
        case .giantFish: return 200
        case .ghostCat: return 500
        case .shadowBeast: return 800
        case .goldenDragon: return 1200
        }
    }

    var ability: BossAbility {
        switch self {
        case .giantFish: return .dashAttack
        case .ghostCat: return .teleport
        case .shadowBeast: return .split
        case .goldenDragon: return .fireBreath
        }
    }
}

enum BossAbility: String {
    case dashAttack = "Dash Attack"
    case teleport = "Teleport"
    case split = "Split"
    case fireBreath = "Fire Breath"
}

struct Boss {
    let type: BossType
    var position: Position
    var health: Int
    var maxHealth: Int
    let id = UUID()
    var isActive: Bool = true

    init(type: BossType, position: Position) {
        self.type = type
        self.position = position
        self.health = type.health
        self.maxHealth = type.health
    }

    var healthPercentage: Double {
        Double(health) / Double(maxHealth)
    }

    var isDefeated: Bool {
        health <= 0
    }
}

struct BossAttack: Identifiable {
    let type: BossType
    let position: Position
    let direction: Direction
    let createdAt: Date
    let id = UUID()

    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > 2.0
    }
}
