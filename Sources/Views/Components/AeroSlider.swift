import SwiftUI

/// Custom styled slider with blue track, labels, and value display.
struct AeroSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    var minLabel: String = ""
    var maxLabel: String = ""
    var step: Double = 1
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(Theme.Fonts.sliderLabel())
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Text("\(Int(value))  \(unit)")
                    .font(Theme.Fonts.dataReadout())
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Slider(value: Binding(get: {
                self.value
            }, set: { newValue in
                if abs(self.value - newValue) >= step {
                    HapticManager.shared.sliderTick()
                }
                self.value = newValue
            }), in: range, step: step)
                .tint(Theme.Colors.accentBlue)
            
            if !minLabel.isEmpty || !maxLabel.isEmpty {
                HStack {
                    Text(minLabel)
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textTertiary)
                    Spacer()
                    Text(maxLabel)
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
