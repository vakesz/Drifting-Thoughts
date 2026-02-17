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
    var fontStyleName: String
    var textColorHex: String?
    var gradientStartHex: String?
    var gradientEndHex: String?

    init(
        title: String = "",
        text: String,
        styleName: String = CardStyle.midnight.rawValue,
        fontStyleName: String = CardFontStyle.serif.rawValue,
        textColorHex: String? = nil,
        gradientStartHex: String? = nil,
        gradientEndHex: String? = nil,
    ) {
        self.id = UUID()
        self.title = title
        self.text = text
        self.createdAt = Date()
        self.styleName = styleName
        self.isFavorite = false
        self.fontStyleName = fontStyleName
        self.textColorHex = textColorHex
        self.gradientStartHex = gradientStartHex
        self.gradientEndHex = gradientEndHex
    }

    var style: CardStyle {
        CardStyle(rawValue: styleName) ?? .midnight
    }

    var fontStyle: CardFontStyle {
        CardFontStyle(rawValue: fontStyleName) ?? .serif
    }
}
