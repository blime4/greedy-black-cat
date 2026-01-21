import SwiftUI

struct MainMenuView: View {
    @State private var selectedMode: GameMode = .classic
    @State private var showingGame = false
    @State private var showingAbout = false
    @State private var showingSettings = false
    @State private var showingAchievements = false
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

                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 20)

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

                        // Game Mode Selection
                        VStack(spacing: 16) {
                            Text("Select Game Mode")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(GameMode.allCases, id: \.rawValue) { mode in
                                    GameModeCard(
                                        mode: mode,
                                        isSelected: selectedMode == mode,
                                        highScore: UserDefaults.standard.integer(
                                            forKey: "GreedyBlackCatHighScore_\(mode.rawValue)"
                                        )
                                    ) {
                                        selectedMode = mode
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Start Button
                        Button(action: {
                            let vm = GameViewModel(gameMode: selectedMode)
                            vm.startGame()
                            gameViewModel = vm
                            showingGame = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Play \(selectedMode.displayName)")
                            }
                            .font(.system(size: 20, weight: .semibold))
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
                        .buttonStyle(GameButtonStyle(isPrimary: true))
                        .pressEffect()

                        // Secondary Buttons
                        HStack(spacing: 30) {
                            Button("About") {
                                showingAbout = true
                            }
                            .font(.body)
                            .foregroundColor(.secondary)
                            .pressEffect()

                            Button("🏆 Achievements") {
                                showingAchievements = true
                            }
                            .font(.body)
                            .foregroundColor(.secondary)
                            .pressEffect()

                            #if os(macOS)
                            Button("Settings") {
                                showingSettings = true
                            }
                            .font(.body)
                            .foregroundColor(.secondary)
                            .pressEffect()
                            #endif
                        }

                        Spacer()
                    }
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showingGame) {
            if let viewModel = gameViewModel {
                GameContainerView(viewModel: viewModel)
            }
        }
        #else
        .sheet(isPresented: $showingGame) {
            if let viewModel = gameViewModel {
                GameContainerView(viewModel: viewModel)
            }
        }
        #endif
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
        }
        #if os(macOS)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        #endif
    }
}

// Game Mode Card Component
struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    let highScore: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(mode.icon)
                    .font(.system(size: 40))
                Text(mode.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(mode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("\(highScore)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.white.opacity(0.8))
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(GameButtonStyle(isPrimary: false))
    }
}

// Container view for the game to handle dismissal
struct GameContainerView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if !viewModel.gameState.isMenu {
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
            } else {
                // Fallback loading view if state is still .menu
                ProgressView("Loading...")
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
