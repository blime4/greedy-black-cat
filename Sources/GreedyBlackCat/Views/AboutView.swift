import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

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

                        // App Icon
                        Text("🐱")
                            .font(.system(size: 100))
                            .shadow(radius: 10)

                        // Title
                        VStack(spacing: 8) {
                            Text("贪吃的黑猫")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                            Text("Greedy Black Cat")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }

                        // Version
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)

                        Divider()
                            .padding(.vertical, 10)

                        // Description
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("About the Game")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                Text("Greedy Black Cat is a classic snake-style game where you control a hungry cat trying to catch fish!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text("贪吃的黑猫是一款经典的贪吃蛇风格游戏，你控制一只饥饿的黑猫尝试捕抓鱼!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.7))
                                    .shadow(radius: 3)
                            )

                            // How to Play
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How to Play")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                instructionRow(icon: "🐟", text: "Eat fish to grow and earn points")
                                instructionRow(icon: "⚠️", text: "Avoid hitting walls and yourself")
                                instructionRow(icon: "🏆", text: "Try to beat your high score!")

                                #if os(macOS)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Controls (Mac)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                    controlRow(keys: "↑ ↓ ← →", action: "Move")
                                    controlRow(keys: "W A S D", action: "Move (alternative)")
                                    controlRow(keys: "Space / Esc", action: "Pause")
                                }
                                #endif

                                #if os(iOS)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Controls (iOS)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                    controlRow(keys: "Swipe", action: "Move")
                                    controlRow(keys: "D-Pad Buttons", action: "Move")
                                }
                                #endif
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.7))
                                    .shadow(radius: 3)
                            )

                            // Fish Types
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fish Types")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                fishTypeRow(color: Color(hex: "C0C0C0"), name: "Small Fish", points: "10 pts")
                                fishTypeRow(color: Color(hex: "FF8C00"), name: "Medium Fish", points: "20 pts")
                                fishTypeRow(color: Color(hex: "FFD700"), name: "Large Fish", points: "50 pts")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.7))
                                    .shadow(radius: 3)
                            )
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
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            #endif
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    private func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func controlRow(keys: String, action: String) -> some View {
        HStack(spacing: 12) {
            Text(keys)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
            Text(action)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func fishTypeRow(color: Color, name: String, points: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
            Text(name)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(points)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
