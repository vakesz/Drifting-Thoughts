import SwiftUI

struct CardPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CardPreviewViewModel
    @State private var breathe = false
    @State private var didSave = false
    @State private var showCustomize = false

    init(
        text: String,
        tag: String?,
        moodName: String? = nil,
        existingThought: Thought? = nil,
    ) {
        _viewModel = State(initialValue: CardPreviewViewModel(
            text: text,
            tag: tag,
            moodName: moodName,
            existingThought: existingThought,
        ))
    }

    var body: some View {
        VStack(spacing: DriftLayout.spacingLG) {
            Spacer()

            CardView(
                thought: viewModel.makeThoughtForPreview(),
                style: viewModel.selectedStyle,
                showWatermark: AppSettings.shared.showWatermark,
                customTextColor: viewModel.textColor,
                customMeshColors: viewModel.customMeshColors,
                customTagPosition: viewModel.tagPosition,
            )
            .scaleEffect(breathe ? 1.02 : 1.0)
            .shadow(color: .cardShadow, radius: 20, y: 10)
            .padding(.horizontal, DriftLayout.spacingXL)
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedStyle)

            Spacer()

            CardStylePicker(selectedStyle: $viewModel.selectedStyle)

            customizeToggle
                .padding(.bottom, DriftLayout.spacingMD)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: didSave)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: viewModel.shareText()) {
                    Image(systemName: "square.and.arrow.up")
                }

                Button {
                    viewModel.save(in: modelContext)
                    didSave.toggle()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.down.circle")
                }
            }
        }
        .sheet(isPresented: $showCustomize) {
            customizeSheet
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }

    // MARK: - Customize Toggle

    private var customizeToggle: some View {
        Button {
            showCustomize = true
        } label: {
            Label("Customize", systemImage: "paintpalette")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.brandAccent)
        }
    }

    // MARK: - Customize Sheet

    private var customizeSheet: some View {
        NavigationStack {
            Form {
                Section("Colors") {
                    ColorPicker("Text", selection: $viewModel.textColor, supportsOpacity: false)
                    ColorPicker("Background Start", selection: $viewModel.gradientStart, supportsOpacity: false)
                    ColorPicker("Background End", selection: $viewModel.gradientEnd, supportsOpacity: false)
                }

                Section("Tag Position") {
                    Picker("Position", selection: $viewModel.tagPosition) {
                        ForEach(TagPosition.allCases) { position in
                            Label(position.label, systemImage: position.iconName)
                                .tag(position)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Customize Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showCustomize = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
