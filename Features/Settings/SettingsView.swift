import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var allThoughts: [Thought]
    @Bindable private var settings = AppSettings.shared

    var body: some View {
        Form {
            profileSection
            cardsSection
            streakSection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Profile

    private var profileSection: some View {
        Section("Profile") {
            TextField("Author name", text: $settings.authorName)
                .textInputAutocapitalization(.words)
                .onChange(of: settings.authorName) { _, newValue in
                    settings.authorName = String(newValue.prefix(DriftLayout.authorNameCharacterLimit))
                }

            Toggle("Show author on cards", isOn: $settings.showAuthorOnCard)
        }
    }

    // MARK: - Cards

    private var cardsSection: some View {
        Section("Cards") {
            Toggle("Show watermark", isOn: $settings.showWatermark)
        }
    }

    // MARK: - Streak

    private var streakSection: some View {
        Section("Streak") {
            Picker("Frequency", selection: $settings.streakFrequency) {
                ForEach(StreakFrequency.allCases) { frequency in
                    Text(frequency.label).tag(frequency)
                }
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        Section("Data") {
            HStack {
                Text("Total thoughts")
                Spacer()
                Text("\(allThoughts.count)")
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}
