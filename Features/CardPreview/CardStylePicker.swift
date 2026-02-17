import SwiftUI

struct CardStylePicker: View {
    @Binding var selectedStyle: CardStyle

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DriftLayout.spacingSM) {
                ForEach(CardStyle.allCases) { style in
                    Button {
                        selectedStyle = style
                    } label: {
                        styleThumbnail(style)
                    }
                    .sensoryFeedback(.selection, trigger: selectedStyle)
                    .accessibilityLabel(style.label)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, DriftLayout.spacingMD)
        }
        .scrollTargetBehavior(.viewAligned)
    }

    private func styleThumbnail(_ style: CardStyle) -> some View {
        VStack(spacing: DriftLayout.spacingXS) {
            RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusSM)
                .fill(MeshGradient.uniform3x3(colors: style.meshColors))
                .frame(width: 64, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: DriftLayout.cornerRadiusSM)
                        .strokeBorder(
                            selectedStyle == style ? Color.brandAccent : Color.clear,
                            lineWidth: 2,
                        )
                )

            Text(style.label)
                .font(.caption)
                .foregroundStyle(
                    selectedStyle == style ? Color.brandAccent : Color.textSecondary
                )
        }
    }
}
