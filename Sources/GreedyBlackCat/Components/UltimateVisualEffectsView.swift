import SwiftUI

struct ParticleExplosionView: View {
    let position: CGPoint
    let color: Color
    let particleCount: Int
    let explosionType: ExplosionType

    @State private var particles: [ExplosionParticle] = []
    @State private var scale: CGFloat = 0

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ExplosionParticleView(particle: particle)
            }
        }
        .position(position)
        .scaleEffect(scale)
        .onAppear {
            createParticles()
            animate()
        }
    }

    private func createParticles() {
        particles = (0..<particleCount).map { index in
            ExplosionParticle(
                id: UUID(),
                color: color,
                size: particleSize(for: index),
                velocity: initialVelocity(for: index),
                life: 1.0,
                decayRate: decayRate(for: index)
            )
        }
    }

    private func particleSize(for index: Int) -> CGFloat {
        switch explosionType {
        case .small:
            return CGFloat.random(in: 3...8)
        case .medium:
            return CGFloat.random(in: 5...12)
        case .large:
            return CGFloat.random(in: 8...18)
        case .massive:
            return CGFloat.random(in: 10...25)
        }
    }

    private func initialVelocity(for index: Int) -> CGVector {
        let speed: CGFloat
        let angle: Double

        switch explosionType {
        case .small:
            speed = CGFloat.random(in: 3...8)
        case .medium:
            speed = CGFloat.random(in: 5...12)
        case .large:
            speed = CGFloat.random(in: 8...18)
        case .massive:
            speed = CGFloat.random(in: 12...25)
        }

        angle = Double.random(in: 0...360)

        return CGVector(
            dx: cos(angle * .pi / 180) * speed,
            dy: sin(angle * .pi / 180) * speed
        )
    }

    private func decayRate(for index: Int) -> Double {
        switch explosionType {
        case .small:
            return Double.random(in: 0.015...0.03)
        case .medium:
            return Double.random(in: 0.01...0.025)
        case .large:
            return Double.random(in: 0.008...0.02)
        case .massive:
            return Double.random(in: 0.005...0.015)
        }
    }

    private func animate() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.0
        }

        // Animate particles
        for i in particles.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.01) {
                animateParticle(index: i)
            }
        }
    }

    private func animateParticle(index: Int) {
        guard index < particles.count else { return }

        withAnimation(.linear(duration: particles[index].life / particles[index].decayRate)) {
            particles[index].life = 0
            particles[index].currentPosition = CGPoint(
                x: particles[index].currentPosition.x + particles[index].velocity.dx * 30,
                y: particles[index].currentPosition.y + particles[index].velocity.dy * 30
            )
        }
    }
}

struct ExplosionParticle: Identifiable {
    let id: UUID
    let color: Color
    let size: CGFloat
    let velocity: CGVector
    var life: Double
    let decayRate: Double
    var currentPosition: CGPoint = .zero

    var isDead: Bool {
        life <= 0
    }
}

struct ExplosionParticleView: View {
    let particle: ExplosionParticle

    var body: some View {
        Circle()
            .fill(particle.color.opacity(particle.life))
            .frame(width: particle.size, height: particle.size)
            .position(particle.currentPosition)
            .blur(radius: particle.size * 0.3)
    }
}

enum ExplosionType {
    case small
    case medium
    case large
    case massive
}

// Neon glow effect for high combos
struct NeonGlowView: View {
    let comboCount: Int
    let isActive: Bool

    @State private var glowIntensity: CGFloat = 0
    @State private var pulsePhase: Double = 0

    var body: some View {
        ZStack {
            if isActive && comboCount >= 5 {
                // Outer neon ring
                Circle()
                    .stroke(
                        neonColor.opacity(0.6),
                        lineWidth: 4
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 15 * glowIntensity)
                    .scaleEffect(1.0 + glowIntensity * 0.3)

                // Middle glow ring
                Circle()
                    .stroke(
                        neonColor.opacity(0.8),
                        lineWidth: 3
                    )
                    .frame(width: 350, height: 350)
                    .blur(radius: 10 * glowIntensity)
                    .scaleEffect(1.0 + glowIntensity * 0.2)

                // Inner core
                Circle()
                    .fill(neonColor.opacity(0.3 * glowIntensity))
                    .frame(width: 300, height: 300)
                    .blur(radius: 20)

                // Neon sparkles
                ForEach(0..<12, id: \.self) { index in
                    NeonSparkle(
                        index: index,
                        color: neonColor,
                        intensity: glowIntensity,
                        phase: pulsePhase
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            startPulse()
        }
        .onChange(of: isActive) { _, active in
            if active {
                withAnimation(.easeIn(duration: 0.3)) {
                    glowIntensity = 1.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    glowIntensity = 0
                }
            }
        }
    }

    private var neonColor: Color {
        switch comboCount {
        case 5...6: return .yellow
        case 7...9: return .orange
        case 10...: return .red
        default: return .purple
        }
    }

    private func startPulse() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulsePhase = 2 * .pi
        }
    }
}

struct NeonSparkle: View {
    let index: Int
    let color: Color
    let intensity: CGFloat
    let phase: Double

    @State private var position: CGPoint = .zero
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1

    var body: some View {
        let angle = Double(index) * 30 + phase * 57.3
        let distance: CGFloat = 150 + intensity * 50

        return Image(systemName: "sparkle")
            .font(.system(size: 20))
            .foregroundColor(color)
            .scaleEffect(scale)
            .opacity(opacity * intensity)
            .position(
                x: 200 + cos(angle * .pi / 180) * distance,
                y: 400 + sin(angle * .pi / 180) * distance
            )
            .onAppear {
                position = CGPoint(
                    x: CGFloat(200) + cos(angle * .pi / 180) * distance,
                    y: CGFloat(400) + sin(angle * .pi / 180) * distance
                )

                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1)
                ) {
                    scale = CGFloat.random(in: 0.8...1.5)
                    opacity = Double.random(in: 0.5...1.0)
                }
            }
    }
}

// Screen distortion/lens effect
struct ScreenDistortionView: View {
    let isActive: Bool
    let distortionIntensity: CGFloat

    @State private var distortionOffset: CGFloat = 0

    var body: some View {
        ZStack {
            if isActive {
                // Barrel distortion simulation
                GeometryReader { geometry in
                    ZStack {
                        // Slight chromatic aberration
                        Rectangle()
                            .fill(Color.red.opacity(distortionIntensity * 0.1))
                            .offset(x: -distortionOffset * 5)
                            .ignoresSafeArea()

                        Rectangle()
                            .fill(Color.blue.opacity(distortionIntensity * 0.1))
                            .offset(x: distortionOffset * 5)
                            .ignoresSafeArea()

                        // Vignette effect
                        RadialGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(distortionIntensity * 0.5)
                            ],
                            center: .center,
                            startRadius: 200,
                            endRadius: 600
                        )
                        .ignoresSafeArea()
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            startDistortion()
        }
    }

    private func startDistortion() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            distortionOffset = 10
        }
    }
}

// Smooth transition overlay
struct SmoothTransitionView: View {
    let fromState: GameState
    let toState: GameState
    let isActive: Bool

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            if isActive {
                // Circular reveal transition
                ZStack {
                    Circle()
                        .fill(transitionColor)
                        .scaleEffect(progress * 2)
                        .blur(radius: 10)
                }
                .ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                progress = 1.0
            }
        }
    }

    private var transitionColor: Color {
        switch (fromState, toState) {
        case (.menu, .playing), (.paused, .playing):
            return .white
        case (.playing, .menu), (.playing, .paused):
            return .black
        default:
            return .gray
        }
    }
}

// Beat sync visualizer
struct BeatSyncVisualizer: View {
    let beatValue: CGFloat
    let isActive: Bool

    @State private var pulsePhase: Double = 0

    var body: some View {
        ZStack {
            if isActive {
                // Center beat indicator
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentColor.opacity(beatValue * 0.8),
                                Color.accentColor.opacity(beatValue * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(1.0 + beatValue * 0.3)
                    .blur(radius: 10)

                // Beat rings
                ForEach(0..<3, id: \.self) { index in
                    let delay = Double(index) * 0.2
                    let ringProgress = max(0, min(1, (beatValue - delay) / (1 - delay)))

                    Circle()
                        .stroke(
                            Color.accentColor.opacity(ringProgress * 0.6),
                            lineWidth: 4 - CGFloat(index)
                        )
                        .frame(width: 200 + CGFloat(index) * 50, height: 200 + CGFloat(index) * 50)
                        .opacity(ringProgress)
                        .scaleEffect(1.0 + ringProgress * 0.2)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.linear(duration: 0.1), value: beatValue)
    }
}

// Shockwave distortion effect
struct ShockwaveDistortionView: View {
    let position: CGPoint
    let radius: CGFloat
    let progress: Double

    var body: some View {
        ZStack {
            // Distortion ring
            Circle()
                .stroke(
                    Color.white.opacity(0.3 * (1 - progress)),
                    lineWidth: 5
                )
                .frame(width: radius * 2, height: radius * 2)
                .blur(radius: 10)
                .scaleEffect(1.0 + progress * 0.5)

            // Color aberration rings
            ForEach(0..<3, id: \.self) { index in
                let offset = CGFloat(index) * 3

                Circle()
                    .stroke(
                        index == 0 ? Color.red.opacity(0.2 * (1 - progress)) :
                        index == 1 ? Color.green.opacity(0.2 * (1 - progress)) :
                        Color.blue.opacity(0.2 * (1 - progress)),
                        lineWidth: 3
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .offset(
                        x: (index == 0 ? -1 : 1) * offset * (1 - progress) * 20,
                        y: (index == 1 ? -1 : 1) * offset * (1 - progress) * 20
                    )
            }
        }
        .position(position)
        .allowsHitTesting(false)
    }
}
