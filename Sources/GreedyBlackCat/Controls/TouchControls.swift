import SwiftUI

#if os(iOS)
struct TouchControls: ViewModifier {
    let viewModel: GameViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var swipeDirection: Direction?

    func body(content: Content) -> some View {
        content
            .overlay(
                // Visual swipe indicator
                Group {
                    if isDragging, let direction = swipeDirection {
                        SwipeIndicator(direction: direction)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .allowsHitTesting(false)
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation

                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height

                        if abs(horizontalAmount) > abs(verticalAmount) {
                            swipeDirection = horizontalAmount > 0 ? .right : .left
                        } else {
                            swipeDirection = verticalAmount > 0 ? .down : .up
                        }
                    }
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height

                        if abs(horizontalAmount) > abs(verticalAmount) {
                            // Horizontal swipe
                            if horizontalAmount > 0 {
                                viewModel.changeDirection(.right)
                            } else {
                                viewModel.changeDirection(.left)
                            }
                        } else {
                            // Vertical swipe
                            if verticalAmount > 0 {
                                viewModel.changeDirection(.down)
                            } else {
                                viewModel.changeDirection(.up)
                            }
                        }

                        // Reset with delay for smooth transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isDragging = false
                            swipeDirection = nil
                            dragOffset = .zero
                        }
                    }
            )
    }
}

// Visual indicator for swipe direction
struct SwipeIndicator: View {
    let direction: Direction

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 80, height: 80)

            Image(systemName: iconName)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 10)
    }

    private var iconName: String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

extension View {
    func touchControls(viewModel: GameViewModel) -> some View {
        self.modifier(TouchControls(viewModel: viewModel))
    }
}
#endif
