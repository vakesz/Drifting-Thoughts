import SwiftUI

enum CardFontStyle: String, CaseIterable, Identifiable, Sendable {
    case serif, rounded, monospaced, classic

    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    var design: Font.Design {
        switch self {
        case .serif: .serif
        case .rounded: .rounded
        case .monospaced: .monospaced
        case .classic: .default
        }
    }

    var font: Font { .system(.title3, design: design) }
    var captionFont: Font { .system(.caption, design: design) }
}
