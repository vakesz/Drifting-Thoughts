import Foundation

enum StreakFrequency: String, CaseIterable, Identifiable, Sendable {
    case daily, weekly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .daily: String(localized: "streak.frequency.daily")
        case .weekly: String(localized: "streak.frequency.weekly")
        }
    }

    var intervalDays: Int {
        switch self {
        case .daily: 1
        case .weekly: 7
        }
    }

    var streakUnit: String {
        switch self {
        case .daily: String(localized: "streak.unit.day")
        case .weekly: String(localized: "streak.unit.week")
        }
    }
}

@MainActor
@Observable
final class AppSettings {
    static let shared = AppSettings()

    var showWatermark: Bool {
        didSet { UserDefaults.standard.set(showWatermark, forKey: "drift.cards.showWatermark") }
    }

    var authorName: String {
        didSet { UserDefaults.standard.set(authorName, forKey: "drift.profile.authorName") }
    }

    var showAuthorOnCard: Bool {
        didSet { UserDefaults.standard.set(showAuthorOnCard, forKey: "drift.profile.showAuthor") }
    }

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "drift.profile.didOnboard") }
    }

    var streakFrequency: StreakFrequency {
        didSet { UserDefaults.standard.set(streakFrequency.rawValue, forKey: "drift.streak.frequency") }
    }

    private init() {
        let defaults = UserDefaults.standard
        self.showWatermark = defaults.object(forKey: "drift.cards.showWatermark") as? Bool ?? true
        self.authorName = defaults.string(forKey: "drift.profile.authorName") ?? ""
        self.showAuthorOnCard = defaults.object(forKey: "drift.profile.showAuthor") as? Bool ?? true
        self.hasCompletedOnboarding = defaults.object(forKey: "drift.profile.didOnboard") as? Bool ?? false
        self.streakFrequency = StreakFrequency(rawValue: defaults.string(forKey: "drift.streak.frequency") ?? "") ?? .daily
    }
}

// MARK: - Streak Calculation

extension StreakFrequency {
    static func currentStreak(from thoughts: [Thought], frequency: StreakFrequency) -> Int {
        guard !thoughts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let interval = frequency.intervalDays

        let uniqueDays = Set(thoughts.map { calendar.startOfDay(for: $0.createdAt) })
            .sorted(by: >)

        guard let mostRecent = uniqueDays.first else { return 0 }

        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        guard daysSinceLast <= interval else { return 0 }

        var streak = 1
        for idx in 1 ..< uniqueDays.count {
            let gap = calendar.dateComponents([.day], from: uniqueDays[idx], to: uniqueDays[idx - 1]).day ?? 0
            if gap <= interval {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}
