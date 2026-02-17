import SwiftData
import SwiftUI

@MainActor
@Observable
final class CardPreviewViewModel {
    var selectedStyle: CardStyle {
        didSet { syncColorsFromStyle() }
    }

    let text: String
    let tag: String?
    let moodName: String?

    // MARK: - Custom Colors

    var textColor: Color
    var gradientStart: Color
    var gradientEnd: Color
    var tagPosition: TagPosition = .bottomTrailing

    /// When editing an existing thought, holds a reference
    var existingThought: Thought?

    init(
        text: String,
        tag: String?,
        moodName: String?,
        existingThought: Thought? = nil,
    ) {
        self.text = text
        self.tag = tag
        self.moodName = moodName
        self.existingThought = existingThought
        let style = existingThought?.style ?? AppSettings.shared.defaultStyle
        self.selectedStyle = style
        self.textColor = style.textColor
        self.gradientStart = style.gradientStartColor
        self.gradientEnd = style.gradientEndColor
    }

    func save(in context: ModelContext) {
        if let existing = existingThought {
            existing.styleName = selectedStyle.rawValue
        } else {
            let thought = Thought(
                text: text,
                styleName: selectedStyle.rawValue,
                tag: tag,
                moodName: moodName,
            )
            context.insert(thought)
        }
    }

    func makeThoughtForPreview() -> Thought {
        if let existing = existingThought {
            return existing
        }
        return Thought(
            text: text,
            styleName: selectedStyle.rawValue,
            tag: tag,
            moodName: moodName,
        )
    }

    var customMeshColors: [Color] {
        [
            gradientStart, gradientStart, gradientEnd,
            gradientStart, gradientEnd, gradientEnd,
            gradientEnd, gradientEnd, gradientStart,
        ]
    }

    /// Build a plain-text version for sharing
    func shareText() -> String {
        var parts: [String] = [text]
        if let moodName, let mood = Mood(rawValue: moodName) {
            parts.append(mood.emoji)
        }
        if let tag {
            parts.append("#\(tag)")
        }
        return parts.joined(separator: " ")
    }

    // MARK: - Private

    private func syncColorsFromStyle() {
        textColor = selectedStyle.textColor
        gradientStart = selectedStyle.gradientStartColor
        gradientEnd = selectedStyle.gradientEndColor
    }
}
