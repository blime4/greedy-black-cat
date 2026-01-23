import SwiftUI

struct RibbonTrailView: View {
    let trailPoints: [TrailPoint]
    let comboCount: Int
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            if trailPoints.count >= 2 {
                // Draw ribbon segments
                ForEach(Array(trailPoints.enumerated()), id: \.element.id) { index, point in
                    if index < trailPoints.count - 1 {
                        let nextPoint = trailPoints[index + 1]
                        let progress = 1.0 - (Double(index) / Double(trailPoints.count))

                        let fromX = CGFloat(point.position.x) * cellSize + cellSize / 2
                        let fromY = CGFloat(point.position.y) * cellSize + cellSize / 2
                        let toX = CGFloat(nextPoint.position.x) * cellSize + cellSize / 2
                        let toY = CGFloat(nextPoint.position.y) * cellSize + cellSize / 2

                        RibbonSegment(
                            from: CGPoint(x: fromX, y: fromY),
                            to: CGPoint(x: toX, y: toY),
                            width: cellSize * 0.4 * CGFloat(progress),
                            color: ribbonColor(for: index),
                            opacity: point.alpha * 0.6,
                            progress: progress
                        )
                    }
                }

                // Ribbon nodes (joints)
                ForEach(Array(trailPoints.enumerated()), id: \.element.id) { index, point in
                    let progress = 1.0 - (Double(index) / Double(trailPoints.count))

                    let posX = CGFloat(point.position.x) * cellSize + cellSize / 2
                    let posY = CGFloat(point.position.y) * cellSize + cellSize / 2

                    Circle()
                        .fill(ribbonColor(for: index).opacity(point.alpha * 0.8))
                        .frame(width: cellSize * 0.3 * CGFloat(progress), height: cellSize * 0.3 * CGFloat(progress))
                        .position(x: posX, y: posY)
                        .blur(radius: 3)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func ribbonColor(for index: Int) -> Color {
        if comboCount >= 5 {
            return .yellow
        } else if comboCount >= 3 {
            return .orange
        } else {
            return Color.accentColor
        }
    }
}

struct RibbonSegment: View {
    let from: CGPoint
    let to: CGPoint
    let width: CGFloat
    let color: Color
    let opacity: Double
    let progress: Double

    var body: some View {
        Path { path in
            path.move(to: from)

            // Create curved ribbon
            let midPoint = CGPoint(
                x: (from.x + to.x) / 2,
                y: (from.y + to.y) / 2
            )

            // Control point for curve
            let controlPoint = CGPoint(
                x: midPoint.x,
                y: midPoint.y + width * 0.5
            )

            path.addQuadCurve(
                to: to,
                control: controlPoint
            )
        }
        .stroke(
            LinearGradient(
                colors: [
                    color.opacity(opacity),
                    color.opacity(opacity * 0.5)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: width,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .blur(radius: 2)
        .shadow(color: color.opacity(0.3), radius: 4)
    }
}

// Floating score numbers
struct FloatingScoreView: View {
    let points: Int
    let position: CGPoint
    let comboMultiplier: Int

    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 2) {
            if comboMultiplier > 1 {
                Text("\(comboMultiplier)x")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
            }

            Text("+\(points)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.2), radius: 3)
        )
        .offset(y: offset)
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                offset = -60
                opacity = 0
                scale = 1.3
            }
        }
    }
}

// Danger zone indicators for obstacles
struct DangerZoneView: View {
    let obstacles: [Obstacle]
    let catPosition: Position
    let gridWidth: Int
    let gridHeight: Int
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            ForEach(obstacles) { obstacle in
                let distance = abs(obstacle.position.x - catPosition.x) + abs(obstacle.position.y - catPosition.y)

                if distance < 4 {
                    let intensity = 1.0 - (Double(distance) / 4.0)

                    // Warning circle around obstacle
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(intensity * 0.8),
                                    Color.orange.opacity(intensity * 0.4)
                                ],
                                startPoint: .center,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        .frame(
                            width: cellSize * (1.5 + intensity),
                            height: cellSize * (1.5 + intensity)
                        )
                        .position(
                            x: CGFloat(obstacle.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(obstacle.position.y) * cellSize + cellSize / 2
                        )
                        .opacity(intensity)
                        .blur(radius: 3)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: intensity
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// Toast notification system
struct ToastNotificationView: View {
    let message: String
    let icon: String
    let type: ToastType

    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    @State private var isShowing = true

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Text(icon)
                .font(.system(size: 32))

            // Message
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(type.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(type.backgroundColor)
                .shadow(color: type.shadowColor, radius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(type.borderColor, lineWidth: 2)
        )
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            showToast()
        }
    }

    private func showToast() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            offset = 0
            opacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            hideToast()
        }
    }

    private func hideToast() {
        withAnimation(.easeIn(duration: 0.3)) {
            offset = -100
            opacity = 0
        }
    }
}

enum ToastType {
    case achievement
    case milestone
    case boss
    case combo
    case warning

    var backgroundColor: Color {
        switch self {
        case .achievement: return Color.purple.opacity(0.9)
        case .milestone: return Color.blue.opacity(0.9)
        case .boss: return Color.red.opacity(0.9)
        case .combo: return Color.orange.opacity(0.9)
        case .warning: return Color.yellow.opacity(0.9)
        }
    }

    var shadowColor: Color {
        switch self {
        case .achievement: return Color.purple.opacity(0.5)
        case .milestone: return Color.blue.opacity(0.5)
        case .boss: return Color.red.opacity(0.5)
        case .combo: return Color.orange.opacity(0.5)
        case .warning: return Color.yellow.opacity(0.5)
        }
    }

    var borderColor: Color {
        switch self {
        case .achievement: return Color.white.opacity(0.3)
        case .milestone: return Color.cyan.opacity(0.5)
        case .boss: return Color.white.opacity(0.5)
        case .combo: return Color.yellow.opacity(0.5)
        case .warning: return Color.red.opacity(0.5)
        }
    }

    var localizedDescription: String {
        switch self {
        case .achievement: return "Achievement Unlocked!"
        case .milestone: return "Milestone Reached!"
        case .boss: return "Boss Battle!"
        case .combo: return "Combo Streak!"
        case .warning: return "Warning!"
        }
    }
}

// Glow pulse synchronized with game pulse
struct GlowPulseView: View {
    let pulseValue: CGFloat
    let color: Color
    let radius: CGFloat

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(color.opacity(pulseValue * 0.3))
                .frame(width: radius * 2, height: radius * 2)
                .blur(radius: 10)

            // Middle ring
            Circle()
                .stroke(color.opacity(pulseValue * 0.5), lineWidth: 3)
                .frame(width: radius * 1.5, height: radius * 1.5)

            // Inner core
            Circle()
                .fill(color.opacity(pulseValue * 0.8))
                .frame(width: radius, height: radius)
        }
        .allowsHitTesting(false)
    }
}

// Speed lines during high speed
struct SpeedLinesOverlay: View {
    let isActive: Bool
    let direction: Direction
    let intensity: CGFloat

    @State private var lineOffset: CGFloat = 0

    var body: some View {
        if isActive {
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    let isVertical = direction == .up || direction == .down
                    let offset = (lineOffset + CGFloat(index) * 30).truncatingRemainder(dividingBy: 200)

                    Rectangle()
                        .fill(Color.white.opacity(0.3 * intensity))
                        .frame(
                            width: isVertical ? 2 : 80,
                            height: isVertical ? 80 : 2
                        )
                        .offset(
                            x: isVertical ? CGFloat(index) * 50 - 100 : offset,
                            y: isVertical ? offset : CGFloat(index) * 50 - 100
                        )
                        .blur(radius: 2)
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 0.3).repeatForever(autoreverses: false)) {
            lineOffset = 200
        }
    }
}

// Screen shake intensifier
struct ScreenShakeIntensifier: ViewModifier {
    let intensity: CGFloat
    let direction: Direction

    @State private var isShaking = false

    func body(content: Content) -> some View {
        content
            .offset(
                x: shakeOffset(isX: true),
                y: shakeOffset(isX: false)
            )
            .onChange(of: intensity) { _, newIntensity in
                if newIntensity > 5 {
                    triggerShake()
                }
            }
    }

    private func shakeOffset(isX: Bool) -> CGFloat {
        guard isShaking else { return 0 }

        switch direction {
        case .up:
            return isX ? CGFloat.random(in: -intensity...intensity) * 0.3 : -intensity
        case .down:
            return isX ? CGFloat.random(in: -intensity...intensity) * 0.3 : intensity
        case .left:
            return isX ? -intensity : CGFloat.random(in: -intensity...intensity) * 0.3
        case .right:
            return isX ? intensity : CGFloat.random(in: -intensity...intensity) * 0.3
        }
    }

    private func triggerShake() {
        guard !isShaking else { return }
        isShaking = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShaking = false
        }
    }
}

extension View {
    func screenShakeModifier(intensity: CGFloat, direction: Direction) -> some View {
        self.modifier(ScreenShakeIntensifier(intensity: intensity, direction: direction))
    }
}
