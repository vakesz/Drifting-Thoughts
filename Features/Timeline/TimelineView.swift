import SwiftData
import SwiftUI

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]
    @State private var viewModel = TimelineViewModel()
    @State private var isShowingSettings = false

    private var filteredThoughts: [Thought] {
        guard !viewModel.searchText.isEmpty else { return thoughts }
        let query = viewModel.searchText.lowercased()
        return thoughts.filter { thought in
            thought.text.lowercased().contains(query) ||
            thought.title.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if thoughts.isEmpty {
                    emptyState
                } else {
                    thoughtList
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search thoughts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No thoughts yet", systemImage: "text.bubble")
        } description: {
            Text("let one drift...")
        }
    }

    // MARK: - Thought List

    private var thoughtList: some View {
        List {
            streakHeader

            ForEach(filteredThoughts) { thought in
                NavigationLink {
                    CardPreviewView(
                        title: thought.title,
                        text: thought.text,
                        existingThought: thought,
                    )
                } label: {
                    ThoughtRowView(thought: thought)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.deleteThought(thought, in: modelContext)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        viewModel.toggleFavorite(thought)
                    } label: {
                        Label(
                            thought.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: thought.isFavorite ? "star.slash" : "star",
                        )
                    }
                    .tint(.yellow)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Streak Header

    private var streakHeader: some View {
        let streak = viewModel.calculateStreak(from: thoughts)
        return Group {
            if streak > 0 {
                HStack(spacing: DriftLayout.spacingSM) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.brandAccent)
                        .symbolEffect(.bounce, value: streak)
                    Text("\(streak) day streak")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .padding(.vertical, DriftLayout.spacingXS)
            }
        }
    }
}
