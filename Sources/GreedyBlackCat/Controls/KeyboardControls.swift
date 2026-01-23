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
                // 检查箭头键和特殊键
                switch keyPress.key {
                case .upArrow:
                    viewModel.changeDirection(.up)
                    return .handled
                case .downArrow:
                    viewModel.changeDirection(.down)
                    return .handled
                case .leftArrow:
                    viewModel.changeDirection(.left)
                    return .handled
                case .rightArrow:
                    viewModel.changeDirection(.right)
                    return .handled
                case .space:
                    if viewModel.gameState.isPlaying {
                        viewModel.performDash()
                        return .handled
                    } else if viewModel.gameState.isPaused {
                        viewModel.resumeGame()
                        return .handled
                    }
                case .escape:
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
                case .tab:
                    viewModel.performDash()
                    return .handled
                default:
                    break
                }

                // 检查字母键 (WASD) + Shift for dash
                let chars = keyPress.characters.lowercased()
                if chars == "w" {
                    viewModel.changeDirection(.up)
                    return .handled
                } else if chars == "s" {
                    viewModel.changeDirection(.down)
                    return .handled
                } else if chars == "a" {
                    viewModel.changeDirection(.left)
                    return .handled
                } else if chars == "d" {
                    viewModel.changeDirection(.right)
                    return .handled
                } else if chars == " " {
                    viewModel.performDash()
                    return .handled
                }

                return .ignored
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
