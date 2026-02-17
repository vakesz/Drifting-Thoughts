import SwiftUI

extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let rgb = UInt64(cleaned, radix: 16) else {
            return nil
        }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self = Color(red: red, green: green, blue: blue)
    }

    var hexString: String? {
        guard let cgColor = self.cgColor,
              let components = cgColor.components
        else {
            return nil
        }

        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat

        switch components.count {
        case 2:
            red = components[0]
            green = components[0]
            blue = components[0]
        case 3, 4:
            red = components[0]
            green = components[1]
            blue = components[2]
        default:
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
