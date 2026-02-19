import Foundation
import SwiftData

@Model
final class Thought {
    var id: UUID
    var text: String
    var createdAt: Date
    var styleName: String
    var isFavorite: Bool
    var themeOverrides: CardThemeOverrides?

    init(
        text: String,
        styleName: String = CardStyle.midnight.rawValue,
        themeOverrides: CardThemeOverrides? = nil,
    ) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.styleName = styleName
        self.isFavorite = false
        self.themeOverrides = themeOverrides
    }

    var style: CardStyle {
        CardStyle(rawValue: styleName) ?? .midnight
    }

    var title: String {
        let firstLine = text.prefix(while: { $0 != "\n" })
        return String(firstLine.prefix(DriftLayout.titleCharacterLimit)).trimmingCharacters(in: .whitespaces)
    }
}
