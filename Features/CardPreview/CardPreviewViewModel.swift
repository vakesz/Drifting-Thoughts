import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class CardPreviewViewModel {
    var selectedStyle: CardStyle {
        didSet { syncColorsFromStyle() }
    }

    let title: String
    let text: String

    // MARK: - Custom Colors

    var textColor: Color
    var gradientStart: Color
    var gradientEnd: Color
    var selectedFontStyle: CardFontStyle

    /// When editing an existing thought, holds a reference
    var existingThought: Thought?

    init(
        title: String,
        text: String,
        existingThought: Thought? = nil,
    ) {
        self.title = title
        self.text = text
        self.existingThought = existingThought
        let style = existingThought?.style ?? AppSettings.shared.defaultStyle
        self.selectedStyle = style
        self.textColor = Color(hex: existingThought?.textColorHex ?? "") ?? style.textColor
        self.gradientStart = Color(hex: existingThought?.gradientStartHex ?? "") ?? style.gradientStartColor
        self.gradientEnd = Color(hex: existingThought?.gradientEndHex ?? "") ?? style.gradientEndColor
        self.selectedFontStyle = existingThought?.fontStyle ?? .serif
    }

    func save(in context: ModelContext) {
        if let existing = existingThought {
            existing.title = title
            existing.text = text
            existing.styleName = selectedStyle.rawValue
            existing.fontStyleName = selectedFontStyle.rawValue
            existing.textColorHex = textColor.hexString
            existing.gradientStartHex = gradientStart.hexString
            existing.gradientEndHex = gradientEnd.hexString
        } else {
            let thought = Thought(
                title: title,
                text: text,
                styleName: selectedStyle.rawValue,
                fontStyleName: selectedFontStyle.rawValue,
                textColorHex: textColor.hexString,
                gradientStartHex: gradientStart.hexString,
                gradientEndHex: gradientEnd.hexString,
            )
            context.insert(thought)
        }
    }

    func makeThoughtForPreview() -> Thought {
        if let existing = existingThought {
            return existing
        }
        return Thought(
            title: title,
            text: text,
            styleName: selectedStyle.rawValue,
            fontStyleName: selectedFontStyle.rawValue,
            textColorHex: textColor.hexString,
            gradientStartHex: gradientStart.hexString,
            gradientEndHex: gradientEnd.hexString,
        )
    }

    var customMeshColors: [Color] {
        [
            gradientStart, gradientStart, gradientEnd,
            gradientStart, gradientEnd, gradientEnd,
            gradientEnd, gradientEnd, gradientStart,
        ]
    }

    func makeShareURL(showWatermark: Bool, authorName: String?) -> URL? {
        let exportView = CardView(
            thought: makeThoughtForPreview(),
            style: selectedStyle,
            showWatermark: showWatermark,
            authorName: authorName,
            customFontStyle: selectedFontStyle,
            customTextColor: textColor,
            customMeshColors: customMeshColors,
        )

        let renderer = ImageRenderer(content: exportView.frame(width: 1080, height: 1350))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage,
              let data = uiImage.pngData()
        else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("drifting-thought-\(UUID().uuidString).png")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func syncColorsFromStyle() {
        textColor = selectedStyle.textColor
        gradientStart = selectedStyle.gradientStartColor
        gradientEnd = selectedStyle.gradientEndColor
    }
}
