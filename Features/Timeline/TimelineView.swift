import SwiftData
import SwiftUI

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]
    @State private var searchText = ""
    @State private var isShowingSettings = false

    private var filteredThoughts: [Thought] {
        guard !searchText.isEmpty else { return thoughts }
        let query = searchText.lowercased()
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
            .searchable(text: $searchText, prompt: "Search thoughts")
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
                    CardDetailView(
                        title: thought.title,
                        text: thought.text,
                        existingThought: thought,
                    )
                } label: {
                    ThoughtRowView(thought: thought)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        modelContext.delete(thought)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        thought.isFavorite.toggle()
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
        let streak = Self.calculateStreak(from: thoughts)
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

    // MARK: - Streak Calculation

    private static func calculateStreak(from thoughts: [Thought]) -> Int {
        guard !thoughts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let uniqueDays = Set(thoughts.map { calendar.startOfDay(for: $0.createdAt) })
            .sorted(by: >)

        guard let mostRecent = uniqueDays.first else { return 0 }

        // Streak only counts if the most recent entry is today or yesterday
        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        guard daysSinceLast <= 1 else { return 0 }

        var streak = 1
        for idx in 1..<uniqueDays.count {
            let expected = calendar.date(byAdding: .day, value: -idx, to: mostRecent)
            if let expected, calendar.isDate(uniqueDays[idx], inSameDayAs: expected) {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}
