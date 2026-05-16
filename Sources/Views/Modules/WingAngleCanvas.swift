import SwiftUI

/// 2D Canvas drawing of an airfoil cross-section with angle of attack, airflow, and force arrows.
struct WingAngleCanvas: View {
    let wingAngle: Double
    let downforce: Double
    let drag: Double
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let centerX = w * 0.40
                let centerY = h * 0.50
                let chordLength = w * 0.40
                let alpha = wingAngle * .pi / 180.0
                
                // Airflow label
                context.draw(
                    Text("Airflow →")
                        .font(Theme.Fonts.caption())
                        .foregroundColor(Theme.Colors.textSecondary),
                    at: CGPoint(x: w * 0.42, y: h * 0.16)
                )
                
                // Draw airflow streamlines
                for i in 0..<6 {
                    let yOff = h * 0.22 + CGFloat(i) * h * 0.10
                    var flowPath = Path()
                    flowPath.move(to: CGPoint(x: w * 0.05, y: yOff))
                    
                    // Deflect around wing
                    let deflection: CGFloat = (yOff > centerY) ? CGFloat(alpha) * 20 : -CGFloat(alpha) * 15
                    flowPath.addCurve(
                        to: CGPoint(x: w * 0.95, y: yOff + deflection),
                        control1: CGPoint(x: centerX - chordLength * 0.3, y: yOff),
                        control2: CGPoint(x: centerX + chordLength * 0.3, y: yOff + deflection * 0.8)
                    )
                    context.stroke(flowPath, with: .color(Theme.Colors.accentBlue.opacity(0.3)),
                                  style: StrokeStyle(lineWidth: 0.8))
                }
                
                // Save and rotate context for wing
                context.translateBy(x: centerX, y: centerY)
                context.rotate(by: .radians(-alpha))
                
                // Draw NACA-style airfoil
                let halfChord = chordLength * 0.5
                var airfoilPath = Path()
                
                // Upper surface
                airfoilPath.move(to: CGPoint(x: -halfChord, y: 0))
                airfoilPath.addCurve(
                    to: CGPoint(x: halfChord, y: 0),
                    control1: CGPoint(x: -halfChord * 0.4, y: -chordLength * 0.08),
                    control2: CGPoint(x: halfChord * 0.2, y: -chordLength * 0.04)
                )
                
                // Lower surface
                airfoilPath.addCurve(
                    to: CGPoint(x: -halfChord, y: 0),
                    control1: CGPoint(x: halfChord * 0.2, y: chordLength * 0.02),
                    control2: CGPoint(x: -halfChord * 0.4, y: chordLength * 0.04)
                )
                
                context.fill(airfoilPath, with: .linearGradient(
                    Gradient(colors: [
                        Color(hex: 0x1E3A5F).opacity(0.9),
                        Color(hex: 0x0E1628).opacity(0.7)
                    ]),
                    startPoint: CGPoint(x: 0, y: -chordLength * 0.08),
                    endPoint: CGPoint(x: 0, y: chordLength * 0.04)
                ))
                context.stroke(airfoilPath, with: .color(Theme.Colors.accentBlue.opacity(0.6)), lineWidth: 1.5)
                
                // Chord line
                var chordLine = Path()
                chordLine.move(to: CGPoint(x: -halfChord, y: 0))
                chordLine.addLine(to: CGPoint(x: halfChord, y: 0))
                context.stroke(chordLine, with: .color(Theme.Colors.textTertiary.opacity(0.4)),
                              style: StrokeStyle(lineWidth: 0.8, dash: [4, 3]))
                
                // Restore rotation
                context.rotate(by: .radians(alpha))
                context.translateBy(x: -centerX, y: -centerY)
                
                // Angle arc
                if wingAngle > 0.5 {
                    var arcPath = Path()
                    arcPath.addArc(
                        center: CGPoint(x: centerX - chordLength * 0.5 * CGFloat(cos(alpha)), 
                                       y: centerY + chordLength * 0.5 * CGFloat(sin(alpha))),
                        radius: chordLength * 0.18,
                        startAngle: .degrees(0),
                        endAngle: .degrees(-wingAngle),
                        clockwise: true
                    )
                    context.stroke(arcPath, with: .color(Theme.Colors.textPrimary.opacity(0.6)), lineWidth: 1)
                    
                    // Alpha label
                    context.draw(
                        Text("α")
                            .font(Theme.Fonts.buttonLabel())
                            .foregroundColor(Theme.Colors.textPrimary),
                        at: CGPoint(x: centerX - chordLength * 0.35, y: centerY - chordLength * 0.08)
                    )
                }
            }
            
            // Force arrows (overlay)
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // Downforce arrow (pointing down, orange)
                    VStack(spacing: 2) {
                        Text("Downforce")
                            .font(Theme.Fonts.caption())
                            .foregroundColor(Theme.Colors.forceDownforce)
                        Image(systemName: "arrow.down")
                            .font(Theme.Fonts.sectionTitle())
                            .foregroundColor(Theme.Colors.forceDownforce)
                            .scaleEffect(y: min(2.0, CGFloat(downforce / 2000.0) + 0.5))
                    }
                    .offset(x: -20, y: -40)
                    
                    Spacer()
                    
                    // Drag arrow (pointing right, red)
                    HStack(spacing: 2) {
                        Text("Drag")
                            .font(Theme.Fonts.caption())
                            .foregroundColor(Theme.Colors.forceDrag)
                        Image(systemName: "arrow.right")
                            .font(Theme.Fonts.sectionTitle())
                            .foregroundColor(Theme.Colors.forceDrag)
                            .scaleEffect(x: min(2.0, CGFloat(drag / 500.0) + 0.5))
                    }
                    .offset(x: 30, y: -80)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}
