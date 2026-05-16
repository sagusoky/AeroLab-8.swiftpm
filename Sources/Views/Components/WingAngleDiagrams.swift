import SwiftUI

// MARK: - Lift & Drag Force Arrows Diagram
struct LiftDragDiagram: View {
    var angle: Double
    var downforce: Double
    var drag: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Lift (Downforce) vs Drag")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.moduleYellow)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let cx = w * 0.5
                let cy = h * 0.5
                
                // Track surface
                var ground = Path()
                ground.move(to: CGPoint(x: 10, y: h * 0.8))
                ground.addLine(to: CGPoint(x: w - 10, y: h * 0.8))
                context.stroke(ground, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 1))
                
                // Airflow arrows (entering from left)
                for i in 0..<3 {
                    let yOffset = CGFloat(i) * 15 - 15
                    drawAirflow(context: &context, from: CGPoint(x: cx - 120, y: cy + yOffset), to: CGPoint(x: cx - 60, y: cy + yOffset), color: .cyan.opacity(0.4))
                }
                
                // Draw Wing Profile
                context.translateBy(x: cx, y: cy)
                context.rotate(by: .degrees(angle)) // Rotate by user angle
                
                // Simplistic wing cross-section
                var wing = Path()
                wing.move(to: CGPoint(x: -40, y: 0))
                wing.addQuadCurve(to: CGPoint(x: 40, y: 0), control: CGPoint(x: 0, y: -20))
                wing.addQuadCurve(to: CGPoint(x: -40, y: 0), control: CGPoint(x: 0, y: 5))
                context.fill(wing, with: .color(Theme.Colors.accentBlue.opacity(0.2)))
                context.stroke(wing, with: .color(Theme.Colors.accentBlue), style: StrokeStyle(lineWidth: 2))
                
                // Reset transform for force arrows
                context.rotate(by: .degrees(-angle))
                context.translateBy(x: -cx, y: -cy)
                
                // Force Arrows
                // Downforce (Green, Down)
                let dfLen: CGFloat = CGFloat(downforce / 50.0) // Scale for visualization
                drawForceArrow(context: &context, from: CGPoint(x: cx, y: cy), to: CGPoint(x: cx, y: cy + dfLen), color: Theme.Colors.dataGreen, label: "Downforce")
                
                // Drag (Orange, Right)
                let dragLen: CGFloat = CGFloat(drag / 50.0) // Scale for visualization
                drawForceArrow(context: &context, from: CGPoint(x: cx, y: cy), to: CGPoint(x: cx + dragLen, y: cy), color: Theme.Colors.dataOrange, label: "Drag")
                
            }
            .frame(height: 150)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.moduleYellow.opacity(0.15), lineWidth: 1))
        )
    }
    
    // Helper to draw airflow with arrow head
    private func drawAirflow(context: inout GraphicsContext, from: CGPoint, to: CGPoint, color: Color) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        // Arrowhead
        path.addLine(to: CGPoint(x: to.x - 4, y: to.y - 3))
        path.move(to: to)
        path.addLine(to: CGPoint(x: to.x - 4, y: to.y + 3))
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    }
    
    // Helper to draw force arrows with label
    private func drawForceArrow(context: inout GraphicsContext, from: CGPoint, to: CGPoint, color: Color, label: String) {
        // Only draw if length is significant
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx*dx + dy*dy)
        if len < 5 { return }
        
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        
        // Arrowhead
        let ux = dx / len
        let uy = dy / len
        let headLen: CGFloat = 8
        let headW: CGFloat = 5
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - headLen * ux + headW * uy, y: to.y - headLen * uy - headW * ux))
        head.addLine(to: CGPoint(x: to.x - headLen * ux - headW * uy, y: to.y - headLen * uy + headW * ux))
        head.closeSubpath()
        context.fill(head, with: .color(color))
        
        // Label
        let labelOffset: CGFloat = 12
        let labelPos = CGPoint(x: to.x + (dx > 0 ? labelOffset : 0), y: to.y + (dy > 0 ? labelOffset : (dx > 0 ? 0 : -labelOffset)))
        context.draw(Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(color), at: labelPos)
    }
}

// MARK: - Oversteer vs Understeer Diagram
struct HandlingBalanceDiagram: View {
    var handlingState: AeroPhysics.HandlingState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Oversteer vs Understeer")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.moduleYellow)
            
            HStack(spacing: 20) {
                // Understeer car diagram
                VStack(spacing: 8) {
                    CarHandlingView(state: .understeer, isActive: handlingState == .understeer)
                    Text("Understeer")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(handlingState == .understeer ? Theme.Colors.stateUndersteer : Theme.Colors.textSecondary)
                }
                
                // Neutral car diagram
                VStack(spacing: 8) {
                    CarHandlingView(state: .neutral, isActive: handlingState == .neutral)
                    Text("Neutral")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(handlingState == .neutral ? Theme.Colors.stateStable : Theme.Colors.textSecondary)
                }
                
                // Oversteer car diagram
                VStack(spacing: 8) {
                    CarHandlingView(state: .oversteer, isActive: handlingState == .oversteer)
                    Text("Oversteer")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(handlingState == .oversteer ? Theme.Colors.stateOversteer : Theme.Colors.textSecondary)
                }
            }
            .padding(.top, 10)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.moduleYellow.opacity(0.15), lineWidth: 1))
        )
    }
}

// Helper for drawing car handling
struct CarHandlingView: View {
    let state: AeroPhysics.HandlingState
    let isActive: Bool
    
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            
            // Draw curving road path
            var roadPath = Path()
            roadPath.move(to: CGPoint(x: cx, y: size.height))
            roadPath.addQuadCurve(to: CGPoint(x: cx + 30, y: 0), control: CGPoint(x: cx - 20, y: cy))
            context.stroke(roadPath, with: .color(Theme.Colors.textSecondary.opacity(0.3)), style: StrokeStyle(lineWidth: 15, lineCap: .round))
            
            // Base car color
            let baseColor = Theme.Colors.textTertiary
            var carColor = baseColor
            var rotationAngle: Double = -15
            var xOffset: CGFloat = 0
            
            if isActive {
                switch state {
                case .understeer:
                    carColor = Theme.Colors.stateUndersteer
                    rotationAngle = -5 // Didn't turn enough
                    xOffset = -15 // Slid wide outside the curve
                case .neutral:
                    carColor = Theme.Colors.stateStable
                    rotationAngle = -25 // Turned correctly
                    xOffset = 10 // On the racing line
                case .oversteer:
                    carColor = Theme.Colors.stateOversteer
                    rotationAngle = -50 // Spun out inside
                    xOffset = 20 // Spun to the inside
                }
            } else {
                 // Inactive state styles loosely neutral
                 rotationAngle = -25
                 xOffset = 10
            }
            
            // Draw simple car
            context.translateBy(x: cx + xOffset, y: cy - 10)
            context.rotate(by: .degrees(rotationAngle))
            
            var carBody = Path()
            let carW: CGFloat = 8
            let carH: CGFloat = 20
            carBody.move(to: CGPoint(x: -carW / 2, y: -carH / 2))
            carBody.addLine(to: CGPoint(x: carW / 2, y: -carH / 2))
            carBody.addLine(to: CGPoint(x: carW / 2 + 2, y: carH / 2))
            carBody.addLine(to: CGPoint(x: -carW / 2 - 2, y: carH / 2))
            carBody.closeSubpath()
            context.fill(carBody, with: .color(carColor.opacity(isActive ? 1.0 : 0.4)))
            context.stroke(carBody, with: .color(carColor.opacity(isActive ? 1.0 : 0.4)), style: StrokeStyle(lineWidth: 1))
            
        }
        .frame(width: 80, height: 100)
    }
}
