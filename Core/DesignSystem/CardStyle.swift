import SwiftUI

enum CardStyle: String, CaseIterable, Identifiable, Sendable {
    case midnight, parchment, sunset

    var id: String { rawValue }
    var label: String {
        switch self {
        case .midnight: String(localized: "card.style.midnight")
        case .parchment: String(localized: "card.style.parchment")
        case .sunset: String(localized: "card.style.sunset")
        }
    }

    var gradientStartColor: Color {
        switch self {
        case .midnight: .midnightGradientStart
        case .parchment: .parchmentGradientStart
        case .sunset: .sunsetGradientStart
        }
    }

    var gradientEndColor: Color {
        switch self {
        case .midnight: .midnightGradientEnd
        case .parchment: .parchmentGradientEnd
        case .sunset: .sunsetGradientEnd
        }
    }

    var textColor: Color {
        switch self {
        case .midnight: .midnightText
        case .parchment: .parchmentText
        case .sunset: .sunsetText
        }
    }
}
