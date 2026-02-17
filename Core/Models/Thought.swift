import Foundation
import SwiftData

@Model
final class Thought {
    var id: UUID
    var text: String
    var createdAt: Date
    var styleName: String
    var tag: String?
    var moodName: String?
    var isFavorite: Bool

    init(
        text: String,
        styleName: String = CardStyle.midnight.rawValue,
        tag: String? = nil,
        moodName: String? = nil,
    ) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.styleName = styleName
        self.tag = tag
        self.moodName = moodName
        self.isFavorite = false
    }

    var style: CardStyle {
        CardStyle(rawValue: styleName) ?? .midnight
    }

    var mood: Mood? {
        guard let moodName else { return nil }
        return Mood(rawValue: moodName)
    }
}
