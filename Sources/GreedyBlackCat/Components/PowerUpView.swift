import SwiftUI

struct PowerUpView: View {
    let powerUp: PowerUp
    let cellSize: CGFloat

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(powerUp.type.color.opacity(0.5), lineWidth: 2)
                .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                .scaleEffect(pulseScale)

            // Inner circle
            Circle()
                .fill(powerUp.type.color)
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                .shadow(color: powerUp.type.color.opacity(0.5), radius: 5)

            // Icon
            Text(powerUp.type.icon)
                .font(.system(size: cellSize * 0.3))
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.2
            }
        }
    }
}
