import SwiftData
import SwiftUI

@main
struct DriftingThoughtsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Thought.self)
    }
}
