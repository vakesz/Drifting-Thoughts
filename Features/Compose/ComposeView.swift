import SwiftUI

struct ComposeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ComposeViewModel()
    @State private var showCardPreview = false
    @State private var hitCharLimit = false
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                textEditor

                bottomBar
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isTextEditorFocused = false
                        showCardPreview = true
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(!viewModel.canPreview)
                }
            }
            .navigationDestination(isPresented: $showCardPreview) {
                CardPreviewView(
                    text: viewModel.text,
                    tag: viewModel.detectedTag,
                )
                .onDisappear {
                    viewModel.reset()
                }
            }
            .onAppear {
                if AppSettings.shared.autoOpenKeyboard {
                    isTextEditorFocused = true
                }
            }
        }
    }

    // MARK: - Text Editor

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
                    if newValue.count == DriftLayout.maxCharacterCount {
                        hitCharLimit = true
                    }
                }
                .sensoryFeedback(.warning, trigger: hitCharLimit)

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

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Spacer()

            if let tag = viewModel.detectedTag {
                TagPillView(tag: tag)
            }
        }
        .padding(.horizontal, DriftLayout.spacingMD)
        .padding(.vertical, DriftLayout.spacingSM)
    }
}
