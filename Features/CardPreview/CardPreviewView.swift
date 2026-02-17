import SwiftUI

struct CardPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable private var settings = AppSettings.shared
    @State private var viewModel: CardPreviewViewModel
    @State private var saveFeedbackTrigger = false
    @State private var isShowingCustomizeSheet = false
    @State private var shareImageURL: URL?
    let onSave: (() -> Void)?

    private var isComposePreview: Bool { onSave != nil }
    private var authorForCard: String? {
        settings.showAuthorOnCard ? settings.authorName : nil
    }
    private var shareContentFingerprint: [String] {
        [
            viewModel.selectedStyle.rawValue,
            viewModel.selectedFontStyle.rawValue,
            viewModel.textColor.hexString ?? "",
            viewModel.gradientStart.hexString ?? "",
            viewModel.gradientEnd.hexString ?? "",
        ]
    }

    init(
        title: String,
        text: String,
        existingThought: Thought? = nil,
        onSave: (() -> Void)? = nil,
    ) {
        _viewModel = State(initialValue: CardPreviewViewModel(
            title: title,
            text: text,
            existingThought: existingThought,
        ))
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: DriftLayout.spacingLG) {
            CardView(
                thought: viewModel.makeThoughtForPreview(),
                style: viewModel.selectedStyle,
                showWatermark: settings.showWatermark,
                authorName: authorForCard,
                customFontStyle: viewModel.selectedFontStyle,
                customTextColor: viewModel.textColor,
                customMeshColors: viewModel.customMeshColors,
            )
            .shadow(color: .cardShadow, radius: 20, y: 10)
            .padding(.horizontal, DriftLayout.spacingXL)
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedStyle)
            .padding(.top, DriftLayout.spacingMD)

            if isComposePreview {
                CardStylePicker(selectedStyle: $viewModel.selectedStyle)
            }

            Spacer(minLength: DriftLayout.spacingSM)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: saveFeedbackTrigger)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let shareImageURL {
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

                    Button {
                        isShowingCustomizeSheet = true
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                    .accessibilityLabel("Customize")
                }
            }
        }
        .sheet(isPresented: $isShowingCustomizeSheet) {
            customizeSheet
        }
        .onAppear {
            shareImageURL = viewModel.makeShareURL(
                showWatermark: settings.showWatermark,
                authorName: authorForCard,
            )
        }
        .onChange(of: shareContentFingerprint) {
            updateShareURL()
        }
    }

    private var customizeSheet: some View {
        NavigationStack {
            Form {
                Section("Colors") {
                    ColorPicker("Text", selection: $viewModel.textColor, supportsOpacity: false)
                    ColorPicker("Background Start", selection: $viewModel.gradientStart, supportsOpacity: false)
                    ColorPicker("Background End", selection: $viewModel.gradientEnd, supportsOpacity: false)
                }

                Section("Typography") {
                    Picker("Font", selection: $viewModel.selectedFontStyle) {
                        ForEach(CardFontStyle.allCases) { fontStyle in
                            Text(fontStyle.label).tag(fontStyle)
                        }
                    }
                }
            }
            .navigationTitle("Customize Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isShowingCustomizeSheet = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func updateShareURL() {
        shareImageURL = viewModel.makeShareURL(
            showWatermark: settings.showWatermark,
            authorName: authorForCard,
        )
    }

    private func saveAndDismiss() {
        viewModel.save(in: modelContext)
        saveFeedbackTrigger.toggle()
        onSave?()
        dismiss()
    }
}
