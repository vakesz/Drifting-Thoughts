import SwiftUI

struct CardView: View {
    let thought: Thought
    let style: CardStyle
    var themeOverrides: CardThemeOverrides?
    var settings: AppSettings = .shared
    var isEditable: Bool = false
    var onBodyFontTapped: (() -> Void)?
    var onAuthorFontTapped: (() -> Void)?

    private var resolvedTheme: ResolvedCardTheme {
        CardThemeResolver.resolve(
            thought: thought,
            style: style,
            settings: settings,
            themeOverrides: themeOverrides
        )
    }

    private var bodyFont: Font { resolvedTheme.bodyFontStyle.font }
    private var authorFont: Font { resolvedTheme.authorFontStyle.captionFont }

    var body: some View {
        ZStack {
            MeshGradient.uniform3x3(colors: resolvedTheme.meshGradientColors)

            VStack(spacing: 0) {
                Spacer()

                bodyText
                    .padding(.horizontal, DriftLayout.spacingXL)

                Spacer()

                if resolvedTheme.showWatermark || resolvedTheme.showAuthor {
                    VStack(spacing: DriftLayout.spacingXS) {
                        if let authorName = resolvedTheme.authorName, resolvedTheme.showAuthor {
                            authorTextView(authorName)
                        }

                        if resolvedTheme.showWatermark {
                            Text(DriftLayout.watermarkText)
                                .font(.caption2)
                                .foregroundStyle(resolvedTheme.watermarkTextColor.opacity(0.25))
                        }
                    }
                    .padding(.bottom, DriftLayout.spacingMD)
                }
            }
        }
        .aspectRatio(DriftLayout.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusLG))
    }

    private var bodyText: some View {
        Text(thought.text)
            .font(bodyFont)
            .foregroundStyle(resolvedTheme.bodyTextColor)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.3)
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditable { onBodyFontTapped?() }
            }
    }

    private func authorTextView(_ authorName: String) -> some View {
        Text("- \(authorName)")
            .font(authorFont)
            .foregroundStyle(resolvedTheme.authorTextColor.opacity(0.5))
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditable { onAuthorFontTapped?() }
            }
    }
}
