import Foundation

@MainActor
@Observable
final class AppSettings: @unchecked Sendable {
    static let shared = AppSettings()

    var autoOpenKeyboard: Bool {
        didSet { UserDefaults.standard.set(autoOpenKeyboard, forKey: "drift.compose.autoKeyboard") }
    }

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

    private init() {
        let defaults = UserDefaults.standard
        self.autoOpenKeyboard = defaults.object(forKey: "drift.compose.autoKeyboard") as? Bool ?? true
        self.showWatermark = defaults.object(forKey: "drift.cards.showWatermark") as? Bool ?? true
        self.authorName = defaults.string(forKey: "drift.profile.authorName") ?? ""
        self.showAuthorOnCard = defaults.object(forKey: "drift.profile.showAuthor") as? Bool ?? true
        self.hasCompletedOnboarding = defaults.object(forKey: "drift.profile.didOnboard") as? Bool ?? false
    }
}
