import CoreGraphics

enum DriftLayout {
    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusLG: CGFloat = 16

    // MARK: - Card

    static let cardAspectRatio: CGFloat = 4.0 / 5.0

    // MARK: - Text Limits

    static let bodyCharacterLimit = 500
    static let titleCharacterLimit = 50
    static let authorNameCharacterLimit = 50

    // MARK: - Watermark

    static let watermarkText = "drifting thoughts"
}
