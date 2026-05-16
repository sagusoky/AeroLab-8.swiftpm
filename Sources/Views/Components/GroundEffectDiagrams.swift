import SwiftUI

// MARK: - Venturi Tunnel Cross-Section Diagram
/// Shows how the car floor narrows the gap with the ground,
/// accelerating airflow and creating low pressure underneath.
struct VenturiTunnelDiagram: View {
    var rideHeight: Double = 25
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Venturi Tunnel Effect")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.accentBlue)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                
                // Ground line
                var groundLine = Path()
                groundLine.move(to: CGPoint(x: 0, y: h * 0.85))
                groundLine.addLine(to: CGPoint(x: w, y: h * 0.85))
                context.stroke(groundLine, with: .color(Color.gray.opacity(0.6)), style: StrokeStyle(lineWidth: 2))
                
                // Ground label
                context.draw(
                    Text("TRACK SURFACE").font(.system(size: 7, weight: .bold)).foregroundColor(.gray),
                    at: CGPoint(x: w * 0.5, y: h * 0.93)
                )
                
                // Car floor (narrowing shape — Venturi profile)
                let gapFraction = CGFloat(rideHeight / 50.0)
                let floorY = h * 0.85 - 12 - (gapFraction * 25) // gap above ground
                
                var floorPath = Path()
                floorPath.move(to: CGPoint(x: w * 0.05, y: floorY + 8))
                // Entry (wider)
                floorPath.addLine(to: CGPoint(x: w * 0.20, y: floorY + 4))
                // Throat (narrowest — maximum venturi)
                floorPath.addQuadCurve(
                    to: CGPoint(x: w * 0.55, y: floorY - 2),
                    control: CGPoint(x: w * 0.38, y: floorY - 6)
                )
                // Diffuser exit (widens)
                floorPath.addQuadCurve(
                    to: CGPoint(x: w * 0.95, y: floorY + 14),
                    control: CGPoint(x: w * 0.75, y: floorY)
                )
                
                context.stroke(floorPath, with: .color(Theme.Colors.accentBlue), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                
                // Car body above floor
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: w * 0.05, y: floorY - 4))
                bodyPath.addQuadCurve(
                    to: CGPoint(x: w * 0.95, y: floorY + 6),
                    control: CGPoint(x: w * 0.45, y: floorY - 30)
                )
                context.stroke(bodyPath, with: .color(Theme.Colors.textTertiary), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                
                // Airflow arrows under car (blue, getting faster at throat)
                let arrowY = (floorY + h * 0.85) / 2
                for i in 0..<5 {
                    let xStart = w * (0.10 + CGFloat(i) * 0.17)
                    let xEnd = xStart + w * 0.12
                    let speed = i == 2 ? 1.5 : (i == 1 || i == 3 ? 1.2 : 0.8)
                    
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: xStart, y: arrowY))
                    arrow.addLine(to: CGPoint(x: xEnd, y: arrowY))
                    // Arrowhead
                    arrow.addLine(to: CGPoint(x: xEnd - 4, y: arrowY - 3))
                    arrow.move(to: CGPoint(x: xEnd, y: arrowY))
                    arrow.addLine(to: CGPoint(x: xEnd - 4, y: arrowY + 3))
                    
                    let opacity = 0.4 + speed * 0.3
                    context.stroke(arrow, with: .color(Color.cyan.opacity(opacity)),
                                   style: StrokeStyle(lineWidth: CGFloat(speed) * 1.2, lineCap: .round))
                }
                
                // Labels
                context.draw(
                    Text("Fast air").font(.system(size: 8, weight: .bold)).foregroundColor(.cyan),
                    at: CGPoint(x: w * 0.42, y: arrowY - 10)
                )
                context.draw(
                    Text("LOW P").font(.system(size: 8, weight: .heavy)).foregroundColor(Theme.Colors.dataGreen),
                    at: CGPoint(x: w * 0.42, y: arrowY + 12)
                )
                
                // Ride height annotation
                var rhLine = Path()
                rhLine.move(to: CGPoint(x: w * 0.15, y: floorY + 5))
                rhLine.addLine(to: CGPoint(x: w * 0.15, y: h * 0.85))
                context.stroke(rhLine, with: .color(Theme.Colors.moduleYellow.opacity(0.6)),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                context.draw(
                    Text("\(Int(rideHeight))mm").font(.system(size: 7, weight: .bold, design: .monospaced)).foregroundColor(Theme.Colors.moduleYellow),
                    at: CGPoint(x: w * 0.15, y: (floorY + h * 0.85) / 2)
                )
                
                // Diffuser label
                context.draw(
                    Text("Diffuser").font(.system(size: 8, weight: .medium)).foregroundColor(Theme.Colors.textTertiary),
                    at: CGPoint(x: w * 0.85, y: floorY + 22)
                )
            }
            .frame(height: 110)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.accentBlue.opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Aerodynamic Forces Diagram
/// Shows the key forces acting on an F1 car: downforce (down), drag (backward),
/// thrust (forward), and weight (down from center).
struct AeroForcesDiagram: View {
    var downforce: Double = 0
    var isStalled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Forces on the Car")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.moduleYellow)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let carCenterX = w * 0.5
                let carCenterY = h * 0.50
                
                // Simplified car silhouette (side view)
                var carBody = Path()
                carBody.move(to: CGPoint(x: w * 0.15, y: carCenterY + 2))
                carBody.addLine(to: CGPoint(x: w * 0.22, y: carCenterY - 6))
                carBody.addLine(to: CGPoint(x: w * 0.35, y: carCenterY - 14))
                carBody.addQuadCurve(
                    to: CGPoint(x: w * 0.65, y: carCenterY - 18),
                    control: CGPoint(x: w * 0.50, y: carCenterY - 22)
                )
                carBody.addLine(to: CGPoint(x: w * 0.78, y: carCenterY - 10))
                // Rear wing
                carBody.addLine(to: CGPoint(x: w * 0.80, y: carCenterY - 22))
                carBody.addLine(to: CGPoint(x: w * 0.85, y: carCenterY - 22))
                carBody.addLine(to: CGPoint(x: w * 0.85, y: carCenterY + 2))
                carBody.closeSubpath()
                
                context.fill(carBody, with: .color(Theme.Colors.accentBlue.opacity(0.15)))
                context.stroke(carBody, with: .color(Theme.Colors.accentBlue.opacity(0.5)),
                               style: StrokeStyle(lineWidth: 1.5))
                
                // Wheels
                let wheelRadius: CGFloat = 7
                let wheelY = carCenterY + 3
                let frontWheelX = w * 0.24
                let rearWheelX = w * 0.78
                context.fill(Path(ellipseIn: CGRect(x: frontWheelX - wheelRadius, y: wheelY - wheelRadius, width: wheelRadius * 2, height: wheelRadius * 2)), with: .color(.gray))
                context.fill(Path(ellipseIn: CGRect(x: rearWheelX - wheelRadius, y: wheelY - wheelRadius, width: wheelRadius * 2, height: wheelRadius * 2)), with: .color(.gray))
                
                // Force Arrows
                // 1. Downforce (GREEN arrow pointing DOWN)
                let dfColor: Color = isStalled ? Theme.Colors.dataRed : Theme.Colors.dataGreen
                let dfLen: CGFloat = min(40, CGFloat(downforce / 200.0))
                drawArrow(context: &context, from: CGPoint(x: carCenterX, y: carCenterY - 26),
                          to: CGPoint(x: carCenterX, y: carCenterY - 26 - dfLen),
                          color: dfColor, lineWidth: 2.5, label: "Downforce", flip: true)
                
                // 2. Drag (ORANGE arrow pointing LEFT/backward)
                drawArrow(context: &context, from: CGPoint(x: w * 0.87, y: carCenterY - 10),
                          to: CGPoint(x: w * 0.87 + 28, y: carCenterY - 10),
                          color: Theme.Colors.dataOrange, lineWidth: 2, label: "Drag", flip: false)
                
                // 3. Thrust (BLUE arrow pointing RIGHT/forward)
                drawArrow(context: &context, from: CGPoint(x: w * 0.13, y: carCenterY - 5),
                          to: CGPoint(x: w * 0.13 - 28, y: carCenterY - 5),
                          color: Theme.Colors.accentBlue, lineWidth: 2, label: "Thrust", flip: false)
                
                // 4. Weight (WHITE arrow pointing DOWN from center)
                drawArrow(context: &context, from: CGPoint(x: carCenterX, y: carCenterY + 5),
                          to: CGPoint(x: carCenterX, y: carCenterY + 30),
                          color: .white.opacity(0.5), lineWidth: 1.5, label: "Weight", flip: false)
                
                // Ground line
                var ground = Path()
                ground.move(to: CGPoint(x: 0, y: carCenterY + wheelRadius + 4))
                ground.addLine(to: CGPoint(x: w, y: carCenterY + wheelRadius + 4))
                context.stroke(ground, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 1))
            }
            .frame(height: 120)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.moduleYellow.opacity(0.15), lineWidth: 1))
        )
    }
    
    private func drawArrow(context: inout GraphicsContext, from: CGPoint, to: CGPoint, color: Color, lineWidth: CGFloat, label: String, flip: Bool) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        
        // Arrowhead
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0 else { return }
        let ux = dx / len
        let uy = dy / len
        let headLen: CGFloat = 6
        let headW: CGFloat = 4
        
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - headLen * ux + headW * uy, y: to.y - headLen * uy - headW * ux))
        head.addLine(to: CGPoint(x: to.x - headLen * ux - headW * uy, y: to.y - headLen * uy + headW * ux))
        head.closeSubpath()
        context.fill(head, with: .color(color))
        
        // Label
        let labelOffset: CGFloat = 10
        let labelX = to.x + (flip ? 0 : (dx > 0 ? labelOffset : -labelOffset))
        let labelY = to.y + (flip ? -labelOffset : (dy > 0 ? labelOffset : -labelOffset))
        context.draw(
            Text(label).font(.system(size: 8, weight: .bold)).foregroundColor(color),
            at: CGPoint(x: labelX, y: labelY)
        )
    }
}

// MARK: - Pressure Distribution Diagram
/// Shows high/low pressure zones around the car cross section.
struct PressureZonesDiagram: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pressure Distribution")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.dataGreen)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let midY = h * 0.50
                
                // Car cross-section (front view — simplified oval)
                let carWidth = w * 0.5
                let carHeight: CGFloat = 28
                let carRect = CGRect(x: (w - carWidth) / 2, y: midY - carHeight / 2, width: carWidth, height: carHeight)
                let carShape = Path(roundedRect: carRect, cornerRadius: 6)
                
                context.fill(carShape, with: .color(Theme.Colors.accentBlue.opacity(0.12)))
                context.stroke(carShape, with: .color(Theme.Colors.accentBlue.opacity(0.4)), style: StrokeStyle(lineWidth: 1.5))
                
                context.draw(
                    Text("CAR").font(.system(size: 9, weight: .bold)).foregroundColor(Theme.Colors.accentBlue.opacity(0.5)),
                    at: CGPoint(x: w * 0.5, y: midY)
                )
                
                // HIGH PRESSURE zone (above — red-orange gradient indicators)
                for i in 0..<5 {
                    let x = w * (0.28 + CGFloat(i) * 0.1)
                    let yTop = midY - carHeight / 2 - 6
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: x, y: yTop - 14))
                    arrow.addLine(to: CGPoint(x: x, y: yTop - 4))
                    // Arrowhead
                    arrow.addLine(to: CGPoint(x: x - 3, y: yTop - 8))
                    arrow.move(to: CGPoint(x: x, y: yTop - 4))
                    arrow.addLine(to: CGPoint(x: x + 3, y: yTop - 8))
                    context.stroke(arrow, with: .color(Theme.Colors.dataOrange.opacity(0.6)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
                context.draw(
                    Text("HIGH PRESSURE").font(.system(size: 8, weight: .heavy)).foregroundColor(Theme.Colors.dataOrange),
                    at: CGPoint(x: w * 0.5, y: midY - carHeight / 2 - 22)
                )
                
                // LOW PRESSURE zone (below — green indicators, pushed up)
                for i in 0..<5 {
                    let x = w * (0.28 + CGFloat(i) * 0.1)
                    let yBot = midY + carHeight / 2 + 6
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: x, y: yBot + 14))
                    arrow.addLine(to: CGPoint(x: x, y: yBot + 4))
                    // Arrowhead
                    arrow.addLine(to: CGPoint(x: x - 3, y: yBot + 8))
                    arrow.move(to: CGPoint(x: x, y: yBot + 4))
                    arrow.addLine(to: CGPoint(x: x + 3, y: yBot + 8))
                    context.stroke(arrow, with: .color(Theme.Colors.dataGreen.opacity(0.6)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
                context.draw(
                    Text("LOW PRESSURE").font(.system(size: 8, weight: .heavy)).foregroundColor(Theme.Colors.dataGreen),
                    at: CGPoint(x: w * 0.5, y: midY + carHeight / 2 + 24)
                )
                
                // Net Force arrow (big, downward)
                let arrowX = w * 0.88
                var netArrow = Path()
                netArrow.move(to: CGPoint(x: arrowX, y: midY - 20))
                netArrow.addLine(to: CGPoint(x: arrowX, y: midY + 20))
                netArrow.addLine(to: CGPoint(x: arrowX - 5, y: midY + 14))
                netArrow.move(to: CGPoint(x: arrowX, y: midY + 20))
                netArrow.addLine(to: CGPoint(x: arrowX + 5, y: midY + 14))
                context.stroke(netArrow, with: .color(.white), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                
                context.draw(
                    Text("NET\nFORCE").font(.system(size: 7, weight: .bold)).foregroundColor(.white),
                    at: CGPoint(x: arrowX, y: midY + 32)
                )
                
                // Ground line
                var ground = Path()
                ground.move(to: CGPoint(x: w * 0.15, y: midY + carHeight / 2 + 38))
                ground.addLine(to: CGPoint(x: w * 0.85, y: midY + carHeight / 2 + 38))
                context.stroke(ground, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
            .frame(height: 110)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.dataGreen.opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Real World F1 Fact Card
struct F1FactCard: View {
    let icon: String
    let title: String
    let fact: String
    let accentColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(Theme.Fonts.sectionTitle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.caption())
                    .foregroundColor(accentColor)
                Text(fact)
                    .font(Theme.Fonts.smallCaption())
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(accentColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColor.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
