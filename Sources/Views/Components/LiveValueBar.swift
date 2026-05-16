import SwiftUI

/// Compact horizontal bar showing labeled live values with colored text.
/// Used in the left panel of interactive modules.
struct LiveValueBar: View {
    let items: [(label: String, value: String, color: Color)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                if idx > 0 {
                    Divider()
                        .frame(height: 28)
                        .background(Theme.Colors.cardBorder)
                }
                VStack(spacing: 2) {
                    Text(item.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Theme.Colors.textTertiary)
                        .lineLimit(1)
                    Text(item.value)
                        .font(Theme.Fonts.formulaFont())
                        .foregroundColor(item.color)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
        )
    }
}
