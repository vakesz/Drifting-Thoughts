import SwiftUI

struct ComposeView: View {
    @State private var title = ""
    @State private var text = ""
    @State private var isShowingCardDetail = false
    @State private var titleLimitFeedbackTrigger = false
    @State private var characterLimitFeedbackTrigger = false
    @FocusState private var isTextEditorFocused: Bool

    private var canPreview: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

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
                        isShowingCardDetail = true
                    } label: {
                        Image(systemName: "eye")
                    }
                    .disabled(!canPreview)
                }
            }
            .navigationDestination(isPresented: $isShowingCardDetail) {
                CardDetailView(
                    title: title,
                    text: text,
                    onSave: {
                        title = ""
                        text = ""
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
        TextField("Title (optional)", text: $title)
            .font(.headline)
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, DriftLayout.spacingMD)
            .padding(.top, DriftLayout.spacingSM)
            .onChange(of: title) { _, newValue in
                let limited = String(newValue.prefix(DriftLayout.titleCharacterLimit))
                if limited != newValue {
                    title = limited
                }
                if limited.count == DriftLayout.titleCharacterLimit {
                    titleLimitFeedbackTrigger = true
                }
            }
            .sensoryFeedback(.warning, trigger: titleLimitFeedbackTrigger)
    }

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused($isTextEditorFocused)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.textPrimary)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .writingToolsBehavior(.complete)
                .padding(.horizontal, DriftLayout.spacingMD)
                .padding(.top, DriftLayout.spacingSM)
                .onChange(of: text) { _, newValue in
                    let limited = String(newValue.prefix(DriftLayout.bodyCharacterLimit))
                    if limited != newValue {
                        text = limited
                    }
                    if limited.count == DriftLayout.bodyCharacterLimit {
                        characterLimitFeedbackTrigger = true
                    }
                }
                .sensoryFeedback(.warning, trigger: characterLimitFeedbackTrigger)

            if text.isEmpty {
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
            Text("\(title.count)/\(DriftLayout.titleCharacterLimit)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text("\(text.count)/\(DriftLayout.bodyCharacterLimit)")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, DriftLayout.spacingMD)
        .padding(.vertical, DriftLayout.spacingSM)
    }
}
