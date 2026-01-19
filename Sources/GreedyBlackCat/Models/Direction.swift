import Foundation

enum Direction: Equatable {
    case up
    case down
    case left
    case right

    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    var offset: Position {
        switch self {
        case .up: return Position(x: 0, y: -1)
        case .down: return Position(x: 0, y: 1)
        case .left: return Position(x: -1, y: 0)
        case .right: return Position(x: 1, y: 0)
        }
    }
}
