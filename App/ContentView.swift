import SwiftData
import SwiftUI

struct ContentView: View {
    @Bindable private var settings = AppSettings.shared
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]
    @State private var searchText = ""

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
            Tab(role: .search) {
                SearchView(searchText: $searchText, thoughts: thoughts)
                    .searchable(text: $searchText, prompt: "Search thoughts")
            }
        }
    }
}
