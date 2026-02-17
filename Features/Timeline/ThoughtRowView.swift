import SwiftUI

struct ThoughtRowView: View {
    let thought: Thought

    var body: some View {
        HStack(alignment: .top, spacing: DriftLayout.spacingSM) {
            // Style color dot
            Circle()
                .fill(thought.style.gradientStartColor)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: DriftLayout.spacingXS) {
                Text(thought.text)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                HStack(spacing: DriftLayout.spacingSM) {
                    if let mood = thought.mood {
                        Text(mood.emoji)
                            .font(.caption)
                    }

                    if let tag = thought.tag {
                        TagPillView(tag: tag, style: .compact)
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
