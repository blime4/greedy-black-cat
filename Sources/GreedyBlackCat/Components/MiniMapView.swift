import SwiftUI

struct MiniMapView: View {
    let catPosition: Position
    let foodPosition: Position?
    let powerUps: [PowerUp]
    let obstacles: [Obstacle]
    let boss: Boss?
    let gridWidth: Int
    let gridHeight: Int

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.6))
                .frame(width: 120, height: 120)

            // Grid representation
            GeometryReader { geometry in
                let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(max(gridWidth, gridHeight))

                ZStack {
                    // Grid lines
                    ForEach(0..<gridWidth, id: \.self) { x in
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1)
                            .offset(x: CGFloat(x) * cellSize)
                    }

                    ForEach(0..<gridHeight, id: \.self) { y in
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .offset(y: CGFloat(y) * cellSize)
                    }

                    // Cat position
                    Circle()
                        .fill(Color.green)
                        .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                        .position(
                            x: CGFloat(catPosition.x) * cellSize + cellSize / 2,
                            y: CGFloat(catPosition.y) * cellSize + cellSize / 2
                        )

                    // Food position
                    if let food = foodPosition {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: cellSize * 0.6, height: cellSize * 0.6)
                            .position(
                                x: CGFloat(food.x) * cellSize + cellSize / 2,
                                y: CGFloat(food.y) * cellSize + cellSize / 2
                            )
                            .blinkAnimation()
                    }

                    // Power-ups
                    ForEach(powerUps) { powerUp in
                        Circle()
                            .fill(powerUp.type.color)
                            .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                            .position(
                                x: CGFloat(powerUp.position.x) * cellSize + cellSize / 2,
                                y: CGFloat(powerUp.position.y) * cellSize + cellSize / 2
                            )
                    }

                    // Obstacles
                    ForEach(obstacles) { obstacle in
                        Rectangle()
                            .fill(Color.red.opacity(0.6))
                            .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                            .position(
                                x: CGFloat(obstacle.position.x) * cellSize + cellSize / 2,
                                y: CGFloat(obstacle.position.y) * cellSize + cellSize / 2
                            )
                    }

                    // Boss
                    if let boss = boss {
                        Circle()
                            .fill(boss.type.color)
                            .frame(width: cellSize * 1.2, height: cellSize * 1.2)
                            .position(
                                x: CGFloat(boss.position.x) * cellSize + cellSize / 2,
                                y: CGFloat(boss.position.y) * cellSize + cellSize / 2
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                                    .frame(width: cellSize * 1.4, height: cellSize * 1.4)
                            )
                    }
                }
            }
            .frame(width: 100, height: 100)
            .padding(10)
        }
    }
}

// Blink animation for food on minimap
extension View {
    func blinkAnimation() -> some View {
        self
            .opacity(0.5)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                value: 0.5
            )
    }
}

// Compass/Direction indicator
struct CompassIndicator: View {
    let direction: Direction
    let catPosition: Position
    let foodPosition: Position?

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 60, height: 60)

            // Direction arrow to food
            if let food = foodPosition {
                let angle = angleToFood(
                    from: catPosition,
                    to: food
                )

                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(angle))
            }

            // Center dot
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        }
        .padding(8)
        .background(
            Circle()
                .fill(Color.black.opacity(0.5))
        )
    }

    private func angleToFood(from: Position, to: Position) -> Double {
        let dx = CGFloat(to.x - from.x)
        let dy = CGFloat(to.y - from.y)
        let angle = atan2(dy, dx) * 180 / .pi
        return angle + 90 // Adjust for arrow pointing up by default
    }
}

// Proximity warning system
struct ProximityWarningView: View {
    let distanceToFood: Int
    let maxDistance: Int

    var body: some View {
        if distanceToFood < maxDistance {
            let intensity = 1.0 - (Double(distanceToFood) / Double(maxDistance))

            ZStack {
                // Warning rings
                ForEach(0..<3, id: \.self) { index in
                    let delay = Double(index) * 0.2
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(intensity * 0.8),
                                    Color.orange.opacity(intensity * 0.4)
                                ],
                                startPoint: .center,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 60 + CGFloat(index) * 20, height: 60 + CGFloat(index) * 20)
                        .opacity(intensity)
                        .scaleEffect(intensity)
                }

                // Warning text
                if intensity > 0.7 {
                    Text("!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
