import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var allThoughts: [Thought]
    @Bindable private var settings = AppSettings.shared

    var body: some View {
        Form {
            writingSection
            cardsSection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Writing

    private var writingSection: some View {
        Section("Writing") {
            Toggle("Auto-open keyboard", isOn: $settings.autoOpenKeyboard)
        }
    }

    // MARK: - Cards

    private var cardsSection: some View {
        Section("Cards") {
            Toggle("Show watermark", isOn: $settings.showWatermark)

            Picker("Default style", selection: $settings.defaultStyleName) {
                ForEach(CardStyle.allCases) { style in
                    Text(style.label).tag(style.rawValue)
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
