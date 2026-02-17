import SwiftUI

enum CardStyle: String, CaseIterable, Identifiable, Sendable {
    case midnight, parchment, sunset

    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    var gradientStartColor: Color { Color("\(rawValue.capitalized)GradientStart") }
    var gradientEndColor: Color { Color("\(rawValue.capitalized)GradientEnd") }
    var textColor: Color { Color("\(rawValue.capitalized)Text") }

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
    /// Creates a uniform 3x3 mesh gradient from the given colors.
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
