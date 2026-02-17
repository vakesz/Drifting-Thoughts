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

    var defaultStyleName: String {
        didSet { UserDefaults.standard.set(defaultStyleName, forKey: "drift.cards.defaultStyle") }
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

    var defaultStyle: CardStyle {
        get { CardStyle(rawValue: defaultStyleName) ?? .midnight }
        set { defaultStyleName = newValue.rawValue }
    }

    private init() {
        let defaults = UserDefaults.standard
        self.autoOpenKeyboard = defaults.object(forKey: "drift.compose.autoKeyboard") as? Bool ?? true
        self.showWatermark = defaults.object(forKey: "drift.cards.showWatermark") as? Bool ?? true
        self.defaultStyleName = defaults.string(forKey: "drift.cards.defaultStyle") ?? CardStyle.midnight.rawValue
        self.authorName = defaults.string(forKey: "drift.profile.authorName") ?? ""
        self.showAuthorOnCard = defaults.object(forKey: "drift.profile.showAuthor") as? Bool ?? true
        self.hasCompletedOnboarding = defaults.object(forKey: "drift.profile.didOnboard") as? Bool ?? false
    }
}
