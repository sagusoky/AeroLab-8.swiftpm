import SwiftUI

/// Reusable force arrow component for downforce/drag vectors.
/// Size is proportional to force magnitude.
struct ForceArrow: View {
    let label: String
    let magnitude: Double
    let maxMagnitude: Double
    let color: Color
    let direction: ArrowDirection
    
    enum ArrowDirection {
        case up, down, left, right
    }
    
    private var normalizedLength: CGFloat {
        CGFloat(min(abs(magnitude) / maxMagnitude, 1.0))
    }
    
    var body: some View {
        VStack(spacing: 2) {
            if direction == .up || direction == .down {
                if direction == .up {
                    arrowHead
                    arrowShaft
                    Text(label)
                        .font(Theme.Fonts.caption())
                        .foregroundColor(color)
                } else {
                    Text(label)
                        .font(Theme.Fonts.caption())
                        .foregroundColor(color)
                    arrowShaft
                    arrowHead
                }
            }
        }
    }
    
    @ViewBuilder
    private var arrowShaft: some View {
        Rectangle()
            .fill(color)
            .frame(width: 3, height: max(10, normalizedLength * 60))
    }
    
    @ViewBuilder
    private var arrowHead: some View {
        Image(systemName: direction == .up ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
            .font(Theme.Fonts.smallCaption())
            .foregroundColor(color)
    }
}
