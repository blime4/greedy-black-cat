import SwiftUI

struct ObstacleView: View {
    let obstacle: Obstacle
    let cellSize: CGFloat

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
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
        .onAppear {
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
