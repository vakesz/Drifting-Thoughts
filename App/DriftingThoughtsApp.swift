import SwiftData
import SwiftUI

@main
struct DriftingThoughtsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppSettings.shared)
        }
        .modelContainer(for: Thought.self)
    }
}
