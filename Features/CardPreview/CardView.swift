import SwiftUI

struct CardView: View {
    let thought: Thought
    let style: CardStyle
    var showWatermark: Bool = true
    var authorName: String?

    // MARK: - Custom Overrides

    var customFontStyle: CardFontStyle?
    var customTextColor: Color?
    var customMeshColors: [Color]?

    private var resolvedTextColor: Color { customTextColor ?? style.textColor }
    private var resolvedMeshColors: [Color] { customMeshColors ?? style.meshColors }
    private var resolvedFont: Font { (customFontStyle ?? thought.fontStyle).font }
    private var resolvedAuthor: String? {
        guard let authorName else { return nil }
        let trimmed = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var body: some View {
        ZStack {
            MeshGradient.uniform3x3(colors: resolvedMeshColors)

            VStack {
                Spacer()

                Text(thought.text)
                    .font(resolvedFont)
                    .foregroundStyle(resolvedTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DriftLayout.spacingXL)

                Spacer()

                if showWatermark || resolvedAuthor != nil {
                    VStack(spacing: DriftLayout.spacingXS) {
                        if let resolvedAuthor {
                            Text("- \(resolvedAuthor)")
                                .font(.caption)
                                .foregroundStyle(resolvedTextColor.opacity(0.5))
                        }

                        if showWatermark {
                            Text("drifting thoughts")
                                .font(.caption2)
                                .foregroundStyle(resolvedTextColor.opacity(0.25))
                        }
                    }
                    .padding(.bottom, DriftLayout.spacingMD)
                }
            }
        }
        .aspectRatio(DriftLayout.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusLG))
    }
}
