import SwiftUI

struct CardView: View {
    let thought: Thought
    let style: CardStyle
    var themeOverrides: CardThemeOverrides?
    var settings: AppSettings = .shared

    private var resolvedTheme: ResolvedCardTheme {
        CardThemeResolver.resolve(
            thought: thought,
            style: style,
            settings: settings,
            themeOverrides: themeOverrides,
        )
    }
    private var bodyFont: Font { resolvedTheme.bodyFontStyle.font }
    private var horizontalTextPadding: CGFloat {
        DriftLayout.spacingXL * CGFloat(resolvedTheme.textPaddingScale)
    }

    var body: some View {
        ZStack {
            MeshGradient.uniform3x3(colors: resolvedTheme.meshGradientColors)

            VStack(spacing: 0) {
                contentTopSpacer

                Text(thought.text)
                    .font(bodyFont)
                    .foregroundStyle(resolvedTheme.bodyTextColor)
                    .lineSpacing(resolvedTheme.lineSpacing)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, horizontalTextPadding)

                contentBottomSpacer

                if resolvedTheme.showWatermark || resolvedTheme.showAuthor {
                    VStack(spacing: DriftLayout.spacingXS) {
                        if let authorName = resolvedTheme.authorName, resolvedTheme.showAuthor {
                            Text("- \(authorName)")
                                .font(.caption)
                                .foregroundStyle(
                                    resolvedTheme.authorTextColor.opacity(resolvedTheme.authorTextOpacity)
                                )
                        }

                        if resolvedTheme.showWatermark {
                            Text(resolvedTheme.watermarkText)
                                .font(.caption2)
                                .foregroundStyle(
                                    resolvedTheme.watermarkTextColor.opacity(resolvedTheme.watermarkTextOpacity)
                                )
                        }
                    }
                    .padding(.bottom, DriftLayout.spacingMD)
                }
            }
        }
        .aspectRatio(DriftLayout.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusLG))
    }

    @ViewBuilder
    private var contentTopSpacer: some View {
        switch resolvedTheme.contentAlignment {
        case .top:
            EmptyView()
        case .center:
            Spacer()
        case .bottom:
            Spacer()
            Spacer()
        }
    }

    @ViewBuilder
    private var contentBottomSpacer: some View {
        switch resolvedTheme.contentAlignment {
        case .top:
            Spacer()
            Spacer()
        case .center:
            Spacer()
        case .bottom:
            EmptyView()
        }
    }
}
