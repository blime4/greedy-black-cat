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

            // Ambient floating particles - larger circles
            ForEach(0..<5, id: \.self) { index in
                FloatingCircle(
                    delay: Double(index) * 0.5,
                    size: CGFloat.random(in: 30...80)
                )
            }

            // Small sparkles scattered throughout
            ForEach(0..<12, id: \.self) { index in
                AmbientSparkle(
                    delay: Double(index) * 0.3,
                    size: CGFloat.random(in: 3...8),
                    duration: Double.random(in: 2...4)
                )
            }

            // Floating geometric shapes
            ForEach(0..<3, id: \.self) { index in
                FloatingShape(
                    delay: Double(index) * 0.7,
                    size: CGFloat.random(in: 20...40),
                    shapeType: index % 2 == 0 ? "circle" : "diamond"
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

// Small ambient sparkle that fades in and out
struct AmbientSparkle: View {
    let delay: Double
    let size: CGFloat
    let duration: Double

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var position: CGPoint = .zero

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundColor(Color.yellow.opacity(opacity))
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                // Random initial position
                position = CGPoint(
                    x: CGFloat.random(in: 50...300),
                    y: CGFloat.random(in: 50...800)
                )

                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    opacity = Double.random(in: 0.3...0.8)
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

// Floating geometric shape with rotation
struct FloatingShape: View {
    let delay: Double
    let size: CGFloat
    let shapeType: String

    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.05
    @State private var rotation: Double = 0

    var body: some View {
        Group {
            if shapeType == "circle" {
                Circle()
                    .fill(Color.accentColor.opacity(opacity))
                    .frame(width: size, height: size)
            } else {
                Diamond()
                    .fill(Color.purple.opacity(opacity))
                    .frame(width: size, height: size)
            }
        }
        .rotationEffect(.degrees(rotation))
        .offset(offset)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 6 + Double.random(in: 0...2))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
            ) {
                offset = CGSize(
                    width: CGFloat.random(in: -80...80),
                    height: CGFloat.random(in: -80...80)
                )
                opacity = Double.random(in: 0.03...0.1)
                rotation = Double.random(in: -30...30)
            }
        }
    }
}

// Diamond shape for variety
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: 0, y: height / 2))
        path.closeSubpath()

        return path
    }
}
