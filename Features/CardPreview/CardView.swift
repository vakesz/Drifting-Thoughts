import SwiftUI

struct CardView: View {
    let thought: Thought
    let style: CardStyle
    var showWatermark: Bool = true

    // MARK: - Custom Overrides

    var customTextColor: Color?
    var customMeshColors: [Color]?
    var customTagPosition: TagPosition?

    private var resolvedTextColor: Color { customTextColor ?? style.textColor }
    private var resolvedMeshColors: [Color] { customMeshColors ?? style.meshColors }
    private var resolvedTagPosition: TagPosition { customTagPosition ?? .bottomTrailing }

    var body: some View {
        ZStack {
            // Background mesh gradient
            MeshGradient.uniform3x3(colors: resolvedMeshColors)

            // Content overlay
            VStack {
                Spacer()

                Text(thought.text)
                    .font(style.font)
                    .foregroundStyle(resolvedTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DriftLayout.spacingXL)

                Spacer()

                // Watermark
                if showWatermark {
                    VStack(spacing: DriftLayout.spacingXS) {
                        Image(systemName: "sparkle")
                            .font(.caption2)
                            .foregroundStyle(resolvedTextColor.opacity(0.3))
                        Text("drifting thoughts")
                            .font(.caption2)
                            .foregroundStyle(resolvedTextColor.opacity(0.25))
                    }
                    .padding(.bottom, DriftLayout.spacingMD)
                }
            }

            // Tag overlay at chosen position
            if thought.mood != nil || thought.tag != nil {
                tagDetail
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: resolvedTagPosition.alignment,
                    )
                    .padding(.horizontal, DriftLayout.spacingLG)
                    .padding(.vertical, DriftLayout.spacingMD)
            }
        }
        .aspectRatio(DriftLayout.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusLG))
    }

    @ViewBuilder
    private var tagDetail: some View {
        HStack(spacing: DriftLayout.spacingXS) {
            if let mood = thought.mood {
                Text(mood.emoji)
                    .font(.callout)
            }
            if let tag = thought.tag {
                Text("— \(tag)")
                    .font(.caption)
                    .foregroundStyle(resolvedTextColor.opacity(0.6))
                    .italic()
            }
        }
    }
}
