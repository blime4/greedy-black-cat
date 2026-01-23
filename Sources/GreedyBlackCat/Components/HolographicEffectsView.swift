import SwiftUI

// Helper struct for ForEach with Int range
struct HolographicLayer: Identifiable {
    let id = UUID()
    let index: Int
}

// Holographic shimmer effect for special items
struct HolographicEffectView: View {
    let intensity: CGFloat

    @State private var shimmerPhase: CGFloat = 0
    @State private var hologramOffset: CGFloat = 0

    var body: some View {
        let layers = [HolographicLayer(index: 0), HolographicLayer(index: 1), HolographicLayer(index: 2), HolographicLayer(index: 3), HolographicLayer(index: 4)]
        let particles = [HolographicLayer(index: 0), HolographicLayer(index: 1), HolographicLayer(index: 2), HolographicLayer(index: 3), HolographicLayer(index: 4), HolographicLayer(index: 5), HolographicLayer(index: 6), HolographicLayer(index: 7)]

        return ZStack {
            // Holographic interference pattern
            ForEach(layers, id: \.id) { layer in
                let layerOffset = shimmerPhase + CGFloat(layer.index) * 0.2

                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    Path { path in
                        // Scanlines
                        for y in stride(from: 0, to: height, by: 4) {
                            let progress = (y / height + layerOffset).truncatingRemainder(dividingBy: 1)

                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(intensity * 0.3),
                                Color.purple.opacity(intensity * 0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.5)
                    .offset(x: hologramOffset * CGFloat(layer.index) * 10)
                }
            }

            // Holographic glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(intensity * 0.4),
                            Color.purple.opacity(intensity * 0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)

            // Floating holographic particles
            ForEach(particles, id: \.id) { particle in
                let angle = Double(particle.index) * 45 + shimmerPhase * 57.3
                let distance: CGFloat = 80 + intensity * 40

                Circle()
                    .fill(Color.white.opacity(intensity * 0.6))
                    .frame(width: 4, height: 4)
                    .position(
                        x: 100 + cos(angle * .pi / 180) * distance,
                        y: 100 + sin(angle * .pi / 180) * distance
                    )
                    .blur(radius: 2)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.0
            }
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                hologramOffset = 1.0
            }
        }
    }
}

// Glowing trail segments
struct GlowingTrailSegmentView: View {
    let position: CGPoint
    let segmentIndex: Int
    let totalSegments: Int
    let comboCount: Int
    let cellSize: CGFloat
    let isInvincible: Bool

    @State private var glowPulse: CGFloat = 0
    @State private var sparkleOpacity: Double = 0

    var body: some View {
        let progress = 1.0 - (Double(segmentIndex) / Double(totalSegments))
        let baseSize = cellSize * 0.8 * progress

        ZStack {
            // Outer glow ring
            if comboCount >= 3 || isInvincible {
                Circle()
                    .fill(trailColor.opacity(0.3 * glowPulse))
                    .frame(width: baseSize * 1.4, height: baseSize * 1.4)
                    .blur(radius: 8)
            }

            // Main body
            Circle()
                .fill(trailColor.opacity(0.6))
                .frame(width: baseSize, height: baseSize)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    trailColor.opacity(0.9),
                                    trailColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: trailColor.opacity(0.5), radius: 4)

            // Sparkle for high combos
            if comboCount >= 5 || isInvincible {
                Image(systemName: "sparkle")
                    .font(.system(size: baseSize * 0.3))
                    .foregroundColor(sparkleColor)
                    .opacity(sparkleOpacity)
                    .scaleEffect(comboCount >= 7 ? 1.2 : 1.0)
            }

            // Inner glow
            Circle()
                .fill(trailColor.opacity(0.2))
                .frame(width: baseSize * 0.5, height: baseSize * 0.5)
                .blur(radius: 3)
        }
        .position(position)
        .onAppear {
            startAnimations()
        }
    }

    private var trailColor: Color {
        if isInvincible {
            return .purple
        } else if comboCount >= 7 {
            return .yellow
        } else if comboCount >= 5 {
            return .orange
        } else if comboCount >= 3 {
            return .red
        } else {
            return Color.accentColor
        }
    }

    private var sparkleColor: Color {
        if isInvincible {
            return .white
        } else if comboCount >= 7 {
            return .yellow
        } else {
            return .orange
        }
    }

    private func startAnimations() {
        // Glow pulse
        if comboCount >= 3 || isInvincible {
            withAnimation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                glowPulse = 1.0
            }

            // Sparkle animation
            withAnimation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...0.3))
            ) {
                sparkleOpacity = Double.random(in: 0.5...1.0)
            }
        }
    }
}

// Multi-color screen flash effects
struct MultiColorFlashView: View {
    let flashType: FlashType
    let intensity: Double

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            switch flashType {
            case .achievement:
                achievementFlash
            case .damage:
                damageFlash
            case .powerUp:
                powerUpFlash
            case .levelUp:
                levelUpFlash
            case .victory:
                victoryFlash
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            triggerFlash()
        }
    }

    private var achievementFlash: some View {
        ZStack {
            // Purple and gold gradient
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.6 * opacity),
                    Color.yellow.opacity(0.4 * opacity),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Starburst lines
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) * 30
                let length = 200 * scale * opacity

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.8 * opacity),
                                Color.clear
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 3, height: length)
                    .rotationEffect(.degrees(angle))
                    .offset(
                        x: 200 + cos(angle * .pi / 180) * 100,
                        y: 400 + sin(angle * .pi / 180) * 100
                    )
            }
        }
    }

    private var damageFlash: some View {
        ZStack {
            // Red flash with vignette
            RadialGradient(
                colors: [
                    Color.red.opacity(0.5 * opacity),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            // Crack lines
            if intensity > 0.5 {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(0.3 * opacity))
                        .frame(width: 2, height: CGFloat.random(in: 50...150))
                        .rotationEffect(.degrees(Double.random(in: -15...15)))
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -150...150)
                        )
                }
            }
        }
    }

    private var powerUpFlash: some View {
        ZStack {
            // Cyan and blue gradient
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.5 * opacity),
                    Color.blue.opacity(0.3 * opacity),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Swirl effect
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        Color.white.opacity(0.4 * opacity),
                        lineWidth: 3
                    )
                    .frame(width: 100 + CGFloat(index) * 50, height: 100 + CGFloat(index) * 50)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .scaleEffect(scale)
            }
        }
    }

    private var levelUpFlash: some View {
        ZStack {
            // Green and gold gradient
            RadialGradient(
                colors: [
                    Color.green.opacity(0.6 * opacity),
                    Color.yellow.opacity(0.4 * opacity),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()

            // Level up rings
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.8 * opacity),
                                Color.clear
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 4
                    )
                    .frame(
                        width: 50 + CGFloat(index) * 80 * scale,
                        height: 50 + CGFloat(index) * 80 * scale
                    )
                    .opacity(1 - progress(for: index))
            }
        }
    }

    private var victoryFlash: some View {
        ZStack {
            // Rainbow victory gradient
            LinearGradient(
                colors: [
                    Color.red.opacity(0.5 * opacity),
                    Color.orange.opacity(0.5 * opacity),
                    Color.yellow.opacity(0.5 * opacity),
                    Color.green.opacity(0.5 * opacity),
                    Color.blue.opacity(0.5 * opacity),
                    Color.purple.opacity(0.5 * opacity),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Confetti overlay
            ForEach(0..<30, id: \.self) { index in
                let confetti = confettiData(for: index)

                Rectangle()
                    .fill(confetti.color.opacity(opacity))
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(confetti.rotation))
                    .position(
                        x: confetti.x,
                        y: confetti.y
                    )
            }
        }
    }

    private func triggerFlash() {
        withAnimation(.easeOut(duration: 0.4)) {
            opacity = intensity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 0
            }
        }
    }

    private func progress(for index: Int) -> Double {
        min(1.0, Double(index) * 0.25 / scale)
    }

    private func confettiData(for index: Int) -> ConfettiData {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        return ConfettiData(
            color: colors.randomElement() ?? .yellow,
            x: CGFloat.random(in: -150...150),
            y: CGFloat.random(in: -150...150),
            rotation: CGFloat.random(in: 0...720)
        )
    }
}

struct ConfettiData {
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let rotation: CGFloat
}

enum FlashType {
    case achievement
    case damage
    case powerUp
    case levelUp
    case victory
}

// Enhanced power-up collection animation
struct PowerUpCollectionAnimation: View {
    let powerUp: PowerUp
    let cellSize: CGFloat

    @State private var collectionScale: CGFloat = 1.0
    @State private var collectionRotation: Double = 0
    @State private var magnetRings: CGFloat = 0

    var body: some View {
        ZStack {
            // Suction rings
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        powerUp.type.color.opacity(0.6),
                        lineWidth: 2
                    )
                    .frame(
                        width: cellSize * (1.2 + magnetRings + CGFloat(index) * 0.2),
                        height: cellSize * (1.2 + magnetRings + CGFloat(index) * 0.2)
                    )
                    .rotationEffect(.degrees(collectionRotation + Double(index) * 45))
                    .opacity(1.0 - magnetRings * 0.5)
            }

            // Sparkle burst
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * 45 + collectionRotation

                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .opacity(1.0 - magnetRings)
                    .offset(
                        x: cos(angle * .pi / 180) * cellSize * 0.6,
                        y: sin(angle * .pi / 180) * cellSize * 0.6
                    )
            }

            // Main power-up with scale effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            powerUp.type.color.opacity(1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: cellSize * 0.6, height: cellSize * 0.6)
                .shadow(color: powerUp.type.color.opacity(0.8), radius: 8)
                .scaleEffect(collectionScale)
                .overlay(
                    Text(powerUp.type.icon)
                        .font(.system(size: cellSize * 0.3))
                        .rotationEffect(.degrees(collectionRotation))
                )
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                collectionScale = 1.5
            }
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                collectionRotation = 360
            }
            withAnimation(.easeOut(duration: 0.8)) {
                magnetRings = 1.0
            }
        }
    }
}

// Victory celebration sequence
struct VictoryCelebrationView: View {
    let score: Int
    let isNewHighScore: Bool
    let onContinue: () -> Void

    @State private var showContent = false
    @State private var scoreScale: CGFloat = 0
    @State private var trophyRotation: Double = 0
    @State private var confettiOpacity: Double = 0
    @State private var celebrationPhase: Int = 0

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            if showContent {
                VStack(spacing: 30) {
                    Spacer()

                    // Trophy with animation
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.yellow.opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 160, height: 160)

                        // Trophy icon
                        Text("🏆")
                            .font(.system(size: 80))
                            .scaleEffect(scoreScale)
                            .rotationEffect(.degrees(trophyRotation))
                            .shadow(color: Color.yellow.opacity(0.5), radius: 10)
                            .overlay(
                                Text("🏆")
                                    .font(.system(size: 80))
                                    .scaleEffect(scoreScale * 1.05)
                                    .rotationEffect(.degrees(-trophyRotation))
                                    .opacity(0.3)
                            )
                    }

                    // Victory message
                    Text(isNewHighScore ? "NEW HIGH SCORE!" : "VICTORY!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.yellow)
                        .scaleEffect(scoreScale)
                        .shadow(color: Color.yellow.opacity(0.3), radius: 5)

                    // Score display
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scoreScale)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                                )
                        )

                    // Confetti overlay
                    if confettiOpacity > 0 {
                        ZStack {
                            ForEach(0..<50, id: \.self) { index in
                                let confetti = victoryConfetti(for: index)

                                Rectangle()
                                    .fill(confetti.color.opacity(confettiOpacity))
                                    .frame(width: 8, height: 8)
                                    .rotationEffect(.degrees(confetti.rotation))
                                    .position(
                                        x: confetti.x,
                                        y: confetti.y
                                    )
                            }
                        }
                    }

                    // Continue button
                    Button(action: {
                        onContinue()
                    }) {
                        Text("Continue")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color.yellow.opacity(0.5), radius: 10)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(scoreScale)
                    .padding(.top, 20)

                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            startCelebration()
        }
    }

    private func startCelebration() {
        // Phase 1: Show content
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showContent = true
            scoreScale = 1.0
        }

        // Phase 2: Trophy rotation
        if isNewHighScore {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                    trophyRotation = 15
                }
            }
        }

        // Phase 3: Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeIn(duration: 0.5)) {
                confettiOpacity = 1.0
            }
        }
    }

    private func victoryConfetti(for index: Int) -> ConfettiData {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue,
            .purple, .pink, .cyan, .white
        ]
        return ConfettiData(
            color: colors.randomElement() ?? .yellow,
            x: CGFloat.random(in: -180...180),
            y: CGFloat.random(in: -300...300),
            rotation: CGFloat.random(in: 0...720)
        )
    }
}
