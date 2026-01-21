import SwiftUI

struct ScorePopupView: View {
    let points: Int
    let position: CGPoint
    let cellSize: CGFloat

    @State private var opacity: Double = 1.0
    @State private var offset: CGFloat = 0

    var body: some View {
        Text("+\(points)")
            .font(.system(size: cellSize * 0.4, weight: .bold))
            .foregroundColor(scoreColor)
            .shadow(color: scoreColor.opacity(0.5), radius: 3)
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 0.8)
                ) {
                    opacity = 0
                    offset = -cellSize * 0.8
                }
            }
    }

    private var scoreColor: Color {
        switch points {
        case 10:
            return Color(hex: "C0C0C0") // Silver
        case 20:
            return Color(hex: "FF8C00") // Orange
        case 50:
            return Color(hex: "FFD700") // Gold
        default:
            return .accentColor
        }
    }
}
