import Foundation

struct Position: Equatable, Hashable {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    func applying(_ offset: Position) -> Position {
        return Position(x: x + offset.x, y: y + offset.y)
    }

    func isInBounds(width: Int, height: Int) -> Bool {
        return x >= 0 && x < width && y >= 0 && y < height
    }
}
