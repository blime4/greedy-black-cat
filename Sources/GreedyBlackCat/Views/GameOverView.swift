import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let onRestart: () -> Void
    let onMainMenu: () -> Void

    var isNewHighScore: Bool {
        score >= highScore && score > 0
    }

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Game Over Title
                Text("Game Over")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                // New High Score Badge
                if isNewHighScore {
                    HStack(spacing: 8) {
                        Text("🏆")
                        Text("New High Score!")
                        Text("🏆")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.2))
                    )
                }

                // Score Display
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Final Score")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.system(size: 56, weight: .bold, design: .monospaced))
                            .foregroundColor(.accentColor)
                    }

                    Divider()
                        .background(Color(.gray.opacity(0.3)))

                    HStack(spacing: 4) {
                        Text("High Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(highScore)")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Play Again")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }

                    Button(action: onMainMenu) {
                        HStack {
                            Image(systemName: "house")
                            Text("Main Menu")
                        }
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
            }
            .padding(40)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(20)
            .padding(40)
        }
    }
}
