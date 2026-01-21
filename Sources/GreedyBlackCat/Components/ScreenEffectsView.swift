import SwiftUI

struct ScreenEffectsView: View {
    let flashIntensity: Double
    let color: Color

    var body: some View {
        ZStack {
            // Flash overlay
            color
                .opacity(flashIntensity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // White flash core
            Color.white
                .opacity(flashIntensity * 0.5)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .allowsHitTesting(false)
    }
}

struct GameOverlayView: View {
    let showAchievement: Bool
    let achievementName: String
    let achievementIcon: String
    var flashIntensity: Double = 0

    var body: some View {
        ZStack {
            if flashIntensity > 0 {
                ScreenEffectsView(flashIntensity: flashIntensity, color: .yellow)
            }

            if showAchievement {
                VStack(spacing: 12) {
                    Text(achievementIcon)
                        .font(.system(size: 60))

                    Text("Achievement Unlocked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(achievementName)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.5), radius: 20)
                )
                .scaleEffect(showAchievement ? 1.0 : 0.5)
                .opacity(showAchievement ? 1.0 : 0)
            }
        }
        .allowsHitTesting(false)
    }
}
