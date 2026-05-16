import SwiftUI

// Shared drawing for the circuit map layout used in Terminology and Perfect Lap views.
struct CircuitLayoutView: View {
    var showBadges: Bool = false
    var activeConcept: TrackConcept? = nil
    var highlightSection: LapSimulator.SectionType? = nil
    
    @State private var animPhase: CGFloat = 0.0
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            
            // --- Custom Detailed Track Shape ---
            var track = Path()
            
            // Start Finish Straight (Bottom left to right)
            track.move(to: CGPoint(x: w * 0.15, y: h * 0.85))
            track.addLine(to: CGPoint(x: w * 0.70, y: h * 0.85)) // Straight
            
            // Turn 1: Hairpin (Right side, tight curve going back up-left)
            let hairpinCenter = CGPoint(x: w * 0.70, y: h * 0.70)
            track.addArc(center: hairpinCenter, radius: h * 0.15, startAngle: .degrees(90), endAngle: .degrees(-60), clockwise: true)
            
            // Short chute leading to Sweeper
            track.addLine(to: CGPoint(x: w * 0.75, y: h * 0.40))
            
            // Turn 2: Sweeper (Top right, fast long radius curve)
            track.addCurve(
                to: CGPoint(x: w * 0.40, y: h * 0.15),
                control1: CGPoint(x: w * 0.85, y: h * 0.15),
                control2: CGPoint(x: w * 0.60, y: h * 0.10)
            )
            
            // Back Straight (Top)
            track.addLine(to: CGPoint(x: w * 0.25, y: h * 0.15))
            
            // Turn 3: Apex / 90 degree corner (Top left)
            track.addCurve(
                to: CGPoint(x: w * 0.10, y: h * 0.40),
                control1: CGPoint(x: w * 0.10, y: h * 0.15),
                control2: CGPoint(x: w * 0.05, y: h * 0.25)
            )
            
            // Final transition back to Start/Finish
            track.addCurve(
                to: CGPoint(x: w * 0.15, y: h * 0.85),
                control1: CGPoint(x: w * 0.15, y: h * 0.60),
                control2: CGPoint(x: w * 0.10, y: h * 0.75)
            )
            
            // 1. Draw base track surface (Grey)
            context.stroke(
                track,
                with: .color(Theme.Colors.cardBorder.opacity(0.4)),
                style: StrokeStyle(lineWidth: 45, lineCap: .round, lineJoin: .round)
            )
            
            // 2. Draw active section highlights
            if let concept = activeConcept {
                let color = colorForConcept(concept)
                var glow = Path()
                
                switch concept {
                case .straight: // Main Straight (Bottom)
                    glow.move(to: CGPoint(x: w * 0.15, y: h * 0.85))
                    glow.addLine(to: CGPoint(x: w * 0.70, y: h * 0.85))
                    
                case .hairpin: // Turn 1 (Right)
                    let center = CGPoint(x: w * 0.70, y: h * 0.70)
                    glow.addArc(center: center, radius: h * 0.15, startAngle: .degrees(90), endAngle: .degrees(-60), clockwise: true)
                    
                case .sweeper: // Turn 2 (Top Right)
                    glow.move(to: CGPoint(x: w * 0.75, y: h * 0.40))
                    glow.addCurve(
                        to: CGPoint(x: w * 0.40, y: h * 0.15),
                        control1: CGPoint(x: w * 0.85, y: h * 0.15),
                        control2: CGPoint(x: w * 0.60, y: h * 0.10)
                    )
                    
                case .apex: // Turn 3 (Top Left)
                    glow.move(to: CGPoint(x: w * 0.25, y: h * 0.15))
                    glow.addCurve(
                        to: CGPoint(x: w * 0.10, y: h * 0.40),
                        control1: CGPoint(x: w * 0.10, y: h * 0.15),
                        control2: CGPoint(x: w * 0.05, y: h * 0.25)
                    )
                }
                
                // Draw glow stroke exactly over that part of the track
                context.stroke(
                    glow,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 45, lineCap: .round, lineJoin: .round)
                )
                
                // Inner bright core line for the active section
                context.stroke(
                    glow,
                    with: .color(color.opacity(0.8)),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                )
                
                // Animated streak (like a car or airflow traveling through)
                let streakLength: CGFloat = 0.15
                let startTrim = max(0.0, animPhase - streakLength)
                let endTrim = min(1.0, animPhase)
                
                let streakPath = glow.trimmedPath(from: startTrim, to: endTrim)
                context.stroke(
                    streakPath,
                    with: .color(.white),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                )
            }
            
            // 3. Center dashed line (drawn over everything except badges)
            context.stroke(
                track,
                with: .color(Theme.Colors.textTertiary.opacity(0.15)),
                style: StrokeStyle(lineWidth: 2, dash: [10, 8])
            )
            
            // Start/Finish checkered line
            var sfLine = Path()
            sfLine.move(to: CGPoint(x: w * 0.15, y: h * 0.79))
            sfLine.addLine(to: CGPoint(x: w * 0.15, y: h * 0.91))
            context.stroke(sfLine, with: .color(Color.white.opacity(0.6)), style: StrokeStyle(lineWidth: 4, dash: [4, 4]))
        }
        .overlay(
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                if showBadges {
                    // Straight Badge
                    BadgeView(label: "Straight", color: Theme.Colors.dataGreen, isActive: activeConcept == .straight)
                        .position(x: w * 0.40, y: h * 0.90)
                    
                    // Hairpin Badge
                    BadgeView(label: "Hairpin", color: Theme.Colors.dataOrange, isActive: activeConcept == .hairpin)
                        .position(x: w * 0.85, y: h * 0.75)
                    
                    // Sweeper Badge
                    BadgeView(label: "Sweeper", color: Theme.Colors.accentBlue, isActive: activeConcept == .sweeper)
                        .position(x: w * 0.85, y: h * 0.25)
                    
                    // Apex Badge
                    BadgeView(label: "Apex", color: .purple, isActive: activeConcept == .apex)
                        .position(x: w * 0.25, y: h * 0.25)
                }
            }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: activeConcept)
        .onChange(of: activeConcept) { _, newValue in
            // Reset and trigger animation whenever a new concept is tapped
            if newValue != nil {
                animPhase = 0.0
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animPhase = 1.0 + 0.15 // +0.15 ensures streak fully exits the path
                }
            } else {
                withAnimation {
                    animPhase = 0.0
                }
            }
        }
    }
    
    private func colorForConcept(_ concept: TrackConcept) -> Color {
        switch concept {
        case .hairpin: return Theme.Colors.dataOrange
        case .apex: return .purple
        case .sweeper: return Theme.Colors.accentBlue
        case .straight: return Theme.Colors.dataGreen
        }
    }
}

struct BadgeView: View {
    let label: String
    let color: Color
    var isActive: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                // Add a glow when active
                .shadow(color: isActive ? color.opacity(0.9) : color.opacity(0.2), radius: isActive ? 6 : 2)
            
            Text(label)
                .font(.system(size: 13, weight: isActive ? .bold : .semibold, design: .monospaced))
                .foregroundColor(isActive ? .white : color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isActive ? color.opacity(0.2) : Color.black.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(color.opacity(isActive ? 0.8 : 0.3), lineWidth: 1))
        )
        // Elevate the badge when active
        .scaleEffect(isActive ? 1.1 : 1.0)
        .shadow(color: isActive ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
    }
}
