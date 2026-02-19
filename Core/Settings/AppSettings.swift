import Foundation

enum StreakFrequency: String, CaseIterable, Identifiable, Sendable {
    case daily, weekly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
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
        case .daily: "day"
        case .weekly: "week"
        }
    }
}

@MainActor
@Observable
final class AppSettings: @unchecked Sendable {
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
