import SwiftData
import SwiftUI

struct ComposeView: View {
    @Query(sort: \Thought.createdAt, order: .reverse) private var thoughts: [Thought]
    @Bindable private var settings = AppSettings.shared
    @State private var text = ""
    @State private var isShowingCardDetail = false
    @State private var isShowingDiscardAlert = false
    @State private var characterLimitFeedbackTrigger = false
    @FocusState private var isTextEditorFocused: Bool

    private var canPreview: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var hasContent: Bool { !text.isEmpty }
    private var isEditing: Bool { hasContent || isTextEditorFocused }

    private var streak: Int {
        Self.calculateStreak(from: thoughts, frequency: settings.streakFrequency)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()

                editorLayout
                    .opacity(isEditing ? 1 : 0)

                if !isEditing {
                    welcomeView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isEditing)
            .navigationTitle(isEditing ? "new thought" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if hasContent {
                        Button {
                            isTextEditorFocused = false
                            isShowingDiscardAlert = true
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if canPreview {
                        Button {
                            isTextEditorFocused = false
                            isShowingCardDetail = true
                        } label: {
                            Image(systemName: "eye")
                        }
                    }
                }
            }
            .alert("Discard this thought?", isPresented: $isShowingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    text = ""
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(isPresented: $isShowingCardDetail) {
                CardDetailView(
                    text: text,
                    onSave: {
                        text = ""
                    }
                )
            }
            .onAppear {
                if hasContent {
                    isTextEditorFocused = true
                }
            }
        }
    }

    // MARK: - Welcome

    private var greeting: (icon: String, text: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12: return ("sun.horizon", "good morning")
        case 12 ..< 17: return ("sun.max", "good afternoon")
        default: return ("moon.stars", "good evening")
        }
    }

    private var welcomeView: some View {
        VStack {
            Spacer()

            VStack(spacing: DriftLayout.spacingSM) {
                Image(systemName: greeting.icon)
                    .font(.system(.title))
                    .foregroundStyle(Color.textPlaceholder)
                    .padding(.bottom, DriftLayout.spacingXS)

                Text(greeting.text)
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(Color.textPrimary)

                Text("let a thought drift...")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.textPlaceholder)

                Text("tap anywhere to begin")
                    .font(.caption)
                    .foregroundStyle(Color.textPlaceholder.opacity(0.6))
                    .padding(.top, DriftLayout.spacingXS)
            }

            Spacer()

            if streak > 0 {
                HStack(spacing: DriftLayout.spacingSM) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.brandAccent)
                        .symbolEffect(.bounce, value: streak)
                    Text("\(streak) \(settings.streakFrequency.streakUnit) streak")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.bottom, DriftLayout.spacingMD)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            isTextEditorFocused = true
        }
    }

    // MARK: - Editor

    private var editorLayout: some View {
        VStack(spacing: 0) {
            if hasContent { characterCount }
            textEditor
        }
    }

    // MARK: - Text Editor

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

    // MARK: - Character Count

    private var characterCount: some View {
        Text("\(text.count)/\(DriftLayout.bodyCharacterLimit)")
            .font(.caption)
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, DriftLayout.spacingMD)
            .padding(.top, DriftLayout.spacingXS)
            .transition(.opacity)
    }

    // MARK: - Streak Calculation

    static func calculateStreak(from thoughts: [Thought], frequency: StreakFrequency) -> Int {
        guard !thoughts.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let interval = frequency.intervalDays

        let uniqueDays = Set(thoughts.map { calendar.startOfDay(for: $0.createdAt) })
            .sorted(by: >)

        guard let mostRecent = uniqueDays.first else { return 0 }

        // Streak only counts if the most recent entry is within the current interval
        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        guard daysSinceLast <= interval else { return 0 }

        var streak = 1
        for idx in 1 ..< uniqueDays.count {
            let gap = calendar.dateComponents([.day], from: uniqueDays[idx], to: uniqueDays[idx - 1]).day ?? 0
            if gap <= interval {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}
