import SwiftUI

struct OnboardingView: View {
    @Environment(AppSettings.self) private var settings
    @State private var draftAuthorName = ""

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your name (optional)", text: $draftAuthorName)
                        .textInputAutocapitalization(.words)
                        .characterLimit(DriftLayout.authorNameCharacterLimit, on: $draftAuthorName)

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
            .onAppear { draftAuthorName = settings.authorName }
        }
    }
}
