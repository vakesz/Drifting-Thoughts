import SwiftUI

struct ComposeView: View {
    @State private var viewModel = ComposeViewModel()
    @State private var isShowingCardPreview = false
    @State private var titleLimitFeedbackTrigger = false
    @State private var characterLimitFeedbackTrigger = false
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleField
                textEditor
                footer
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isTextEditorFocused = false
                        isShowingCardPreview = true
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(!viewModel.canPreview)
                }
            }
            .navigationDestination(isPresented: $isShowingCardPreview) {
                CardPreviewView(
                    title: viewModel.title,
                    text: viewModel.text,
                    onSave: {
                        viewModel.reset()
                    },
                )
            }
            .onAppear {
                if AppSettings.shared.autoOpenKeyboard {
                    isTextEditorFocused = true
                }
            }
        }
    }

    private var titleField: some View {
        TextField("Title (optional)", text: $viewModel.title)
            .font(.headline)
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, DriftLayout.spacingMD)
            .padding(.top, DriftLayout.spacingSM)
            .onChange(of: viewModel.title) { _, newValue in
                let limited = String(newValue.prefix(DriftLayout.maxTitleCount))
                if limited != newValue {
                    viewModel.title = limited
                }
                if limited.count == DriftLayout.maxTitleCount {
                    titleLimitFeedbackTrigger = true
                }
            }
            .sensoryFeedback(.warning, trigger: titleLimitFeedbackTrigger)
    }

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.text)
                .focused($isTextEditorFocused)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.textPrimary)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .writingToolsBehavior(.complete)
                .padding(.horizontal, DriftLayout.spacingMD)
                .padding(.top, DriftLayout.spacingSM)
                .onChange(of: viewModel.text) { _, newValue in
                    let limited = String(newValue.prefix(DriftLayout.maxCharacterCount))
                    if limited != newValue {
                        viewModel.text = limited
                    }
                    if limited.count == DriftLayout.maxCharacterCount {
                        characterLimitFeedbackTrigger = true
                    }
                }
                .sensoryFeedback(.warning, trigger: characterLimitFeedbackTrigger)

            if viewModel.text.isEmpty {
                Text("let a thought drift...")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.textPlaceholder)
                    .padding(.horizontal, DriftLayout.spacingMD + 5)
                    .padding(.top, DriftLayout.spacingSM + 8)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Text("\(viewModel.title.count)/\(DriftLayout.maxTitleCount)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text("\(viewModel.text.count)/\(DriftLayout.maxCharacterCount)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, DriftLayout.spacingMD)
        .padding(.vertical, DriftLayout.spacingSM)
    }
}
