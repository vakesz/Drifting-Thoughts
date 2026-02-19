import SwiftData
import SwiftUI

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]
    @State private var isShowingSettings = false

    private var groupedThoughts: [(date: Date, thoughts: [Thought])] {
        Dictionary(grouping: thoughts) { thought in
            Calendar.current.startOfDay(for: thought.createdAt)
        }
        .sorted { $0.key > $1.key }
        .map { (date: $0.key, thoughts: $0.value) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if thoughts.isEmpty {
                    emptyState
                } else {
                    thoughtTimeline
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Thought Timeline

    private var thoughtTimeline: some View {
        ScrollView {
            LazyVStack(spacing: DriftLayout.spacingMD) {
                ForEach(groupedThoughts, id: \.date) { group in
                    dateHeader(group.date)

                    ForEach(group.thoughts) { thought in
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
            }
            .padding(.vertical, DriftLayout.spacingSM)
        }
    }

    // MARK: - Date Header

    private func dateHeader(_ date: Date) -> some View {
        Text(date, format: Date.FormatStyle().month(.wide).day().year())
            .font(.title3.weight(.medium))
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DriftLayout.spacingMD)
            .padding(.top, DriftLayout.spacingMD)
    }
}
