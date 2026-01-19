import SwiftUI

#if os(iOS)
struct TouchControls: ViewModifier {
    let viewModel: GameViewModel
    @State private var dragOffset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 30)
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
                    }
            )
    }
}

extension View {
    func touchControls(viewModel: GameViewModel) -> some View {
        self.modifier(TouchControls(viewModel: viewModel))
    }
}
#endif
