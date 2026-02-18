import Foundation
import SwiftData

@Model
final class Thought {
    var id: UUID
    var title: String
    var text: String
    var createdAt: Date
    var styleName: String
    var isFavorite: Bool
    var themeOverridesJSON: String?

    init(
        title: String = "",
        text: String,
        styleName: String = CardStyle.midnight.rawValue,
        themeOverridesJSON: String? = nil,
    ) {
        self.id = UUID()
        self.title = title
        self.text = text
        self.createdAt = Date()
        self.styleName = styleName
        self.isFavorite = false
        self.themeOverridesJSON = themeOverridesJSON
    }

    var style: CardStyle {
        CardStyle(rawValue: styleName) ?? .midnight
    }

    var fontStyle: CardFontStyle {
        themeOverrides.flatMap { CardFontStyle(rawValue: $0.bodyFontStyleName ?? "") } ?? .serif
    }

    var authorFontStyle: CardFontStyle {
        themeOverrides.flatMap { CardFontStyle(rawValue: $0.authorFontStyleName ?? "") } ?? .serif
    }

    var themeOverrides: CardThemeOverrides? {
        get {
            guard let themeOverridesJSON,
                  let data = themeOverridesJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode(CardThemeOverrides.self, from: data)
            else {
                return nil
            }
            return decoded.persistableSnapshot()
        }
        set {
            guard let normalized = newValue?.persistableSnapshot(),
                  let data = try? JSONEncoder().encode(normalized),
                  let json = String(data: data, encoding: .utf8)
            else {
                themeOverridesJSON = nil
                return
            }
            themeOverridesJSON = json
        }
    }
}
