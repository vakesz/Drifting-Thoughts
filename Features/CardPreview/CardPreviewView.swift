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
    private var shareContentSnapshot: [String] {
        [
            viewModel.selectedStyle.rawValue,
            viewModel.themeOverridesSnapshot,
            settings.authorName,
            String(settings.showAuthorOnCard),
            String(settings.showWatermark),
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
                themeOverrides: viewModel.draftThemeOverrides,
                settings: settings,
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
            shareImageURL = viewModel.makeShareURL(settings: settings)
        }
        .onChange(of: shareContentSnapshot) {
            updateShareURL()
        }
    }

    private var customizeSheet: some View {
        NavigationStack {
            Form {
                Section("Colors") {
                    ColorPicker("Body Text", selection: $viewModel.bodyTextColor, supportsOpacity: false)
                    ColorPicker("Background Start", selection: $viewModel.backgroundGradientStart, supportsOpacity: false)
                    ColorPicker("Background End", selection: $viewModel.backgroundGradientEnd, supportsOpacity: false)
                    ColorPicker("Author Text", selection: $viewModel.authorTextColor, supportsOpacity: false)
                    ColorPicker("Watermark Text", selection: $viewModel.watermarkTextColor, supportsOpacity: false)
                }

                Section("Typography") {
                    Picker("Body Font", selection: $viewModel.bodyFontStyle) {
                        ForEach(CardFontStyle.allCases) { fontStyle in
                            Text(fontStyle.label).tag(fontStyle)
                        }
                    }
                }

                Section("Metadata") {
                    Toggle("Show author on this card", isOn: $viewModel.showsAuthor)
                    Toggle("Show watermark on this card", isOn: $viewModel.showsWatermark)
                    TextField("Watermark text", text: $viewModel.watermarkText)
                    HStack {
                        Text("Author Opacity")
                        Slider(value: $viewModel.authorTextOpacity, in: 0...1)
                    }
                    HStack {
                        Text("Watermark Opacity")
                        Slider(value: $viewModel.watermarkTextOpacity, in: 0...1)
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
        shareImageURL = viewModel.makeShareURL(settings: settings)
    }

    private func saveAndDismiss() {
        viewModel.save(in: modelContext)
        saveFeedbackTrigger.toggle()
        onSave?()
        dismiss()
    }
}
