import SwiftUI

struct CardPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable private var settings = AppSettings.shared
    @State private var viewModel: CardPreviewViewModel
    @State private var saveFeedbackTrigger = false
    @State private var showBodyFontPicker = false
    @State private var showAuthorFontPicker = false
    @State private var shareImageURL: URL?
    let onSave: (() -> Void)?

    private var isComposePreview: Bool { onSave != nil }

    init(
        title: String,
        text: String,
        existingThought: Thought? = nil,
        onSave: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: CardPreviewViewModel(
            title: title,
            text: text,
            existingThought: existingThought
        ))
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: DriftLayout.spacingLG) {
            cardSection

            Spacer(minLength: DriftLayout.spacingSM)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: saveFeedbackTrigger)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !isComposePreview, let shareImageURL {
                    ShareLink(item: shareImageURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share image")
                }

                if isComposePreview {
                    Button("Save") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if !isComposePreview {
                shareImageURL = viewModel.makeShareURL(settings: settings)
            }
        }
    }

    // MARK: - Card

    private var cardSection: some View {
        CardView(
            thought: viewModel.makeThoughtForPreview(),
            style: viewModel.selectedStyle,
            themeOverrides: viewModel.draftThemeOverrides,
            settings: settings,
            isEditable: isComposePreview,
            onBodyFontTapped: { showBodyFontPicker = true },
            onAuthorFontTapped: { showAuthorFontPicker = true }
        )
        .shadow(color: .cardShadow, radius: 20, y: 10)
        .padding(.horizontal, DriftLayout.spacingXL)
        .padding(.top, DriftLayout.spacingMD)
        .popover(isPresented: $showBodyFontPicker) {
            fontPicker(selection: $viewModel.bodyFontStyle)
        }
        .popover(isPresented: $showAuthorFontPicker) {
            fontPicker(selection: $viewModel.authorFontStyle)
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
                            .font(fontStyle.font)
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

    // MARK: - Actions

    private func saveAndDismiss() {
        viewModel.save(in: modelContext)
        saveFeedbackTrigger.toggle()
        onSave?()
        dismiss()
    }
}
