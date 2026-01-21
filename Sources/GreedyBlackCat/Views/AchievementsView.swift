import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stats: GameStats = GameStats.load()

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
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 20)

                        // Header
                        VStack(spacing: 8) {
                            Text("🏆")
                                .font(.system(size: 60))
                            Text("Achievements")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                        }

                        // Stats Overview
                        HStack(spacing: 16) {
                            StatBox(icon: "🎮", label: "Games", value: "\(stats.gamesPlayed)")
                            StatBox(icon: "🐟", label: "Fish Eaten", value: "\(stats.totalFoodEaten)")
                            StatBox(icon: "⭐", label: "Power-ups", value: "\(stats.totalPowerUpsCollected)")
                        }
                        .padding(.horizontal)

                        // Achievements Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(Achievement.allCases, id: \.rawValue) { achievement in
                                AchievementCard(
                                    achievement: achievement,
                                    isUnlocked: achievement.isUnlocked(stats: stats)
                                )
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            #endif
        }
        .onAppear {
            stats = GameStats.load()
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.icon)
                .font(.system(size: 40))
                .opacity(isUnlocked ? 1.0 : 0.3)

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.white.opacity(0.9) : Color.gray.opacity(0.1))
                .shadow(color: isUnlocked ? Color.black.opacity(0.05) : .clear, radius: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct StatBox: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            Text(value)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.05), radius: 3)
        )
    }
}
