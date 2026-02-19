import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class CardDetailViewModel {
    let text: String
    let selectedStyle: CardStyle
    var draftThemeOverrides: CardThemeOverrides
    var existingThought: Thought?

    init(
        text: String,
        existingThought: Thought? = nil
    ) {
        self.text = text
        self.existingThought = existingThought
        self.selectedStyle = existingThought?.style ?? .sunset
        self.draftThemeOverrides = existingThought?.themeOverrides ?? CardThemeOverrides()
    }

    var bodyFontStyle: CardFontStyle {
        get { CardFontStyle(rawValue: draftThemeOverrides.bodyFontStyleName ?? "") ?? .serif }
        set { draftThemeOverrides.bodyFontStyleName = newValue.rawValue }
    }

    var authorFontStyle: CardFontStyle {
        get { CardFontStyle(rawValue: draftThemeOverrides.authorFontStyleName ?? "") ?? .serif }
        set { draftThemeOverrides.authorFontStyleName = newValue.rawValue }
    }

    func save(in context: ModelContext) {
        if let existing = existingThought {
            existing.text = text
            existing.styleName = selectedStyle.rawValue
            existing.themeOverrides = draftThemeOverrides
        } else {
            let thought = Thought(
                text: text,
                styleName: selectedStyle.rawValue
            )
            thought.themeOverrides = draftThemeOverrides
            context.insert(thought)
        }
    }

    func makeThoughtForPreview() -> Thought {
        if let existing = existingThought {
            return existing
        }
        let previewThought = Thought(
            text: text,
            styleName: selectedStyle.rawValue
        )
        previewThought.themeOverrides = draftThemeOverrides
        return previewThought
    }

    func makeShareURL(settings: AppSettings) -> URL? {
        let exportView = CardView(
            thought: makeThoughtForPreview(),
            style: selectedStyle,
            themeOverrides: draftThemeOverrides,
            settings: settings
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
}
