import SwiftUI

struct HitEffectView: View {
    let position: CGPoint
    let color: Color
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 3)
            .frame(width: 40, height: 40)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 2.5
                    opacity = 0
                }
            }
    }
}

struct ShockwaveView: View {
    let position: CGPoint
    let color: Color
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0.8

    var body: some View {
        ZStack {
            // Multiple rings for shockwave effect
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(0.6 - Double(index) * 0.2), lineWidth: 2)
                    .frame(width: 30, height: 30)
                    .scaleEffect(scale - CGFloat(index) * 0.3)
                    .opacity(opacity - Double(index) * 0.2)
            }
        }
        .position(position)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 3
                opacity = 0
            }
        }
    }
}
