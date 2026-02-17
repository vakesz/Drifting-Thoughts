import SwiftUI

struct ThoughtRowView: View {
    let thought: Thought

    var body: some View {
        HStack(alignment: .top, spacing: DriftLayout.spacingSM) {
            Circle()
                .fill(thought.style.gradientStartColor)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: DriftLayout.spacingXS) {
                Text(thought.title.isEmpty ? thought.text : thought.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                HStack(spacing: DriftLayout.spacingSM) {
                    if !thought.title.isEmpty {
                        Text(thought.text)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(thought.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(.vertical, DriftLayout.spacingXS)
    }
}
