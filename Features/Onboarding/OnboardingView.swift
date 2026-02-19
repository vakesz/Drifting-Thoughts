import SwiftUI

struct OnboardingView: View {
    @Bindable private var settings = AppSettings.shared
    @State private var draftAuthorName = AppSettings.shared.authorName

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your name (optional)", text: $draftAuthorName)
                        .textInputAutocapitalization(.words)
                        .onChange(of: draftAuthorName) { _, newValue in
                            draftAuthorName = String(newValue.prefix(DriftLayout.authorNameCharacterLimit))
                        }

                    Toggle("Show author on cards", isOn: $settings.showAuthorOnCard)
                }

                Section {
                    Button("Continue") {
                        settings.authorName = draftAuthorName.trimmingCharacters(in: .whitespacesAndNewlines)
                        settings.hasCompletedOnboarding = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Welcome")
        }
    }
}
