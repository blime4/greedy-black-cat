import SwiftUI

struct AchievementCelebrationView: View {
    let isActive: Bool
    let achievementType: AchievementType

    @State private var confettiCount: Int = 0
    @State private var celebrationScale: CGFloat = 0.5
    @State private var celebrationOpacity: Double = 0

    var body: some View {
        ZStack {
            if isActive {
                // Confetti explosion
                ForEach(0..<confettiCount, id: \.self) { index in
                    ConfettiPiece(
                        index: index,
                        color: confettiColor(index: index)
                    )
                }

                // Central celebration burst
                ZStack {
                    // Starburst
                    ForEach(0..<12, id: \.self) { index in
                        let angle = Double(index) * 30
                        StarRay(angle: angle, color: achievementType.color)
                            .scaleEffect(celebrationScale)
                            .opacity(celebrationOpacity)
                    }

                    // Achievement icon
                    Text(achievementType.icon)
                        .font(.system(size: 80))
                        .scaleEffect(celebrationScale)
                        .opacity(celebrationOpacity)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, active in
            if active {
                startCelebration()
            }
        }
    }

    private func startCelebration() {
        // Animate confetti count
        withAnimation(.easeInOut(duration: 0.3)) {
            confettiCount = 50
        }

        // Animate burst
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            celebrationScale = 1.0
            celebrationOpacity = 1.0
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                celebrationOpacity = 0
            }
        }
    }

    private func confettiColor(index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors[index % colors.count]
    }
}

struct ConfettiPiece: View {
    let index: Int
    let color: Color

    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                // Random starting position from center
                let centerX = 200.0
                let centerY = 400.0
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 50...200)

                position = CGPoint(
                    x: centerX + cos(angle) * distance * 0.1,
                    y: centerY + sin(angle) * distance * 0.1
                )

                // Animate outward
                withAnimation(
                    Animation.easeOut(duration: Double.random(in: 1.0...2.0))
                        .delay(Double(index) * 0.01)
                ) {
                    position = CGPoint(
                        x: centerX + cos(angle) * distance,
                        y: centerY + sin(angle) * distance
                    )
                    rotation = Double.random(in: -360...360)
                }

                // Fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }
                }
            }
    }
}

struct StarRay: View {
    let angle: Double
    let color: Color

    @State private var length: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 4, height: length)
            .rotationEffect(.degrees(angle))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    length = 100
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        opacity = 0
                    }
                }
            }
    }
}

enum AchievementType {
    case firstBlood
    case comboMaster
    case speedDemon
    case survivor
    case bossSlayer
    case highScore
    case perfectGame
    case legend

    var icon: String {
        switch self {
        case .firstBlood: return "🎯"
        case .comboMaster: return "🔥"
        case .speedDemon: return "⚡"
        case .survivor: return "💪"
        case .bossSlayer: return "⚔️"
        case .highScore: return "🏆"
        case .perfectGame: return "⭐"
        case .legend: return "👑"
        }
    }

    var color: Color {
        switch self {
        case .firstBlood: return .red
        case .comboMaster: return .orange
        case .speedDemon: return .yellow
        case .survivor: return .green
        case .bossSlayer: return .purple
        case .highScore: return .blue
        case .perfectGame: return .pink
        case .legend: return Color(hex: "FFD700")
        }
    }

    var name: String {
        switch self {
        case .firstBlood: return "First Blood!"
        case .comboMaster: return "Combo Master!"
        case .speedDemon: return "Speed Demon!"
        case .survivor: return "Survivor!"
        case .bossSlayer: return "Boss Slayer!"
        case .highScore: return "New High Score!"
        case .perfectGame: return "Perfect Game!"
        case .legend: return "Legend!"
        }
    }
}
