import SwiftUI

struct CardView: View {
    let thought: Thought
    let style: CardStyle
    var themeOverrides: CardThemeOverrides?
    var settings: AppSettings
    var explicitWidth: CGFloat?
    var bodyFontSelection: Binding<CardFontStyle>?
    var authorFontSelection: Binding<CardFontStyle>?

    @State private var showBodyFontPicker = false
    @State private var showAuthorFontPicker = false

    private var isEditable: Bool { bodyFontSelection != nil || authorFontSelection != nil }

    private var resolvedTheme: ResolvedCardTheme {
        CardThemeResolver.resolve(
            thought: thought,
            style: style,
            settings: settings,
            themeOverrides: themeOverrides
        )
    }

    // MARK: - Dynamic Sizing

    /// Interpolates aspect ratio between min (short text) and max (full text).
    /// Higher ratio value = wider relative to height = shorter card.
    private var dynamicAspectRatio: CGFloat {
        Self.dynamicAspectRatio(for: thought.text)
    }

    static func dynamicAspectRatio(for text: String) -> CGFloat {
        let charCount = text.count
        let maxChars = DriftLayout.bodyCharacterLimit
        let t = min(CGFloat(charCount) / CGFloat(maxChars), 1.0)
        return DriftLayout.cardShortAspectRatio + t * (DriftLayout.cardTallAspectRatio - DriftLayout.cardShortAspectRatio)
    }

    /// Font size that attempts to fill the full card width for the given text.
    /// Uses available width and a scale factor so a single word spans the card;
    /// .minimumScaleFactor handles shrinking for long text.
    private func bodyFontSize(availableWidth: CGFloat) -> CGFloat {
        availableWidth * 0.28
    }

    var body: some View {
        cardContent
            .aspectRatio(dynamicAspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusLG))
    }

    @ViewBuilder
    private var cardContent: some View {
        if let explicitWidth {
            cardLayout(availableWidth: explicitWidth)
        } else {
            GeometryReader { geometry in
                cardLayout(availableWidth: geometry.size.width)
            }
        }
    }

    private func cardLayout(availableWidth: CGFloat) -> some View {
        ZStack {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
                ],
                colors: resolvedTheme.meshGradientColors
            )

            VStack(spacing: 0) {
                Spacer()

                bodyText(availableWidth: availableWidth - DriftLayout.spacingXL * 2)
                    .padding(.horizontal, DriftLayout.spacingXL)

                Spacer()

                if resolvedTheme.showWatermark || resolvedTheme.authorName != nil {
                    VStack(spacing: DriftLayout.spacingXS) {
                        if let authorName = resolvedTheme.authorName {
                            authorTextView(authorName)
                        }

                        if resolvedTheme.showWatermark {
                            Text(DriftLayout.watermarkText)
                                .font(.caption2)
                                .foregroundStyle(resolvedTheme.textColor.opacity(0.25))
                        }
                    }
                    .padding(.bottom, DriftLayout.spacingMD)
                }
            }
        }
    }

    // MARK: - Body Text

    private func bodyText(availableWidth: CGFloat) -> some View {
        Text(thought.text)
            .font(.system(size: bodyFontSize(availableWidth: availableWidth), design: resolvedTheme.bodyFontStyle.design))
            .foregroundStyle(resolvedTheme.textColor)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.3)
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditable { showBodyFontPicker = true }
            }
            .popover(isPresented: $showBodyFontPicker) {
                if let selection = bodyFontSelection {
                    fontPicker(selection: selection)
                }
            }
    }

    // MARK: - Author Text

    private func authorTextView(_ authorName: String) -> some View {
        Text(authorName)
            .font(resolvedTheme.authorFontStyle.captionFont)
            .foregroundStyle(resolvedTheme.textColor.opacity(0.5))
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditable { showAuthorFontPicker = true }
            }
            .popover(isPresented: $showAuthorFontPicker) {
                if let selection = authorFontSelection {
                    fontPicker(selection: selection)
                }
            }
    }

    // MARK: - Font Picker

    private func fontPicker(selection: Binding<CardFontStyle>) -> some View {
        VStack(spacing: 0) {
            ForEach(CardFontStyle.allCases) { fontStyle in
                Button {
                    selection.wrappedValue = fontStyle
                    showBodyFontPicker = false
                    showAuthorFontPicker = false
                } label: {
                    HStack {
                        Text(fontStyle.label)
                            .font(.system(.body, design: fontStyle.design))
                        Spacer()
                        if selection.wrappedValue == fontStyle {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, DriftLayout.spacingMD)
                    .padding(.vertical, DriftLayout.spacingSM)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DriftLayout.spacingSM)
        .presentationCompactAdaptation(.popover)
    }
}
