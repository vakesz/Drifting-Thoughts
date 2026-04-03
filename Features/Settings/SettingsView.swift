import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var allThoughts: [Thought]
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section("Profile") {
                TextField("Author name", text: $settings.authorName)
                    .textInputAutocapitalization(.words)
                    .characterLimit(DriftLayout.authorNameCharacterLimit, on: $settings.authorName)

                Toggle("Show author on cards", isOn: $settings.showAuthorOnCard)
            }

            Section("Cards") {
                Toggle("Show watermark", isOn: $settings.showWatermark)
            }

            Section("Streak") {
                Picker("Frequency", selection: $settings.streakFrequency) {
                    ForEach(StreakFrequency.allCases) { frequency in
                        Text(frequency.label).tag(frequency)
                    }
                }
            }

            Section("Data") {
                HStack {
                    Text("Total thoughts")
                    Spacer()
                    Text(verbatim: "\(allThoughts.count)")
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(verbatim: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
