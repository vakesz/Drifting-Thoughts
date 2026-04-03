import SwiftUI

enum CardFontStyle: String, CaseIterable, Identifiable, Sendable {
    case serif, rounded, monospaced, classic

    var id: String { rawValue }
    var label: String {
        switch self {
        case .serif: String(localized: "card.font.serif")
        case .rounded: String(localized: "card.font.rounded")
        case .monospaced: String(localized: "card.font.monospaced")
        case .classic: String(localized: "card.font.classic")
        }
    }

    var design: Font.Design {
        switch self {
        case .serif: .serif
        case .rounded: .rounded
        case .monospaced: .monospaced
        case .classic: .default
        }
    }

    var captionFont: Font { .system(.caption, design: design) }
}
