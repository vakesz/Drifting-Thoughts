import SwiftUI

struct ContentView: View {
    @Bindable private var settings = AppSettings.shared

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView()
            }
        }
        .tint(Color.brandAccent)
    }

    private var mainTabs: some View {
        TabView {
            Tab("Compose", systemImage: "pencil.line") {
                ComposeView()
            }
            Tab("Timeline", systemImage: "clock") {
                TimelineView()
            }
        }
    }
}
