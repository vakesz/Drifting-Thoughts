import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Compose", systemImage: "pencil.line") {
                ComposeView()
            }
            Tab("Timeline", systemImage: "clock") {
                TimelineView()
            }
        }
        .tint(Color.brandAccent)
    }
}
