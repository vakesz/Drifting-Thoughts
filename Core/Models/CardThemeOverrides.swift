import Foundation
import SwiftUI

struct CardThemeOverrides: Codable, Equatable, Sendable {
    var bodyFontStyleName: String?
    var authorFontStyleName: String?

    func persistableSnapshot() -> Self? {
        var normalized = self
        normalized.bodyFontStyleName = Self.normalizedFontStyleName(bodyFontStyleName)
        normalized.authorFontStyleName = Self.normalizedFontStyleName(authorFontStyleName)
        return normalized.isEmpty ? nil : normalized
    }

    var isEmpty: Bool {
        bodyFontStyleName == nil && authorFontStyleName == nil
    }

    private static func normalizedFontStyleName(_ input: String?) -> String? {
        guard let input else { return nil }
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }
}

struct ResolvedCardTheme: Sendable {
    var textColor: Color
    var backgroundGradientStart: Color
    var backgroundGradientEnd: Color

    var bodyFontStyle: CardFontStyle
    var authorFontStyle: CardFontStyle

    var showAuthor: Bool
    var showWatermark: Bool
    var authorName: String?

    var meshGradientColors: [Color] {
        let s = backgroundGradientStart, e = backgroundGradientEnd
        return [s, s, e, s, e, e, e, e, s]
    }
}

enum CardThemeResolver {
    @MainActor
    static func resolve(
        thought: Thought,
        style: CardStyle,
        settings: AppSettings,
        themeOverrides: CardThemeOverrides? = nil
    ) -> ResolvedCardTheme {
        let overrides = themeOverrides ?? thought.themeOverrides

        let bodyFontStyle = CardFontStyle(rawValue: overrides?.bodyFontStyleName ?? "") ?? .serif
        let authorFontStyle = CardFontStyle(rawValue: overrides?.authorFontStyleName ?? "") ?? .serif

        let authorName = settings.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let showAuthor = settings.showAuthorOnCard && !authorName.isEmpty
        let showWatermark = settings.showWatermark

        return ResolvedCardTheme(
            textColor: style.textColor,
            backgroundGradientStart: style.gradientStartColor,
            backgroundGradientEnd: style.gradientEndColor,
            bodyFontStyle: bodyFontStyle,
            authorFontStyle: authorFontStyle,
            showAuthor: showAuthor,
            showWatermark: showWatermark,
            authorName: showAuthor ? authorName : nil
        )
    }
}
