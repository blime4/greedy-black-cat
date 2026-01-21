import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color(hex: "FFF8E7").opacity(0.3),
                    Color(hex: "FFE4CC").opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Floating decorative elements
            ForEach(0..<5, id: \.self) { index in
                FloatingCircle(
                    delay: Double(index) * 0.5,
                    size: CGFloat.random(in: 30...80)
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct FloatingCircle: View {
    let delay: Double
    let size: CGFloat
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.1

    var body: some View {
        Circle()
            .fill(Color.accentColor.opacity(opacity))
            .frame(width: size, height: size)
            .offset(offset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 4 + Double.random(in: 0...2))
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -50...50),
                        height: CGFloat.random(in: -50...50)
                    )
                    opacity = Double.random(in: 0.05...0.15)
                }
            }
    }
}
