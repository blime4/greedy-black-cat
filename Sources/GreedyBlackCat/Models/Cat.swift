import Foundation

struct Cat {
    var body: [Position]
    var direction: Direction

    init(startPosition: Position, startLength: Int = 3, direction: Direction = .right) {
        self.direction = direction
        var initialBody: [Position] = []
        for i in 0..<startLength {
            let offset = direction.opposite.offset
            let pos = Position(
                x: startPosition.x + offset.x * i,
                y: startPosition.y + offset.y * i
            )
            initialBody.append(pos)
        }
        self.body = initialBody
    }

    var head: Position {
        return body.first ?? Position(x: 0, y: 0)
    }

    var length: Int {
        return body.count
    }

    mutating func move(to position: Position, grow: Bool = false) {
        body.insert(position, at: 0)
        if !grow {
            body.removeLast()
        }
    }

    mutating func changeDirection(_ newDirection: Direction) {
        // Prevent 180-degree turns
        guard newDirection != direction.opposite else {
            return
        }
        direction = newDirection
    }

    func checkSelfCollision() -> Bool {
        guard body.count > 1 else { return false }
        let head = body[0]
        return body[1...].contains(head)
    }

    func checkWallCollision(gridWidth: Int, gridHeight: Int) -> Bool {
        return !head.isInBounds(width: gridWidth, height: gridHeight)
    }
}
