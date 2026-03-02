import SwiftUI

struct ThoughtContextMenu: ViewModifier {
    let thought: Thought
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content.contextMenu {
            Button {
                thought.isFavorite.toggle()
            } label: {
                Label(
                    thought.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: thought.isFavorite ? "star.slash" : "star"
                )
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension View {
    func thoughtContextMenu(thought: Thought, onDelete: @escaping () -> Void) -> some View {
        modifier(ThoughtContextMenu(thought: thought, onDelete: onDelete))
    }
}
