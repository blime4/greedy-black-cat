import SwiftUI

struct SpeedLinesView: View {
    let isDashing: Bool
    let direction: Direction
    let gridSize: CGFloat

    @State private var lineOffset: CGFloat = 0

    var body: some View {
        if isDashing {
            ZStack {
                // Create speed lines based on direction
                ForEach(0..<8, id: \.self) { index in
                    SpeedLine(
                        direction: direction,
                        offset: lineOffset + CGFloat(index) * (gridSize / 8),
                        gridSize: gridSize
                    )
                }
            }
            .opacity(isDashing ? 0.6 : 0)
            .onAppear {
                withAnimation(.linear(duration: 0.3).repeatForever(autoreverses: false)) {
                    lineOffset = gridSize
                }
            }
        }
    }
}

struct SpeedLine: View {
    let direction: Direction
    let offset: CGFloat
    let gridSize: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white.opacity(0.5))
            .frame(width: lineWidth, height: lineHeight)
            .offset(computedOffset)
            .rotationEffect(.degrees(rotationAngle))
    }

    private var lineWidth: CGFloat {
        gridSize * 0.02
    }

    private var lineHeight: CGFloat {
        gridSize * 0.3
    }

    private var computedOffset: CGSize {
        switch direction {
        case .up: return CGSize(width: 0, height: -offset)
        case .down: return CGSize(width: 0, height: offset)
        case .left: return CGSize(width: -offset, height: 0)
        case .right: return CGSize(width: offset, height: 0)
        }
    }

    private var rotationAngle: Double {
        switch direction {
        case .up: return 90
        case .down: return 270
        case .left: return 180
        case .right: return 0
        }
    }
}
