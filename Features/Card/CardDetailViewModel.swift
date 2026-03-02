import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class CardDetailViewModel {
    let text: String
    var selectedStyle: CardStyle
    var draftThemeOverrides: CardThemeOverrides
    var existingThought: Thought?

    private var cachedPreviewThought: Thought?
    private var lastShareURL: URL?

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
        let normalizedOverrides = draftThemeOverrides.persistableSnapshot()
        if let existing = existingThought {
            existing.text = text
            existing.styleName = selectedStyle.rawValue
            existing.themeOverrides = normalizedOverrides
        } else {
            let thought = Thought(
                text: text,
                styleName: selectedStyle.rawValue
            )
            thought.themeOverrides = normalizedOverrides
            context.insert(thought)
        }
    }

    func makeThoughtForPreview() -> Thought {
        if let existing = existingThought {
            return existing
        }
        if let cached = cachedPreviewThought {
            cached.text = text
            cached.styleName = selectedStyle.rawValue
            cached.themeOverrides = draftThemeOverrides
            return cached
        }
        let thought = Thought(text: text, styleName: selectedStyle.rawValue)
        thought.themeOverrides = draftThemeOverrides
        cachedPreviewThought = thought
        return thought
    }

    func makeShareURL(settings: AppSettings) -> URL? {
        if let previous = lastShareURL {
            try? FileManager.default.removeItem(at: previous)
            lastShareURL = nil
        }

        let exportWidth: CGFloat = 1080
        let aspectRatio = CardView.dynamicAspectRatio(for: text)
        let exportHeight = exportWidth / aspectRatio

        let exportView = CardView(
            thought: makeThoughtForPreview(),
            style: selectedStyle,
            themeOverrides: draftThemeOverrides,
            settings: settings,
            explicitWidth: exportWidth
        )

        let renderer = ImageRenderer(content: exportView.frame(width: exportWidth, height: exportHeight))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage,
              let data = uiImage.pngData()
        else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("drifting-thought-export.png")
        do {
            try data.write(to: url, options: .atomic)
            lastShareURL = url
            return url
        } catch {
            return nil
        }
    }
}
