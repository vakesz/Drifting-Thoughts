import Foundation
import SwiftData

@MainActor
@Observable
final class TimelineViewModel {
    var searchText: String = ""

    func deleteThought(_ thought: Thought, in context: ModelContext) {
        context.delete(thought)
    }

    func toggleFavorite(_ thought: Thought) {
        thought.isFavorite.toggle()
    }

    /// Calculate the current writing streak (consecutive days with at least one thought)
    func calculateStreak(from thoughts: [Thought]) -> Int {
        guard !thoughts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get unique days that have thoughts, sorted descending
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
