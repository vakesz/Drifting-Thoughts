import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var searchText: String
    let thoughts: [Thought]

    private var filteredThoughts: [Thought] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return thoughts.filter { thought in
            thought.text.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    emptyPrompt
                } else if filteredThoughts.isEmpty {
                    noResults
                } else {
                    resultsList
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Empty Prompt

    private var emptyPrompt: some View {
        ContentUnavailableView {
            Label("Search thoughts", systemImage: "magnifyingglass")
        } description: {
            Text("find a drifting thought...")
        }
    }

    // MARK: - No Results

    private var noResults: some View {
        ContentUnavailableView.search(text: searchText)
    }

    // MARK: - Results

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: DriftLayout.spacingMD) {
                ForEach(filteredThoughts) { thought in
                    NavigationLink {
                        CardDetailView(
                            text: thought.text,
                            existingThought: thought
                        )
                    } label: {
                        CardView(thought: thought, style: thought.style)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            thought.isFavorite.toggle()
                        } label: {
                            Label(
                                thought.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: thought.isFavorite ? "star.slash" : "star"
                            )
                        }

                        Button(role: .destructive) {
                            modelContext.delete(thought)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.horizontal, DriftLayout.spacingMD)
                }
            }
            .padding(.vertical, DriftLayout.spacingSM)
        }
    }
}
