import SwiftUI

enum TagPosition: String, CaseIterable, Identifiable, Sendable {
    case bottomLeading, bottomTrailing, topLeading, topTrailing

    var id: String { rawValue }

    var label: String {
        switch self {
        case .bottomLeading: "Bottom Left"
        case .bottomTrailing: "Bottom Right"
        case .topLeading: "Top Left"
        case .topTrailing: "Top Right"
        }
    }

    var alignment: Alignment {
        switch self {
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        }
    }

    var iconName: String {
        switch self {
        case .bottomLeading: "arrow.down.left"
        case .bottomTrailing: "arrow.down.right"
        case .topLeading: "arrow.up.left"
        case .topTrailing: "arrow.up.right"
        }
    }
}

enum CardStyle: String, CaseIterable, Identifiable, Sendable {
    case midnight, parchment, sunset

    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    var gradientStartColor: Color { Color("\(rawValue.capitalized)GradientStart") }
    var gradientEndColor: Color { Color("\(rawValue.capitalized)GradientEnd") }
    var textColor: Color { Color("\(rawValue.capitalized)Text") }

    var font: Font {
        switch self {
        case .midnight: .system(.title3, design: .serif).italic()
        case .parchment: .system(.title3, design: .serif)
        case .sunset: .system(.title3, design: .default)
        }
    }

    /// MeshGradient control points — each style gets a unique 3x3 mesh
    var meshColors: [Color] {
        let start = gradientStartColor
        let end = gradientEndColor
        return [
            start, start, end,
            start, end, end,
            end, end, start,
        ]
    }
}

// MARK: - MeshGradient Helpers

extension MeshGradient {
    /// Creates a uniform 3×3 mesh gradient from the given colors.
    static func uniform3x3(colors: [Color]) -> MeshGradient {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
            ],
            colors: colors,
        )
    }
}
