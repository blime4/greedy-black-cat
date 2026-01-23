import SwiftUI

struct BossView: View {
    let boss: Boss
    let cellSize: CGFloat

    @State private var attackAnimation: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var isHit: Bool = false

    var body: some View {
        ZStack {
            // Health bar above boss
            VStack(spacing: 4) {
                // Boss name
                Text(boss.type.emoji)
                    .font(.system(size: cellSize * 0.5))
                    .scaleEffect(pulseScale)

                // Health bar background
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.3))
                    .frame(width: cellSize * 1.2, height: cellSize * 0.1)

                // Health bar fill
                RoundedRectangle(cornerRadius: 3)
                    .fill(boss.type.color)
                    .frame(width: cellSize * 1.2 * boss.healthPercentage, height: cellSize * 0.1)
                    .animation(.easeInOut(duration: 0.3), value: boss.health)

                // Boss body
                bossBody
                    .scaleEffect(isHit ? 0.9 : 1.0)
                    .opacity(isHit ? 0.7 : 1.0)
            }
            .rotationEffect(.degrees(rotationAngle))
            .onAppear {
                startAnimations()
            }
        }
        .onChange(of: boss.health) { _, newHealth in
            if newHealth < boss.maxHealth {
                triggerHitEffect()
            }
        }
    }

    private var bossBody: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(boss.type.color.opacity(0.3))
                .frame(width: cellSize * 1.3, height: cellSize * 1.3)
                .blur(radius: 8)

            // Main body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [boss.type.color, boss.type.color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: cellSize * 1.2, height: cellSize * 1.2)
                .shadow(color: boss.type.color.opacity(0.5), radius: 8)

            // Face/eyes
            bossFace
        }
    }

    private var bossFace: some View {
        Group {
            switch boss.type {
            case .giantFish:
                fishFace
            case .ghostCat:
                ghostFace
            case .shadowBeast:
                beastFace
            case .goldenDragon:
                dragonFace
            }
        }
    }

    private var fishFace: some View {
        VStack(spacing: cellSize * 0.05) {
            // Eyes
            HStack(spacing: cellSize * 0.2) {
                Circle()
                    .fill(Color.white)
                    .frame(width: cellSize * 0.2, height: cellSize * 0.2)
                Circle()
                    .fill(Color.white)
                    .frame(width: cellSize * 0.2, height: cellSize * 0.2)
            }

            // Mouth
            RoundedRectangle(cornerRadius: cellSize * 0.05)
                .fill(Color.black.opacity(0.3))
                .frame(width: cellSize * 0.4, height: cellSize * 0.08)
        }
    }

    private var ghostFace: some View {
        VStack(spacing: cellSize * 0.08) {
            // Hollow eyes
            HStack(spacing: cellSize * 0.25) {
                Circle()
                    .fill(Color.black)
                    .frame(width: cellSize * 0.15, height: cellSize * 0.15)
                Circle()
                    .fill(Color.black)
                    .frame(width: cellSize * 0.15, height: cellSize * 0.15)
            }

            // Oval mouth
            Ellipse()
                .fill(Color.black.opacity(0.5))
                .frame(width: cellSize * 0.2, height: cellSize * 0.3)
        }
    }

    private var beastFace: some View {
        VStack(spacing: cellSize * 0.05) {
            // Angry eyes
            HStack(spacing: cellSize * 0.2) {
                Triangle()
                    .fill(Color.red)
                    .frame(width: cellSize * 0.15, height: cellSize * 0.15)
                Triangle()
                    .fill(Color.red)
                    .frame(width: cellSize * 0.15, height: cellSize * 0.15)
            }

            // Sharp teeth
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Triangle()
                        .fill(Color.white)
                        .frame(width: cellSize * 0.06, height: cellSize * 0.1)
                }
            }
        }
    }

    private var dragonFace: some View {
        VStack(spacing: cellSize * 0.05) {
            // Noble eyes
            HStack(spacing: cellSize * 0.2) {
                Circle()
                    .fill(Color.red)
                    .frame(width: cellSize * 0.12, height: cellSize * 0.12)
                Circle()
                    .fill(Color.red)
                    .frame(width: cellSize * 0.12, height: cellSize * 0.12)
            }

            // Flame symbol
            Image(systemName: "flame.fill")
                .font(.system(size: cellSize * 0.2))
                .foregroundColor(.orange)
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        // Pulse animation
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.1
        }

        // Slow rotation
        withAnimation(
            Animation.linear(duration: 20.0)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
    }

    private func triggerHitEffect() {
        isHit = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isHit = false
        }
    }
}

struct BossAttackView: View {
    let attack: BossAttack
    let cellSize: CGFloat

    @State private var progress: CGFloat = 0

    var body: some View {
        Group {
            switch attack.type.ability {
            case .dashAttack:
                dashIndicator
            case .teleport:
                teleportRipple
            case .split:
                splitParticles
            case .fireBreath:
                fireBreath
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0)) {
                progress = 1.0
            }
        }
    }

    private var dashIndicator: some View {
        ZStack {
            // Warning line showing dash direction
            Rectangle()
                .fill(attack.type.color.opacity(0.6))
                .frame(width: cellSize * 0.15, height: cellSize * 2)
                .rotationEffect(dashRotation)
                .offset(y: -cellSize * (1 - progress))

            Circle()
                .stroke(attack.type.color.opacity(0.8), lineWidth: 3)
                .frame(width: cellSize * 0.6, height: cellSize * 0.6)
        }
    }

    private var teleportRipple: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(attack.type.color.opacity(0.5 - Double(i) * 0.15), lineWidth: 2)
                    .frame(width: cellSize * (0.5 + CGFloat(i) * 0.3 + progress * 0.5), height: cellSize * (0.5 + CGFloat(i) * 0.3 + progress * 0.5))
                    .opacity(1 - progress)
            }
        }
    }

    private var splitParticles: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * 45
                Circle()
                    .fill(attack.type.color.opacity(0.7))
                    .frame(width: cellSize * 0.15, height: cellSize * 0.15)
                    .offset(
                        x: cos(angle * .pi / 180) * cellSize * progress,
                        y: sin(angle * .pi / 180) * cellSize * progress
                    )
            }
        }
    }

    private var fireBreath: some View {
        ZStack {
            // Flame cone
            Image(systemName: "flame.fill")
                .font(.system(size: cellSize * 0.4))
                .foregroundColor(.orange.opacity(1 - progress))
                .offset(y: -cellSize * progress)

            // Heat distortion
            Circle()
                .fill(Color.red.opacity(0.3 * (1 - progress)))
                .frame(width: cellSize * progress, height: cellSize * progress)
                .blur(radius: 10)
        }
    }

    private var dashRotation: Angle {
        switch attack.direction {
        case .up: return .degrees(0)
        case .down: return .degrees(180)
        case .left: return .degrees(-90)
        case .right: return .degrees(90)
        }
    }
}
