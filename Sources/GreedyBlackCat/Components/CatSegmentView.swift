import SwiftUI

struct CatSegmentView: View {
    let isHead: Bool
    let direction: Direction
    let cellSize: CGFloat

    @State private var mouthScale: CGFloat = 1.0
    @State private var appearScale: CGFloat = 0.0

    var body: some View {
        ZStack {
            if isHead {
                catHeadView
            } else {
                catBodyView
            }
        }
        .frame(width: cellSize * 0.9, height: cellSize * 0.9)
        .scaleEffect(appearScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: appearScale)
        .onAppear {
            appearScale = 1.0
        }
    }

    // MARK: - Cat Head
    private var catHeadView: some View {
        ZStack {
            // Main head shape
            RoundedRectangle(cornerRadius: cellSize * 0.3)
                .fill(Color(hex: "1A1A1A"))

            // Ears
            HStack(spacing: cellSize * 0.5) {
                earView(rotated: false)
                earView(rotated: true)
            }
            .offset(y: -cellSize * 0.15)

            // Eyes
            HStack(spacing: cellSize * 0.15) {
                eyeView
                eyeView
            }
            .offset(y: -cellSize * 0.05)

            // Nose
            Triangle()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: cellSize * 0.15, height: cellSize * 0.12)
                .offset(y: cellSize * 0.08)

            // Mouth (slight smile with animation)
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: 1, y: 0),
                    control: CGPoint(x: 0.5, y: 1 * mouthScale)
                )
            }
            .stroke(Color(hex: "333333"), lineWidth: cellSize * 0.03)
            .frame(width: cellSize * 0.3, height: cellSize * 0.1)
            .offset(y: cellSize * 0.15)
            .onAppear {
                // Gentle mouth animation
                withAnimation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                ) {
                    mouthScale = 0.6
                }
            }

            // Whiskers
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
                whiskerLine
                whiskerLine
            }
            .offset(x: -cellSize * 0.25, y: cellSize * 0.05)

            // Right whiskers
            VStack(spacing: cellSize * 0.05) {
                whiskerLine
                whiskerLine
                whiskerLine
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
                        Color(hex: "1A1A1A"),
                        Color(hex: "2D2D2D")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
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
