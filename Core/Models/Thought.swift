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
    var themeOverrides: CardThemeOverrides?

    init(
        title: String = "",
        text: String,
        styleName: String = CardStyle.midnight.rawValue,
        themeOverrides: CardThemeOverrides? = nil,
    ) {
        self.id = UUID()
        self.title = title
        self.text = text
        self.createdAt = Date()
        self.styleName = styleName
        self.isFavorite = false
        self.themeOverrides = themeOverrides
    }

    var style: CardStyle {
        CardStyle(rawValue: styleName) ?? .midnight
    }
}
