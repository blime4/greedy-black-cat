import SwiftUI

struct ComboMultiplierPopup: View {
    let multiplier: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            Text("\(multiplier)x")
                .font(.system(size: 48, weight: .heavy))
                .foregroundColor(multiplierColor)

            Text("COMBO")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(multiplierColor.opacity(0.3))
                .shadow(color: multiplierColor.opacity(0.5), radius: 15)
        )
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.2
            }
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.3)) {
                    scale = 0.8
                }
            }
        }
    }

    private var multiplierColor: Color {
        switch multiplier {
        case 2...3:
            return .orange
        case 4:
            return .red
        case 5:
            return .purple
        default:
            return .yellow
        }
    }
}
