import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Binding var searchText: String
    let thoughts: [Thought]

    @State private var thoughtToDelete: Thought?
    @State private var isShowingDeleteConfirmation = false

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
            .confirmationDialog(
                "Delete this thought?",
                isPresented: $isShowingDeleteConfirmation,
                presenting: thoughtToDelete,
                actions: { thought in
                    Button("Delete", role: .destructive) {
                        modelContext.delete(thought)
                    }
                },
                message: { _ in
                    Text("delete.confirmation")
                }
            )
        }
    }

    // MARK: - Empty Prompt

    private var emptyPrompt: some View {
        ContentUnavailableView {
            Label("search.empty.title", systemImage: "magnifyingglass")
        } description: {
            Text("search.empty.description")
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
                        CardView(thought: thought, style: thought.style, settings: settings)
                    }
                    .buttonStyle(.plain)
                    .thoughtContextMenu(thought: thought) {
                        thoughtToDelete = thought
                        isShowingDeleteConfirmation = true
                    }
                    .padding(.horizontal, DriftLayout.spacingMD)
                }
            }
            .padding(.vertical, DriftLayout.spacingSM)
        }
    }
}
