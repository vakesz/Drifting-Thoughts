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

    var defaultStyle: CardStyle {
        get { CardStyle(rawValue: defaultStyleName) ?? .midnight }
        set { defaultStyleName = newValue.rawValue }
    }

    private init() {
        let defaults = UserDefaults.standard
        self.autoOpenKeyboard = defaults.object(forKey: "drift.compose.autoKeyboard") as? Bool ?? true
        self.showWatermark = defaults.object(forKey: "drift.cards.showWatermark") as? Bool ?? true
        self.defaultStyleName = defaults.string(forKey: "drift.cards.defaultStyle") ?? CardStyle.midnight.rawValue
    }
}
