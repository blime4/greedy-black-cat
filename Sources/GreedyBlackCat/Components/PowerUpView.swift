import SwiftUI

struct PowerUpView: View {
    let powerUp: PowerUp
    let cellSize: CGFloat

    @State private var pulseScale: CGFloat = 1.0
    @State private var spawnScale: CGFloat = 0.0
    @State private var rotation: Double = 0
    @State private var magneticPulse: CGFloat = 0

    var body: some View {
        ZStack {
            // Magnetic field rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                powerUp.type.color.opacity(0.6 - Double(index) * 0.2),
                                powerUp.type.color.opacity(0.1)
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: cellSize * (0.8 + magneticPulse + CGFloat(index) * 0.2), height: cellSize * (0.8 + magneticPulse + CGFloat(index) * 0.2))
                    .rotationEffect(.degrees(rotation + Double(index * 30)))
                    .opacity(1.0 - magneticPulse)
            }

            // Orbiting particles
            ForEach(0..<6, id: \.self) { index in
                let angle = Double(index) * 60 + rotation
                Circle()
                    .fill(powerUp.type.color.opacity(0.8))
                    .frame(width: cellSize * 0.08, height: cellSize * 0.08)
                    .offset(
                        x: cos(angle * .pi / 180) * cellSize * 0.5,
                        y: sin(angle * .pi / 180) * cellSize * 0.5
                    )
            }

            // Outer glow ring
            Circle()
                .stroke(powerUp.type.color.opacity(0.5), lineWidth: 2)
                .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                .scaleEffect(pulseScale)

            // Inner circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [powerUp.type.color, powerUp.type.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                .shadow(color: powerUp.type.color.opacity(0.5), radius: 5)

            // Icon
            Text(powerUp.type.icon)
                .font(.system(size: cellSize * 0.3))
        }
        .scaleEffect(spawnScale)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.2
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                spawnScale = 1.0
            }
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(
                Animation.easeOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                magneticPulse = 0.5
            }
        }
    }
}
