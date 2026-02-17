enum Mood: String, CaseIterable, Identifiable, Sendable {
    case calm, happy, melancholy, inspired, restless, grateful

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .calm: "🌊"
        case .happy: "☀️"
        case .melancholy: "🌧️"
        case .inspired: "✨"
        case .restless: "🍃"
        case .grateful: "🙏"
        }
    }
}
