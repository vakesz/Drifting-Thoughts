import Foundation
import SwiftUI

enum CardContentAlignment: String, Codable, CaseIterable, Sendable {
    case top
    case center
    case bottom
}

struct CardThemeOverrides: Codable, Equatable, Sendable {
    static let defaultAuthorTextOpacity: Double = 0.5
    static let defaultWatermarkTextOpacity: Double = 0.25

    var titleTextColorHex: String?
    var bodyTextColorHex: String?
    var authorTextColorHex: String?
    var watermarkTextColorHex: String?
    var backgroundGradientStartHex: String?
    var backgroundGradientEndHex: String?

    var titleFontStyleName: String?
    var bodyFontStyleName: String?

    var authorTextOpacity: Double?
    var watermarkTextOpacity: Double?

    var showAuthorOverride: Bool?
    var showWatermarkOverride: Bool?
    var watermarkTextOverride: String?

    // Future-rich schema additions.
    var contentAlignment: CardContentAlignment?
    var lineSpacing: Double?
    var textPaddingScale: Double?
    var backgroundNoiseIntensity: Double?

    func persistableSnapshot() -> Self? {
        var normalized = self

        normalized.titleTextColorHex = RGBHex.normalized(titleTextColorHex)
        normalized.bodyTextColorHex = RGBHex.normalized(bodyTextColorHex)
        normalized.authorTextColorHex = RGBHex.normalized(authorTextColorHex)
        normalized.watermarkTextColorHex = RGBHex.normalized(watermarkTextColorHex)
        normalized.backgroundGradientStartHex = RGBHex.normalized(backgroundGradientStartHex)
        normalized.backgroundGradientEndHex = RGBHex.normalized(backgroundGradientEndHex)

        normalized.titleFontStyleName = Self.normalizedFontStyleName(titleFontStyleName)
        normalized.bodyFontStyleName = Self.normalizedFontStyleName(bodyFontStyleName)

        normalized.authorTextOpacity = normalized.authorTextOpacity.map(Self.clampedUnitInterval)
        normalized.watermarkTextOpacity = normalized.watermarkTextOpacity.map(Self.clampedUnitInterval)

        if let watermarkTextOverride = normalized.watermarkTextOverride?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !watermarkTextOverride.isEmpty {
            normalized.watermarkTextOverride = watermarkTextOverride
        } else {
            normalized.watermarkTextOverride = nil
        }

        normalized.lineSpacing = normalized.lineSpacing.map { max(0, $0) }
        normalized.textPaddingScale = normalized.textPaddingScale.map { max(0.5, $0) }
        normalized.backgroundNoiseIntensity = normalized.backgroundNoiseIntensity.map(Self.clampedUnitInterval)

        return normalized.isEmpty ? nil : normalized
    }

    var isEmpty: Bool {
        titleTextColorHex == nil &&
            bodyTextColorHex == nil &&
            authorTextColorHex == nil &&
            watermarkTextColorHex == nil &&
            backgroundGradientStartHex == nil &&
            backgroundGradientEndHex == nil &&
            titleFontStyleName == nil &&
            bodyFontStyleName == nil &&
            authorTextOpacity == nil &&
            watermarkTextOpacity == nil &&
            showAuthorOverride == nil &&
            showWatermarkOverride == nil &&
            watermarkTextOverride == nil &&
            contentAlignment == nil &&
            lineSpacing == nil &&
            textPaddingScale == nil &&
            backgroundNoiseIntensity == nil
    }

    private static func normalizedFontStyleName(_ input: String?) -> String? {
        guard let input else { return nil }
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }

    private static func clampedUnitInterval(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

struct ResolvedCardTheme: Sendable {
    var bodyTextColor: Color
    var authorTextColor: Color
    var watermarkTextColor: Color
    var backgroundGradientStart: Color
    var backgroundGradientEnd: Color

    var bodyFontStyle: CardFontStyle

    var authorTextOpacity: Double
    var watermarkTextOpacity: Double

    var showAuthor: Bool
    var showWatermark: Bool
    var watermarkText: String
    var authorName: String?

    var contentAlignment: CardContentAlignment
    var lineSpacing: Double
    var textPaddingScale: Double

    /// 3x3 mesh gradient color array derived from the gradient endpoints.
    var meshGradientColors: [Color] {
        let s = backgroundGradientStart, e = backgroundGradientEnd
        return [s, s, e, s, e, e, e, e, s]
    }
}

enum CardThemeResolver {
    static let defaultWatermarkText = "drifting thoughts"

    @MainActor
    static func resolve(
        thought: Thought,
        style: CardStyle,
        settings: AppSettings,
        themeOverrides: CardThemeOverrides? = nil,
    ) -> ResolvedCardTheme {
        let overrides = (themeOverrides ?? thought.themeOverrides)?.persistableSnapshot()

        let defaultTextColor = style.textColor

        func resolveColor(_ hex: String?, fallback: Color) -> Color {
            hex.flatMap { Color(rgbHex: $0) } ?? fallback
        }

        let bodyFontStyle = CardFontStyle(rawValue: overrides?.bodyFontStyleName ?? "")
            ?? thought.fontStyle

        let authorName = settings.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let showAuthor = (overrides?.showAuthorOverride ?? settings.showAuthorOnCard)
            && !authorName.isEmpty
        let showWatermark = overrides?.showWatermarkOverride ?? settings.showWatermark

        return ResolvedCardTheme(
            bodyTextColor: resolveColor(overrides?.bodyTextColorHex, fallback: defaultTextColor),
            authorTextColor: resolveColor(overrides?.authorTextColorHex, fallback: defaultTextColor),
            watermarkTextColor: resolveColor(overrides?.watermarkTextColorHex, fallback: defaultTextColor),
            backgroundGradientStart: resolveColor(overrides?.backgroundGradientStartHex, fallback: style.gradientStartColor),
            backgroundGradientEnd: resolveColor(overrides?.backgroundGradientEndHex, fallback: style.gradientEndColor),
            bodyFontStyle: bodyFontStyle,
            authorTextOpacity: min(max(overrides?.authorTextOpacity ?? CardThemeOverrides.defaultAuthorTextOpacity, 0), 1),
            watermarkTextOpacity: min(max(overrides?.watermarkTextOpacity ?? CardThemeOverrides.defaultWatermarkTextOpacity, 0), 1),
            showAuthor: showAuthor,
            showWatermark: showWatermark,
            watermarkText: overrides?.watermarkTextOverride ?? defaultWatermarkText,
            authorName: showAuthor ? authorName : nil,
            contentAlignment: overrides?.contentAlignment ?? .center,
            lineSpacing: max(overrides?.lineSpacing ?? 0, 0),
            textPaddingScale: max(overrides?.textPaddingScale ?? 1, 0.5),
        )
    }
}
