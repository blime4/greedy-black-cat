import Foundation
import SwiftUI

struct TrailPoint: Identifiable {
    let id = UUID()
    let position: Position
    let alpha: Double
    let createdAt = Date
}

struct TrailSystem {
    private var points: [TrailPoint] = []
    private let maxPoints: Int = 8

    mutating func addPoint(_ position: Position) {
        points.append(TrailPoint(position: position, alpha: 1.0, createdAt: Date()))
        if points.count > maxPoints {
            points.removeFirst()
        }
    }

    mutating func update(decayRate: Double) -> [TrailPoint] {
        let now = Date()
        points = points.filter { point in
            now.timeIntervalSince(point.createdAt) < 1.0
        }
        return points
    }

    func clear() {
        points.removeAll()
    }
}
