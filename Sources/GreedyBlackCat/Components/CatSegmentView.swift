import SwiftUI

struct CatSegmentView: View {
    let isHead: Bool
    let direction: Direction
    let cellSize: CGFloat
    var comboCount: Int = 0
    var isInvincible: Bool = false
    var gameMode: GameMode = .classic
    var isEating: Bool = false

    @State private var mouthScale: CGFloat = 1.0
    @State private var appearScale: CGFloat = 0.0
    @State private var isGlowing = false
    @State private var eyePulse: CGFloat = 1.0
    @State private var jawOpen: CGFloat = 0

    private var emotion: CatEmotion {
        if isInvincible {
            return .excited
        }
        switch comboCount {
        case 0...1: return .focused
        case 2...3: return .happy
        case 4...: return .excited
        default: return .surprised
        }
    }

    private var catColor: Color {
        switch gameMode {
        case .classic:
            return Color(hex: "1A1A1A") // Black
        case .zen:
            return Color(hex: "FFB6C1") // Light pink
        case .timeAttack:
            return Color(hex: "FF6B6B") // Red
        case .hardcore:
            return Color(hex: "8B008B") // Dark purple
        }
    }

    var body: some View {
        ZStack {
            if isHead {
                catHeadView
            } else {
                catBodyView
            }

            // Subtle glow effect for body segments
            if !isHead {
                Circle()
                    .fill(Color.accentColor.opacity(isGlowing ? 0.1 : 0.05))
                    .frame(width: cellSize, height: cellSize)
                    .blur(radius: 5)
            }
        }
        .frame(width: cellSize * 0.9, height: cellSize * 0.9)
        .scaleEffect(appearScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: appearScale)
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: jawOpen)
        .animation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
            value: isGlowing
        )
        .onAppear {
            appearScale = 1.0
            isGlowing = true
        }
        .onChange(of: isEating) { _, newValue in
            if newValue && isHead {
                // Trigger jaw chomp animation
                withAnimation(.easeOut(duration: 0.1)) {
                    jawOpen = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        jawOpen = 0
                    }
                }
            }
        }
    }

    // MARK: - Cat Head
    private var catHeadView: some View {
        ZStack {
            // Main head shape with invincibility glow
            Group {
                RoundedRectangle(cornerRadius: cellSize * 0.3)
                    .fill(catColor)

                if isInvincible {
                    RoundedRectangle(cornerRadius: cellSize * 0.3)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 8)
                }
            }

            // Ears
            HStack(spacing: cellSize * 0.5) {
                earView(rotated: false)
                earView(rotated: true)
            }
            .offset(y: -cellSize * 0.15)

            // Eyes with emotion
            HStack(spacing: cellSize * 0.15) {
                eyeView
                eyeView
            }
            .offset(y: -cellSize * 0.05)
            .scaleEffect(emotion.eyeScale)

            // Nose
            Triangle()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: cellSize * 0.15, height: cellSize * 0.12)
                .offset(y: cellSize * 0.08)

            // Mouth with emotion-based animation and jaw chomp
            ZStack {
                // Upper jaw
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 1, y: 0),
                        control: CGPoint(x: 0.5, y: emotion.mouthPath.0 * emotion.mouthPath.1)
                    )
                }
                .stroke(Color(hex: "333333"), lineWidth: cellSize * 0.03)
                .frame(width: cellSize * 0.3, height: cellSize * 0.1)
                .offset(y: cellSize * 0.13 - (jawOpen * cellSize * 0.05))

                // Lower jaw (animated during eating)
                if jawOpen > 0 {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addQuadCurve(
                            to: CGPoint(x: 1, y: 0),
                            control: CGPoint(x: 0.5, y: emotion.mouthPath.0 * emotion.mouthPath.1)
                        )
                    }
                    .stroke(Color(hex: "333333"), lineWidth: cellSize * 0.03)
                    .frame(width: cellSize * 0.3, height: cellSize * 0.1)
                    .offset(y: cellSize * 0.17 + (jawOpen * cellSize * 0.05))
                }
            }
            .offset(y: cellSize * 0.15)

            // Whiskers with emotion angle
            whiskersView
        }
        .rotationEffect(headRotation)
    }

    private var headRotation: Angle {
        switch direction {
        case .up: return .degrees(0)
        case .down: return .degrees(180)
        case .left: return .degrees(-90)
        case .right: return .degrees(90)
        }
    }

    private func earView(rotated: Bool) -> some View {
        Triangle()
            .fill(Color(hex: "1A1A1A"))
            .frame(width: cellSize * 0.25, height: cellSize * 0.2)
            .overlay(
                Triangle()
                    .fill(Color(hex: "333333"))
                    .frame(width: cellSize * 0.15, height: cellSize * 0.12)
                    .offset(y: cellSize * 0.03)
            )
            .rotationEffect(.degrees(rotated ? -20 : 20))
    }

    private var eyeView: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "FFD700"))
                .frame(width: cellSize * 0.25, height: cellSize * 0.25)

            Circle()
                .fill(Color.black)
                .frame(width: cellSize * 0.12, height: cellSize * 0.12)
        }
    }

    private var whiskersView: some View {
        ZStack {
            // Left whiskers
            VStack(spacing: cellSize * 0.05) {
                whiskerLine
                    .rotationEffect(.degrees(-emotion.whiskerAngle))
                whiskerLine
                whiskerLine
                    .rotationEffect(.degrees(emotion.whiskerAngle))
            }
            .offset(x: -cellSize * 0.25, y: cellSize * 0.05)

            // Right whiskers
            VStack(spacing: cellSize * 0.05) {
                whiskerLine
                    .rotationEffect(.degrees(emotion.whiskerAngle))
                whiskerLine
                whiskerLine
                    .rotationEffect(.degrees(-emotion.whiskerAngle))
            }
            .offset(x: cellSize * 0.25, y: cellSize * 0.05)
        }
    }

    private var whiskerLine: some View {
        Rectangle()
            .fill(Color(hex: "333333"))
            .frame(width: cellSize * 0.2, height: cellSize * 0.02)
    }

    // MARK: - Cat Body
    private var catBodyView: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        catColor,
                        catColor.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: catColor.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
