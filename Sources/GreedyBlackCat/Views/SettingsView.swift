import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("gameSpeed") private var selectedSpeed: String = "Normal"
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("showGrid") private var showGrid: Bool = true

    private let speeds = ["Slow", "Normal", "Fast"]

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

                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 20)

                    // Title
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                    }
                    .padding(.horizontal)

                    // Settings List
                    VStack(spacing: 16) {
                        // Game Speed
                        settingRow(icon: "speedometer", title: "Game Speed") {
                            Picker("Game Speed", selection: $selectedSpeed) {
                                ForEach(speeds, id: \.self) { speed in
                                    Text(speed).tag(speed)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Sound
                        settingRow(icon: "speaker.wave.2.fill", title: "Sound Effects") {
                            Toggle("", isOn: $soundEnabled)
                                .labelsHidden()
                        }

                        // Show Grid
                        settingRow(icon: "grid", title: "Show Grid Lines") {
                            Toggle("", isOn: $showGrid)
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Info text
                    Text("Settings are saved automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)

                    // Reset High Score Button
                    Button(action: resetHighScore) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Reset High Score")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    .padding(.bottom, 20)
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
    }

    private func settingRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            Spacer()

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 3)
        )
    }

    private func resetHighScore() {
        UserDefaults.standard.set(0, forKey: "GreedyBlackCatHighScore")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
