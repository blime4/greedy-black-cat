import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let onRestart: () -> Void
    let onMainMenu: () -> Void

    @State private var showContent = false
    @State private var scoreScale: CGFloat = 0.5
    @State private var trophyRotation: Double = 0

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
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                // New High Score Badge with animation
                if isNewHighScore {
                    HStack(spacing: 8) {
                        Text("🏆")
                            .rotationEffect(.degrees(trophyRotation))
                        Text("New High Score!")
                        Text("🏆")
                            .rotationEffect(.degrees(-trophyRotation))
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.2))
                    )
                    .scaleEffect(showContent ? 1 : 0)
                    .shadow(color: .yellow.opacity(0.5), radius: 15)
                }

                // Score Display
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Final Score")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.accentColor)
                            .scaleEffect(scoreScale)
                    }

                    Divider()

                    HStack(spacing: 4) {
                        Text("High Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(highScore)")
                            .font(.system(.body))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .scaleEffect(showContent ? 1 : 0.8)

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Play Again")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                    .buttonStyle(GameButtonStyle(isPrimary: true))
                    .pressEffect()

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
                    .buttonStyle(GameButtonStyle(isPrimary: false))
                    .pressEffect()
                }
                .padding(.horizontal, 32)
            }
            .padding(40)
            .background(backgroundColor)
            .cornerRadius(20)
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                scoreScale = 1.0
            }
            if isNewHighScore {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: true).delay(0.4)) {
                    trophyRotation = 15
                }
            }
        }
    }
}
