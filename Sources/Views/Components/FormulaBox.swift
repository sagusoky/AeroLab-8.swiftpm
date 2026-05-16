import SwiftUI

/// Styled formula display with variable definitions below.
struct FormulaBox: View {
    let formula: String
    let variables: [(symbol: String, meaning: String)]
    var accentColor: Color = Theme.Colors.accentBlue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formula)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundColor(accentColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(accentColor.opacity(0.08))
                )
            
            ForEach(Array(variables.enumerated()), id: \.offset) { _, v in
                HStack(spacing: 6) {
                    Text(v.symbol)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(accentColor)
                        .frame(width: 24, alignment: .trailing)
                    Text("=")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textTertiary)
                    Text(v.meaning)
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Theme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
        )
    }
}
