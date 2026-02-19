import SwiftUI

struct CardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable private var settings = AppSettings.shared
    @State private var viewModel: CardDetailViewModel
    @State private var saveFeedbackTrigger = false
    @State private var shareImageURL: URL?
    let onSave: (() -> Void)?

    private var isComposePreview: Bool { onSave != nil }

    init(
        text: String,
        existingThought: Thought? = nil,
        onSave: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: CardDetailViewModel(
            text: text,
            existingThought: existingThought
        ))
        self.onSave = onSave
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            cardSection
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
            bodyFontSelection: isComposePreview ? $viewModel.bodyFontStyle : nil,
            authorFontSelection: isComposePreview ? $viewModel.authorFontStyle : nil
        )
        .shadow(color: .cardShadow, radius: 20, y: 10)
        .padding(.horizontal, DriftLayout.spacingMD)
        .padding(.vertical, DriftLayout.spacingMD)
    }

    // MARK: - Actions

    private func saveAndDismiss() {
        viewModel.save(in: modelContext)
        saveFeedbackTrigger.toggle()
        onSave?()
        dismiss()
    }
}
