import SwiftUI
import UIKit

/// Shared hex-color string utilities used by `Color` extensions and `CardThemeOverrides`.
enum RGBHex {
    /// Strips non-alphanumeric characters, uppercases, and validates a 6-digit hex string.
    /// Returns `nil` for `nil` input or invalid strings.
    static func normalized(_ input: String?) -> String? {
        guard let input else { return nil }
        let cleaned = input.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
        guard cleaned.count == 6, UInt64(cleaned, radix: 16) != nil else { return nil }
        return cleaned
    }
}

extension Color {
    /// Initializes a color from a 6-digit RGB hex string (e.g. `#A1B2C3` or `A1B2C3`).
    init?(rgbHex: String) {
        guard let cleaned = RGBHex.normalized(rgbHex),
              let rgb = UInt64(cleaned, radix: 16)
        else {
            return nil
        }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self = Color(red: red, green: green, blue: blue)
    }

    /// Serializes the color to a 6-digit RGB uppercase hex string.
    var rgbHexString: String? {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero

        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        else {
            return nil
        }

        return String(
            format: "%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255),
        )
    }
}
