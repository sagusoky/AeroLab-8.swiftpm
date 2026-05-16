import SwiftUI

/// 2D Canvas drawing of F1 car side view with airflow, pressure zones, and downforce arrow.
struct GroundEffectCanvas: View {
    let rideHeight: Double
    let velocity: Double
    let downforce: Double
    let isStalled: Bool
    
    @State private var animationPhase: Double = 0
    
    var body: some View {
        ZStack {
            // Main Canvas
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let groundY = h * 0.72
                let carBottom = groundY - CGFloat(rideHeight / 50.0) * h * 0.12 - h * 0.02
                let carTop = carBottom - h * 0.18
                let carLeft = w * 0.12
                let carRight = w * 0.88
                
                // Ground line
                var groundPath = Path()
                groundPath.move(to: CGPoint(x: 0, y: groundY))
                groundPath.addLine(to: CGPoint(x: w, y: groundY))
                context.stroke(groundPath, with: .color(Theme.Colors.textTertiary.opacity(0.5)),
                              style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                
                // Airflow streamlines above car
                for i in 0..<4 {
                    let yOff = carTop - CGFloat(i) * h * 0.04 - h * 0.02
                    var flowPath = Path()
                    let phase = CGFloat(animationPhase)
                    flowPath.move(to: CGPoint(x: w * 0.02 - phase.truncatingRemainder(dividingBy: 30), y: yOff))
                    flowPath.addCurve(
                        to: CGPoint(x: w * 0.98, y: yOff + h * 0.01),
                        control1: CGPoint(x: w * 0.35, y: yOff - h * 0.02),
                        control2: CGPoint(x: w * 0.65, y: yOff + h * 0.02)
                    )
                    context.stroke(flowPath, with: .color(Theme.Colors.accentBlue.opacity(0.25)),
                                  style: StrokeStyle(lineWidth: 1.0))
                }
                
                // Airflow streamlines below car (faster → closer together)
                let gapFactor = CGFloat(rideHeight) / 50.0
                for i in 0..<3 {
                    let yOff = carBottom + CGFloat(i + 1) * h * 0.015 * gapFactor + h * 0.005
                    var flowPath = Path()
                    flowPath.move(to: CGPoint(x: carLeft - w * 0.08, y: yOff))
                    flowPath.addCurve(
                        to: CGPoint(x: carRight + w * 0.08, y: yOff),
                        control1: CGPoint(x: w * 0.40, y: yOff - h * 0.01),
                        control2: CGPoint(x: w * 0.60, y: yOff + h * 0.01)
                    )
                    context.stroke(flowPath, with: .color(Theme.Colors.accentBlue.opacity(0.4)),
                                  style: StrokeStyle(lineWidth: 1.2))
                }
                
                // Car body
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: carLeft, y: carBottom))
                bodyPath.addLine(to: CGPoint(x: carLeft + w * 0.08, y: carBottom - h * 0.02))
                bodyPath.addLine(to: CGPoint(x: carLeft + w * 0.15, y: carTop + h * 0.10))
                bodyPath.addCurve(
                    to: CGPoint(x: w * 0.42, y: carTop),
                    control1: CGPoint(x: carLeft + w * 0.22, y: carTop + h * 0.06),
                    control2: CGPoint(x: w * 0.35, y: carTop)
                )
                bodyPath.addLine(to: CGPoint(x: w * 0.50, y: carTop - h * 0.01))
                bodyPath.addCurve(
                    to: CGPoint(x: carRight - w * 0.10, y: carTop + h * 0.06),
                    control1: CGPoint(x: w * 0.58, y: carTop - h * 0.01),
                    control2: CGPoint(x: w * 0.68, y: carTop + h * 0.02)
                )
                bodyPath.addLine(to: CGPoint(x: carRight, y: carBottom))
                bodyPath.closeSubpath()
                
                context.fill(bodyPath, with: .linearGradient(
                    Gradient(colors: [
                        Color(hex: 0x1A2744).opacity(0.9),
                        Color(hex: 0x0E1628).opacity(0.8)
                    ]),
                    startPoint: CGPoint(x: 0, y: carTop),
                    endPoint: CGPoint(x: 0, y: carBottom)
                ))
                context.stroke(bodyPath, with: .color(Theme.Colors.accentBlue.opacity(0.5)), lineWidth: 1.5)
                
                // Wheels
                let wheelR: CGFloat = h * 0.06
                drawWheel(context: context, center: CGPoint(x: carLeft + w * 0.10, y: carBottom + wheelR * 0.4), radius: wheelR)
                drawWheel(context: context, center: CGPoint(x: carRight - w * 0.10, y: carBottom + wheelR * 0.4), radius: wheelR)
                
                // Front wing
                var fwing = Path()
                fwing.addRoundedRect(in: CGRect(x: carLeft - w * 0.04, y: carBottom - h * 0.005, width: w * 0.12, height: h * 0.025), cornerSize: CGSize(width: 2, height: 2))
                context.fill(fwing, with: .color(Color(hex: 0x1A2744).opacity(0.7)))
                context.stroke(fwing, with: .color(Theme.Colors.accentBlue.opacity(0.4)), lineWidth: 1)
                
                // Rear wing
                let rwingY = carTop - h * 0.05
                var rwing = Path()
                rwing.addRoundedRect(in: CGRect(x: carRight - w * 0.06, y: rwingY, width: w * 0.10, height: h * 0.025), cornerSize: CGSize(width: 2, height: 2))
                context.fill(rwing, with: .color(Color(hex: 0x1A2744).opacity(0.7)))
                context.stroke(rwing, with: .color(Theme.Colors.accentBlue.opacity(0.4)), lineWidth: 1)
                
                // Wing support
                var support = Path()
                support.move(to: CGPoint(x: carRight - w * 0.02, y: rwingY + h * 0.025))
                support.addLine(to: CGPoint(x: carRight - w * 0.04, y: carTop + h * 0.06))
                context.stroke(support, with: .color(Theme.Colors.accentBlue.opacity(0.3)), lineWidth: 1)
                
                // Ride height dimension line
                let dimX = carRight + w * 0.06
                var dimLine = Path()
                dimLine.move(to: CGPoint(x: dimX, y: carBottom))
                dimLine.addLine(to: CGPoint(x: dimX, y: groundY))
                context.stroke(dimLine, with: .color(Theme.Colors.textSecondary.opacity(0.6)),
                              style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                
                // Dimension ticks
                var topTick = Path()
                topTick.move(to: CGPoint(x: dimX - 4, y: carBottom))
                topTick.addLine(to: CGPoint(x: dimX + 4, y: carBottom))
                context.stroke(topTick, with: .color(Theme.Colors.textSecondary.opacity(0.6)), lineWidth: 1)
                
                var bottomTick = Path()
                bottomTick.move(to: CGPoint(x: dimX - 4, y: groundY))
                bottomTick.addLine(to: CGPoint(x: dimX + 4, y: groundY))
                context.stroke(bottomTick, with: .color(Theme.Colors.textSecondary.opacity(0.6)), lineWidth: 1)
                
                // Dimension label
                context.draw(
                    Text("\(Int(rideHeight))mm")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textSecondary),
                    at: CGPoint(x: dimX + w * 0.04, y: (carBottom + groundY) / 2)
                )
            }
            
            // Pressure labels (overlay)
            VStack {
                // HIGH PRESSURE above
                Text("HIGH PRESSURE ↓")
                    .font(Theme.Fonts.badgeLabel())
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Theme.Colors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                            )
                    )
                    .offset(x: -60, y: -20)
                
                // Downforce arrow label
                VStack(spacing: 1) {
                    Text("DF")
                        .font(Theme.Fonts.caption())
                        .foregroundColor(Theme.Colors.forceDownforce)
                    Image(systemName: "arrow.down")
                        .font(Theme.Fonts.buttonLabel())
                        .foregroundColor(Theme.Colors.forceDownforce)
                        .scaleEffect(y: min(1.5, CGFloat(downforce / 3000.0) + 0.5))
                }
                .offset(x: 10, y: -20)
                
                Spacer()
                
                // LOW PRESSURE below
                Text("↑ LOW PRESSURE ↑")
                    .font(Theme.Fonts.badgeLabel())
                    .foregroundColor(Theme.Colors.accentBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Theme.Colors.accentBlue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Theme.Colors.accentBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .offset(y: -60)
            }
            .padding(.vertical, 20)
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                animationPhase = 30
            }
        }
    }
    
    private func drawWheel(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let wheelRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let wheelPath = Path(ellipseIn: wheelRect)
        context.fill(wheelPath, with: .color(Color(hex: 0x2A3040)))
        context.stroke(wheelPath, with: .color(Theme.Colors.accentBlue.opacity(0.3)), lineWidth: 1)
    }
}
