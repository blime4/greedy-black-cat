import Foundation
import SwiftUI

enum ObstacleType {
    case rock
    case spike
    case ice

    var color: Color {
        switch self {
        case .rock: return Color(hex: "696969") // Dim Gray
        case .spike: return Color(hex: "8B0000") // Dark Red
        case .ice: return Color(hex: "87CEEB") // Sky Blue
        }
    }

    var icon: String {
        switch self {
        case .rock: return "🪨"
        case .spike: return "📍"
        case .ice: return "🧊"
        }
    }
}

struct Obstacle: Identifiable {
    let id = UUID()
    let type: ObstacleType
    let position: Position
}
