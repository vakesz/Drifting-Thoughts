import CoreGraphics
import SwiftUI

enum DriftLayout {
    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusLG: CGFloat = 16

    // MARK: - Card

    static let cardShortAspectRatio: CGFloat = 4.0 / 3.0 // short text → wider card
    static let cardTallAspectRatio: CGFloat = 4.0 / 5.0 // long text → taller card

    // MARK: - Text Limits

    static let bodyCharacterLimit = 500
    static let titleCharacterLimit = 50 // used by computed Thought.title
    static let authorNameCharacterLimit = 50

    // MARK: - Watermark

    static let watermarkText = "drifting thoughts"
}

// MARK: - Character Limit

extension View {
    func characterLimit(_ limit: Int, on value: Binding<String>) -> some View {
        onChange(of: value.wrappedValue) { _, newValue in
            let truncated = String(newValue.prefix(limit))
            if truncated != newValue {
                value.wrappedValue = truncated
            }
        }
    }
}
