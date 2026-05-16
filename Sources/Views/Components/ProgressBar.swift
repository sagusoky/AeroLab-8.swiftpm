import SwiftUI

/// Bottom progress bar showing page N/M with blue fill and forward button.
struct ModuleProgressBar: View {
    let current: Int
    let total: Int
    var onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(current) / \(total)")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.textSecondary)
                .frame(width: 44, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Theme.Colors.cardBackground)
                        .frame(height: 5)
                    
                    // Fill
                    Capsule()
                        .fill(Theme.Colors.accentBlue)
                        .frame(width: max(0, geo.size.width * CGFloat(current) / CGFloat(total)), height: 5)
                        .animation(.easeInOut(duration: 0.3), value: current)
                }
            }
            .frame(height: 5)
            
            // Forward button
            Button(action: onNext) {
                Circle()
                    .fill(Theme.Colors.accentBlue)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Theme.Colors.accentBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.vertical, 8)
    }
}
