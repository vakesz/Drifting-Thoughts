import SwiftUI

struct CardView: View {
    let thought: Thought
    let style: CardStyle
    var themeOverrides: CardThemeOverrides?
    var settings: AppSettings = .shared
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
                                .foregroundStyle(resolvedTheme.textColor.opacity(0.25))
                        }
                    }
                    .padding(.bottom, DriftLayout.spacingMD)
                }
            }
        }
        .aspectRatio(DriftLayout.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusLG))
    }

    // MARK: - Body Text

    private var bodyText: some View {
        Text(thought.text)
            .font(resolvedTheme.bodyFontStyle.font)
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
