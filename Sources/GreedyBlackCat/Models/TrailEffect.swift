import Foundation
import SwiftUI

struct TrailPoint: Identifiable {
    let id = UUID()
    let position: Position
    let alpha: Double
    let createdAt: Date
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
        // Guard against invalid decay rate
        guard decayRate > 0 else { return points }

        let now = Date()
        points = points.filter { point in
            now.timeIntervalSince(point.createdAt) < decayRate
        }
        return points
    }

    mutating func clear() {
        points.removeAll()
    }
}
