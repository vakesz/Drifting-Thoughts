import Foundation

@MainActor
@Observable
final class ComposeViewModel {
    var text: String = ""

    var canPreview: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    // swiftlint:disable:next force_try
    private static let tagPattern = try! Regex(#"#(\p{Letter}[\p{Letter}\p{Number}_]*)"#)

    /// Auto-extracts the first #hashtag from the text
    var detectedTag: String? {
        guard let match = text.firstMatch(of: Self.tagPattern),
              let captured = match.output[1].substring
        else {
            return nil
        }
        let raw = String(captured)
            .lowercased()
            .prefix(DriftLayout.maxTagLength)
        return raw.isEmpty ? nil : String(raw)
    }

    func reset() {
        text = ""
    }
}
