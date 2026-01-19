import SwiftUI

struct MainMenuView: View {
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "GreedyBlackCatHighScore")
    @State private var showingGame = false
    @State private var gameViewModel: GameViewModel?

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "FFF8E7"),
                        Color(hex: "FFE4CC")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Title
                    VStack(spacing: 16) {
                        Text("🐱")
                            .font(.system(size: 80))
                        Text("贪吃的黑猫")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                        Text("Greedy Black Cat")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // High Score
                    VStack(spacing: 8) {
                        Text("High Score")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(highScore)")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "FFD700"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.8))
                            .shadow(radius: 5)
                    )

                    Spacer()

                    // Start Button
                    Button(action: {
                        gameViewModel = GameViewModel()
                        showingGame = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Start Game")
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3), value: showingGame)

                    // Secondary Buttons
                    HStack(spacing: 40) {
                        Button("About") {
                            // Show about sheet
                        }
                        .font(.body)
                        .foregroundColor(.secondary)

                        #if os(macOS)
                        Button("Settings") {
                            // Open settings
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                        #endif
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingGame) {
            if let viewModel = gameViewModel {
                GameContainerView(viewModel: viewModel)
            }
        }
        .onAppear {
            highScore = UserDefaults.standard.integer(forKey: "GreedyBlackCatHighScore")
        }
    }
}

// Container view for the game to handle dismissal
struct GameContainerView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if viewModel.gameState.isPlaying || viewModel.gameState.isPaused {
                GameView(viewModel: viewModel)
            } else if viewModel.gameState.isGameOver {
                GameOverView(
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    onRestart: {
                        viewModel.restartGame()
                    },
                    onMainMenu: {
                        dismiss()
                    }
                )
            }
        }
        #if os(iOS)
        .navigationBarBackButtonHidden(true)
        #endif
        .onReceive(viewModel.$gameState) { newState in
            if newState == .menu {
                dismiss()
            }
        }
    }
}

#Preview {
    MainMenuView()
}
