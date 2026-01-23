import SwiftUI

struct RippleShockwaveView: View {
    let position: CGPoint
    let color: Color
    let maxRadius: CGFloat
    let duration: TimeInterval

    @State private var currentRadius: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var lineWidth: CGFloat = 5

    var body: some View {
        ZStack {
            // Multiple ripple rings
            ForEach(0..<3, id: \.self) { index in
                let delay = Double(index) * 0.15
                let ringProgress = max(0, min(1, (currentRadius / maxRadius) - delay))

                if ringProgress > 0 {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.8 * (1 - ringProgress)),
                                    color.opacity(0.3 * (1 - ringProgress)),
                                    color.opacity(0)
                                ],
                                startPoint: .center,
                                endPoint: .trailing
                            ),
                            lineWidth: lineWidth * (1 - ringProgress * 0.5)
                        )
                        .frame(
                            width: currentRadius * 2 * (1 - delay),
                            height: currentRadius * 2 * (1 - delay)
                        )
                        .opacity(opacity * (1 - ringProgress))
                        .blur(radius: ringProgress * 5)
                }
            }

            // Central impact flash
            if currentRadius < maxRadius * 0.3 {
                let flashOpacity = 1.0 - (currentRadius / (maxRadius * 0.3))
                Circle()
                    .fill(color)
                    .frame(width: currentRadius * 0.5, height: currentRadius * 0.5)
                    .opacity(opacity * flashOpacity)
                    .blur(radius: 10)
            }

            // Particles emitted from center
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) * 30
                let distance = currentRadius * 0.8
                RippleParticle(
                    angle: angle,
                    distance: distance,
                    color: color,
                    progress: currentRadius / maxRadius
                )
            }
        }
        .position(position)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: duration)) {
            currentRadius = maxRadius
            opacity = 0
        }
    }
}

struct RippleParticle: View {
    let angle: Double
    let distance: CGFloat
    let color: Color
    let progress: Double

    var body: some View {
        Circle()
            .fill(color.opacity(1 - progress))
            .frame(width: 6, height: 6)
            .offset(
                x: cos(angle * .pi / 180) * distance,
                y: sin(angle * .pi / 180) * distance
            )
            .blur(radius: progress * 3)
    }
}

// Vortex suction effect for food
struct VortexSuctionView: View {
    let foodPosition: CGPoint
    let catPosition: CGPoint
    let cellSize: CGFloat
    let isActive: Bool

    @State private var rotation: Double = 0
    @State private var suctionStrength: CGFloat = 0

    var body: some View {
        if isActive {
            ZStack {
                // Spiral suction lines
                ForEach(0..<8, id: \.self) { index in
                    let angle = Double(index) * 45 + rotation
                    SpiralLine(
                        angle: angle,
                        strength: suctionStrength,
                        color: Color.orange
                    )
                }

                // Particles being sucked in
                ForEach(0..<6, id: \.self) { index in
                    SuctionParticle(
                        index: index,
                        foodPosition: foodPosition,
                        catPosition: catPosition,
                        progress: suctionStrength
                    )
                }
            }
            .position(foodPosition)
            .onAppear {
                startSuction()
            }
        }
    }

    private func startSuction() {
        withAnimation(.easeIn(duration: 0.5)) {
            suctionStrength = 1.0
        }
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

struct SpiralLine: View {
    let angle: Double
    let strength: CGFloat
    let color: Color

    var body: some View {
        Path { path in
            let centerX: CGFloat = 0
            let centerY: CGFloat = 0
            let maxRadius: CGFloat = 100 * strength

            path.move(to: CGPoint(x: centerX, y: centerY))

            for i in 0..<20 {
                let progress = CGFloat(i) / 20
                let currentRadius = progress * maxRadius
                let currentAngle = angle + progress * 180

                let x = centerX + cos(currentAngle * .pi / 180) * currentRadius
                let y = centerY + sin(currentAngle * .pi / 180) * currentRadius

                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        .stroke(color.opacity(0.6), lineWidth: 2)
        .blur(radius: 2)
    }
}

struct SuctionParticle: View {
    let index: Int
    let foodPosition: CGPoint
    let catPosition: CGPoint
    let progress: CGFloat

    @State private var offset: CGFloat = 0

    var body: some View {
        Circle()
            .fill(Color.orange.opacity(1 - progress))
            .frame(width: 5, height: 5)
            .offset(
                x: (catPosition.x - foodPosition.x) * progress * offset * 0.5,
                y: (catPosition.y - foodPosition.y) * progress * offset * 0.5
            )
            .onAppear {
                offset = CGFloat.random(in: 0.5...1.0)
            }
    }
}

// Dynamic background that changes with combo
struct DynamicBackgroundView: View {
    let comboCount: Int
    let difficultyLevel: Int

    @State private var hueRotation: Double = 0
    @State private var pulse: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        baseColor.opacity(0.3),
                        baseColor.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Animated gradient mesh
                ForEach(0..<5, id: \.self) { index in
                    let position = gradientPosition(
                        index: index,
                        width: geometry.size.width,
                        height: geometry.size.height
                    )

                    RadialGradient(
                        colors: [
                            comboColor.opacity(0.4 + pulse * 0.2),
                            comboColor.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .frame(width: 300, height: 300)
                    .position(position)
                    .blur(radius: 50)
                    .rotationEffect(.degrees(hueRotation + Double(index * 36)))
                }

                // Floating orbs
                ForEach(0..<6, id: \.self) { index in
                    FloatingOrb(
                        index: index,
                        comboCount: comboCount,
                        color: comboColor
                    )
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                startAnimation()
            }
            .onChange(of: comboCount) { _, _ in
                updateColors()
            }
        }
    }

    private var baseColor: Color {
        switch difficultyLevel {
        case 1...2: return .blue
        case 3...4: return .purple
        case 5...6: return .red
        default: return .gray
        }
    }

    private var comboColor: Color {
        switch comboCount {
        case 0...2: return .orange
        case 3...4: return .red
        case 5...7: return .purple
        case 8...: return .pink
        default: return .yellow
        }
    }

    private func gradientPosition(index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let angle = Double(index) * 72 + hueRotation
        let radius: CGFloat = 150

        return CGPoint(
            x: width / 2 + cos(angle * .pi / 180) * radius,
            y: height / 2 + sin(angle * .pi / 180) * radius
        )
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 30.0).repeatForever(autoreverses: false)) {
            hueRotation = 360
        }
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            pulse = 1.0
        }
    }

    private func updateColors() {
        withAnimation(.easeInOut(duration: 0.5)) {
            // Trigger color update
        }
    }
}

struct FloatingOrb: View {
    let index: Int
    let comboCount: Int
    let color: Color

    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0.3
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: 40 + CGFloat(comboCount) * 5, height: 40 + CGFloat(comboCount) * 5)
            .blur(radius: 20)
            .position(position)
            .scaleEffect(scale)
            .onAppear {
                let randomX = CGFloat.random(in: 50...350)
                let randomY = CGFloat.random(in: 50...750)
                position = CGPoint(x: randomX, y: randomY)

                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 3...5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3)
                ) {
                    position = CGPoint(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 50...750)
                    )
                    opacity = Double.random(in: 0.2...0.5)
                    scale = CGFloat.random(in: 0.8...1.2)
                }
            }
    }
}

// Chromatic aberration effect on damage
struct ChromaticAberrationView: View {
    let intensity: Double

    var body: some View {
        ZStack {
            // Red channel offset
            Rectangle()
                .fill(Color.red.opacity(intensity * 0.1))
                .ignoresSafeArea()

            // Blue channel offset
            Rectangle()
                .fill(Color.blue.opacity(intensity * 0.1))
                .ignoresSafeArea()

            // Glitch lines
            if intensity > 0.5 {
                ForEach(0..<3, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 2)
                        .offset(y: CGFloat(index * 100 - 150))
                        .ignoresSafeArea(.all, edges: .trailing)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
