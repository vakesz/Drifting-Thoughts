import Foundation

@MainActor
@Observable
final class ComposeViewModel {
    var title: String = ""
    var text: String = ""

    var canPreview: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func reset() {
        title = ""
        text = ""
    }
}
