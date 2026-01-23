import SwiftUI

struct ComboChainView: View {
    let comboCount: Int
    let cellSize: CGFloat
    let catPosition: CGPoint

    @State private var linkOpacity: [Double] = []
    @State private var linkScale: [CGFloat] = []

    var body: some View {
        if comboCount >= 3 {
            ZStack {
                // Draw chain links behind the cat
                ForEach(0..<min(comboCount - 1, 5), id: \.self) { index in
                    let progress = Double(index + 1) / Double(min(comboCount - 1, 5) + 1)
                    let linkPosition = CGPoint(
                        x: catPosition.x - CGFloat(progress) * cellSize * 0.8,
                        y: catPosition.y - CGFloat(progress) * cellSize * 0.3
                    )

                    ChainLink(
                        index: index,
                        comboCount: comboCount,
                        cellSize: cellSize,
                        opacity: index < linkOpacity.count ? linkOpacity[index] : 0,
                        scale: index < linkScale.count ? linkScale[index] : 1
                    )
                    .position(linkPosition)
                }
            }
            .onAppear {
                initializeLinks()
            }
            .onChange(of: comboCount) { _, newCount in
                updateLinks(for: newCount)
            }
        }
    }

    private func initializeLinks() {
        let count = min(comboCount - 1, 5)
        linkOpacity = Array(repeating: 0.0, count: max(count, 5))
        linkScale = Array(repeating: 1.0, count: max(count, 5))

        // Animate links appearing one by one
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if i < linkOpacity.count {
                        linkOpacity[i] = 0.8
                        linkScale[i] = 1.2
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if i < linkScale.count {
                            linkScale[i] = 1.0
                        }
                    }
                }
            }
        }
    }

    private func updateLinks(for count: Int) {
        let linkCount = min(count - 1, 5)

        // Add new links
        while linkOpacity.count < linkCount {
            linkOpacity.append(0.0)
            linkScale.append(1.0)
        }

        // Animate new links
        if linkCount > 0 {
            let newLinkIndex = linkCount - 1
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if newLinkIndex < linkOpacity.count {
                    linkOpacity[newLinkIndex] = 0.8
                    linkScale[newLinkIndex] = 1.3
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if newLinkIndex < linkScale.count {
                        linkScale[newLinkIndex] = 1.0
                    }
                }
            }
        }
    }
}

struct ChainLink: View {
    let index: Int
    let comboCount: Int
    let cellSize: CGFloat
    let opacity: Double
    let scale: CGFloat

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(linkColor.opacity(0.3))
                .frame(width: cellSize * 0.35 * scale, height: cellSize * 0.35 * scale)
                .blur(radius: 3)

            // Link circle
            Circle()
                .stroke(linkColor.opacity(opacity), lineWidth: 2)
                .frame(width: cellSize * 0.25 * scale, height: cellSize * 0.25 * scale)

            // Inner dot
            Circle()
                .fill(linkColor.opacity(opacity))
                .frame(width: cellSize * 0.1 * scale, height: cellSize * 0.1 * scale)

            // Combo number
            if comboCount >= 5 {
                Text("\(index + 1)")
                    .font(.system(size: cellSize * 0.08, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
    }

    private var linkColor: Color {
        switch comboCount {
        case 3...4:
            return .orange
        case 5:
            return .yellow
        case 6...:
            return .red
        default:
            return .white
        }
    }
}
