import SwiftUI

struct TagPillView: View {
    let tag: String
    var style: Style = .regular

    enum Style {
        case regular, compact
    }

    var body: some View {
        Text("#\(tag)")
            .font(style == .regular ? .caption : .caption2)
            .foregroundStyle(style == .regular ? Color.textPrimary : Color.textSecondary)
            .padding(.horizontal, DriftLayout.spacingSM)
            .padding(.vertical, style == .regular ? 6 : 2)
            .background(Color.tagPill)
            .clipShape(Capsule())
    }
}
