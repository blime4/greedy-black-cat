import SwiftUI
import Combine

#if os(macOS)
struct KeyboardControls: ViewModifier {
    let viewModel: GameViewModel
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focusable()
            .focused($isFocused)
            .onKeyPress { keyPress in
                switch keyPress.key {
                case .upArrow, .w:
                    viewModel.changeDirection(.up)
                    return .handled
                case .downArrow, .s:
                    viewModel.changeDirection(.down)
                    return .handled
                case .leftArrow, .a:
                    viewModel.changeDirection(.left)
                    return .handled
                case .rightArrow, .d:
                    viewModel.changeDirection(.right)
                    return .handled
                case .space, .escape:
                    if viewModel.gameState.isPlaying {
                        viewModel.pauseGame()
                    } else if viewModel.gameState.isPaused {
                        viewModel.resumeGame()
                    }
                    return .handled
                case .return:
                    if viewModel.gameState.isGameOver {
                        viewModel.restartGame()
                    }
                    return .handled
                default:
                    return .ignored
                }
            }
            .onAppear {
                isFocused = true
            }
    }
}

extension View {
    func keyboardControls(viewModel: GameViewModel) -> some View {
        self.modifier(KeyboardControls(viewModel: viewModel))
    }
}
#endif
