import Foundation

struct Food: Equatable, Identifiable {
    enum FoodType {
        case smallFish   // 10 points
        case mediumFish  // 20 points
        case largeFish   // 50 points

        var points: Int {
            switch self {
            case .smallFish: return 10
            case .mediumFish: return 20
            case .largeFish: return 50
            }
        }

        static func random() -> FoodType {
            let random = Double.random(in: 0...1)
            if random < 0.70 {
                return .smallFish
            } else if random < 0.95 {
                return .mediumFish
            } else {
                return .largeFish
            }
        }
    }

    let position: Position
    let type: FoodType
    let id = UUID()

    init(position: Position, type: FoodType = .random()) {
        self.position = position
        self.type = type
    }

    var points: Int {
        return type.points
    }
}
