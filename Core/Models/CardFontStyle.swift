import SwiftUI

enum CardFontStyle: String, CaseIterable, Identifiable, Sendable {
    case serif, rounded, monospaced, classic

    var id: String { rawValue }

    var label: String {
        switch self {
        case .serif: "Serif"
        case .rounded: "Rounded"
        case .monospaced: "Monospaced"
        case .classic: "Classic"
        }
    }

    var font: Font {
        switch self {
        case .serif: .system(.title3, design: .serif)
        case .rounded: .system(.title3, design: .rounded)
        case .monospaced: .system(.title3, design: .monospaced)
        case .classic: .system(size: 24, weight: .regular, design: .default)
        }
    }

    var captionFont: Font {
        switch self {
        case .serif: .system(.caption, design: .serif)
        case .rounded: .system(.caption, design: .rounded)
        case .monospaced: .system(.caption, design: .monospaced)
        case .classic: .system(.caption, design: .default)
        }
    }
}
