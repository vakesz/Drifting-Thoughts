import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class CardPreviewViewModel {
    var selectedStyle: CardStyle {
        didSet { resetThemeToStyleDefaults() }
    }

    let title: String
    let text: String
    var draftThemeOverrides: CardThemeOverrides
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
        self.draftThemeOverrides = existingThought?.themeOverrides ?? CardThemeOverrides()
    }

    var bodyTextColor: Color {
        get { colorOverride(\.bodyTextColorHex, default: selectedStyle.textColor) }
        set { setColorOverride(\.bodyTextColorHex, newValue: newValue, default: selectedStyle.textColor) }
    }

    var backgroundGradientStart: Color {
        get { colorOverride(\.backgroundGradientStartHex, default: selectedStyle.gradientStartColor) }
        set { setColorOverride(\.backgroundGradientStartHex, newValue: newValue, default: selectedStyle.gradientStartColor) }
    }

    var backgroundGradientEnd: Color {
        get { colorOverride(\.backgroundGradientEndHex, default: selectedStyle.gradientEndColor) }
        set { setColorOverride(\.backgroundGradientEndHex, newValue: newValue, default: selectedStyle.gradientEndColor) }
    }

    var authorTextColor: Color {
        get { colorOverride(\.authorTextColorHex, default: selectedStyle.textColor) }
        set { setColorOverride(\.authorTextColorHex, newValue: newValue, default: selectedStyle.textColor) }
    }

    var watermarkTextColor: Color {
        get { colorOverride(\.watermarkTextColorHex, default: selectedStyle.textColor) }
        set { setColorOverride(\.watermarkTextColorHex, newValue: newValue, default: selectedStyle.textColor) }
    }

    var bodyFontStyle: CardFontStyle {
        get { CardFontStyle(rawValue: draftThemeOverrides.bodyFontStyleName ?? "") ?? .serif }
        set { draftThemeOverrides.bodyFontStyleName = newValue.rawValue }
    }

    var showsAuthor: Bool {
        get { draftThemeOverrides.showAuthorOverride ?? AppSettings.shared.showAuthorOnCard }
        set {
            draftThemeOverrides.showAuthorOverride = (newValue == AppSettings.shared.showAuthorOnCard)
                ? nil : newValue
        }
    }

    var showsWatermark: Bool {
        get { draftThemeOverrides.showWatermarkOverride ?? AppSettings.shared.showWatermark }
        set {
            draftThemeOverrides.showWatermarkOverride = (newValue == AppSettings.shared.showWatermark)
                ? nil : newValue
        }
    }

    var watermarkText: String {
        get { draftThemeOverrides.watermarkTextOverride ?? CardThemeResolver.defaultWatermarkText }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            draftThemeOverrides.watermarkTextOverride = (trimmed.isEmpty || trimmed == CardThemeResolver.defaultWatermarkText)
                ? nil : trimmed
        }
    }

    var authorTextOpacity: Double {
        get { draftThemeOverrides.authorTextOpacity ?? CardThemeOverrides.defaultAuthorTextOpacity }
        set {
            let clamped = min(max(newValue, 0), 1)
            let isDefault = abs(clamped - CardThemeOverrides.defaultAuthorTextOpacity) < .ulpOfOne
            draftThemeOverrides.authorTextOpacity = isDefault ? nil : clamped
        }
    }

    var watermarkTextOpacity: Double {
        get { draftThemeOverrides.watermarkTextOpacity ?? CardThemeOverrides.defaultWatermarkTextOpacity }
        set {
            let clamped = min(max(newValue, 0), 1)
            let isDefault = abs(clamped - CardThemeOverrides.defaultWatermarkTextOpacity) < .ulpOfOne
            draftThemeOverrides.watermarkTextOpacity = isDefault ? nil : clamped
        }
    }

    var themeOverridesSnapshot: String {
        guard let normalized = draftThemeOverrides.persistableSnapshot(),
              let data = try? JSONEncoder().encode(normalized),
              let encoded = String(data: data, encoding: .utf8)
        else {
            return "none"
        }
        return encoded
    }

    func save(in context: ModelContext) {
        if let existing = existingThought {
            existing.title = title
            existing.text = text
            existing.styleName = selectedStyle.rawValue
            existing.themeOverrides = draftThemeOverrides
        } else {
            let thought = Thought(
                title: title,
                text: text,
                styleName: selectedStyle.rawValue,
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
            title: title,
            text: text,
            styleName: selectedStyle.rawValue,
        )
        previewThought.themeOverrides = draftThemeOverrides
        return previewThought
    }

    func makeShareURL(settings: AppSettings) -> URL? {
        let exportView = CardView(
            thought: makeThoughtForPreview(),
            style: selectedStyle,
            themeOverrides: draftThemeOverrides,
            settings: settings,
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

    private func colorOverride(
        _ keyPath: KeyPath<CardThemeOverrides, String?>,
        default fallback: Color
    ) -> Color {
        Color(rgbHex: draftThemeOverrides[keyPath: keyPath] ?? "") ?? fallback
    }

    private func setColorOverride(
        _ keyPath: WritableKeyPath<CardThemeOverrides, String?>,
        newValue: Color,
        default fallback: Color
    ) {
        let hex = newValue.rgbHexString
        draftThemeOverrides[keyPath: keyPath] = (hex == fallback.rgbHexString) ? nil : hex
    }

    private func resetThemeToStyleDefaults() {
        draftThemeOverrides.bodyTextColorHex = nil
        draftThemeOverrides.authorTextColorHex = nil
        draftThemeOverrides.watermarkTextColorHex = nil
        draftThemeOverrides.backgroundGradientStartHex = nil
        draftThemeOverrides.backgroundGradientEndHex = nil
    }
}
