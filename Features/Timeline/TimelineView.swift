import SwiftData
import SwiftUI

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]
    @State private var isShowingSettings = false
    @State private var groupedThoughts: [(date: Date, thoughts: [Thought])] = []
    @State private var thoughtToDelete: Thought?

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
            .onChange(of: thoughts, initial: true) {
                groupedThoughts = Self.groupThoughts(thoughts)
            }
            .confirmationDialog(
                "Delete this thought?",
                isPresented: Binding(
                    get: { thoughtToDelete != nil },
                    set: { if !$0 { thoughtToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let thought = thoughtToDelete {
                        modelContext.delete(thought)
                    }
                }
            } message: {
                Text("This can't be undone.")
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
                        .thoughtContextMenu(thought: thought) {
                            thoughtToDelete = thought
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

    // MARK: - Grouping

    private static func groupThoughts(_ thoughts: [Thought]) -> [(date: Date, thoughts: [Thought])] {
        Dictionary(grouping: thoughts) { thought in
            Calendar.current.startOfDay(for: thought.createdAt)
        }
        .sorted { $0.key > $1.key }
        .map { (date: $0.key, thoughts: $0.value) }
    }
}
