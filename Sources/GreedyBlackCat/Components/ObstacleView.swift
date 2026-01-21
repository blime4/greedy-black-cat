import SwiftUI

struct ObstacleView: View {
    let obstacle: Obstacle
    let cellSize: CGFloat

    @State private var rotation: Double = 0
    @State private var spawnScale: CGFloat = 0.0
    @State private var warningPulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Warning pulse before spawn
            if spawnScale < 1.0 {
                Circle()
                    .fill(obstacle.type.color.opacity(0.3))
                    .frame(width: cellSize * 1.2, height: cellSize * 1.2)
                    .scaleEffect(warningPulse)
                    .blur(radius: 8)
            }

            // Background
            Circle()
                .fill(obstacle.type.color)
                .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                .shadow(color: obstacle.type.color.opacity(0.4), radius: 3)

            // Icon
            Text(obstacle.type.icon)
                .font(.system(size: cellSize * 0.4))
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(spawnScale)
        .onAppear {
            // Warning pulse animation before appearing
            withAnimation(.easeOut(duration: 0.4)) {
                warningPulse = 1.5
            }

            // Spawn animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                spawnScale = 1.0
            }

            switch obstacle.type {
            case .ice:
                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            case .spike:
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    rotation = 15
                }
            case .rock:
                break
            }
        }
    }
}
