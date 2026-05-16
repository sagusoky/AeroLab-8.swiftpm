import SwiftUI

// MARK: - Bernoulli's Principle Diagram (Wing Angle)
struct BernoulliCrossSectionDiagram: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bernoulli's Principle (Inverted Airfoil)")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.accentBlue)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let cx = w * 0.5
                let cy = h * 0.55
                
                // Wing (F1 rear wing is inverted to an airplane wing)
                var wing = Path()
                wing.move(to: CGPoint(x: cx - 60, y: cy + 10))
                // Bottom curve (more curved on an F1 car for low pressure)
                wing.addQuadCurve(to: CGPoint(x: cx + 60, y: cy - 10), control: CGPoint(x: cx, y: cy + 30))
                // Top curve (flatter)
                wing.addQuadCurve(to: CGPoint(x: cx - 60, y: cy + 10), control: CGPoint(x: cx, y: cy - 15))
                context.fill(wing, with: .color(Theme.Colors.textTertiary.opacity(0.8)))
                
                // Top Airflow (Slower, High Pressure)
                for i in 0..<2 {
                    let yOffset = CGFloat(i) * -15 - 20
                    var path = Path()
                    path.move(to: CGPoint(x: cx - 90, y: cy + yOffset + 15))
                    path.addQuadCurve(to: CGPoint(x: cx + 90, y: cy + yOffset - 10), control: CGPoint(x: cx, y: cy + yOffset))
                    context.stroke(path, with: .color(.cyan.opacity(0.4)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                }
                
                // Bottom Airflow (Faster, Low Pressure)
                for i in 0..<3 {
                    let yOffset = CGFloat(i) * 12 + 15
                    var path = Path()
                    path.move(to: CGPoint(x: cx - 90, y: cy + 15 + CGFloat(i)*5))
                    path.addQuadCurve(to: CGPoint(x: cx + 90, y: cy + yOffset - 10), control: CGPoint(x: cx, y: cy + yOffset + 20))
                    context.stroke(path, with: .color(Theme.Colors.dataGreen.opacity(0.6)), style: StrokeStyle(lineWidth: 2))
                }
                
                // Labels
                context.draw(Text("SLOW AIR = HIGH PRESSURE").font(.system(size: 8, weight: .bold)).foregroundColor(Theme.Colors.dataOrange), at: CGPoint(x: cx, y: cy - 40))
                context.draw(Text("FAST AIR = LOW PRESSURE").font(.system(size: 8, weight: .bold)).foregroundColor(Theme.Colors.dataGreen), at: CGPoint(x: cx, y: cy + 45))
                
                // Downforce arrow
                var arrow = Path()
                arrow.move(to: CGPoint(x: cx, y: cy - 20))
                arrow.addLine(to: CGPoint(x: cx, y: cy + 15))
                arrow.addLine(to: CGPoint(x: cx - 4, y: cy + 11))
                arrow.move(to: CGPoint(x: cx, y: cy + 15))
                arrow.addLine(to: CGPoint(x: cx + 4, y: cy + 11))
                context.stroke(arrow, with: .color(.white), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
            .frame(height: 120)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.accentBlue.opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Downforce Mechanics (Ground Effect)
struct FloorSuctionDiagram: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ground Effect Mechanics")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.moduleYellow)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                
                // Paddock / Track
                var ground = Path()
                ground.move(to: CGPoint(x: 10, y: h * 0.8))
                ground.addLine(to: CGPoint(x: w - 10, y: h * 0.8))
                context.stroke(ground, with: .color(.gray.opacity(0.5)), style: StrokeStyle(lineWidth: 2))
                
                // Car Floor Venturi shape
                var floor = Path()
                floor.move(to: CGPoint(x: w * 0.1, y: h * 0.6))
                floor.addLine(to: CGPoint(x: w * 0.3, y: h * 0.7)) // throat
                floor.addLine(to: CGPoint(x: w * 0.7, y: h * 0.7)) // throat
                floor.addLine(to: CGPoint(x: w * 0.9, y: h * 0.5)) // diffuser
                context.stroke(floor, with: .color(Theme.Colors.textPrimary), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                
                // Airflow arrows (squeezed)
                for i in 0..<3 {
                    let yPos = h * 0.75 + CGFloat(i) * 3
                    var air = Path()
                    air.move(to: CGPoint(x: w * 0.05, y: h * 0.65 + CGFloat(i) * 3))
                    air.addLine(to: CGPoint(x: w * 0.3, y: yPos))
                    air.addLine(to: CGPoint(x: w * 0.7, y: yPos))
                    air.addLine(to: CGPoint(x: w * 0.95, y: h * 0.55 + CGFloat(i) * 3))
                    context.stroke(air, with: .color(.cyan.opacity(0.6)), style: StrokeStyle(lineWidth: 1.5))
                }
                
                // Suction arrows (pulling down)
                for i in 0..<4 {
                    let xPos = w * (0.35 + CGFloat(i) * 0.1)
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: xPos, y: h * 0.7))
                    arrow.addLine(to: CGPoint(x: xPos, y: h * 0.78))
                    arrow.addLine(to: CGPoint(x: xPos - 2, y: h * 0.75))
                    arrow.move(to: CGPoint(x: xPos, y: h * 0.78))
                    arrow.addLine(to: CGPoint(x: xPos + 2, y: h * 0.75))
                    context.stroke(arrow, with: .color(Theme.Colors.dataGreen), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
                
                context.draw(Text("SUCTION").font(.system(size: 9, weight: .heavy)).foregroundColor(Theme.Colors.dataGreen), at: CGPoint(x: w * 0.5, y: h * 0.88))
            }
            .frame(height: 100)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.moduleYellow.opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Center of Pressure Diagram (Aero Balance)
struct CoPDiagram: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Center of Pressure (CoP)")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.dataOrange)
            
            Canvas { context, size in
                let w = size.width
                let h = size.height
                
                // Car chassis shape (top down)
                var car = Path()
                let carW = w * 0.6
                let carH = 20.0
                let cx = w / 2
                let cy = h / 2
                car.addRoundedRect(in: CGRect(x: cx - carW/2, y: cy - carH/2, width: carW, height: carH), cornerSize: CGSize(width: 5, height: 5))
                context.fill(car, with: .color(Theme.Colors.textTertiary.opacity(0.3)))
                
                // Front and Rear wings
                context.fill(Path(roundedRect: CGRect(x: cx - carW/2 - 10, y: cy - 15, width: 15, height: 30), cornerRadius: 2), with: .color(Theme.Colors.accentBlue))
                context.fill(Path(roundedRect: CGRect(x: cx + carW/2 - 5, y: cy - 20, width: 15, height: 40), cornerRadius: 2), with: .color(Theme.Colors.dataOrange))
                
                // CoG and CoP dots
                let cogX = cx - 5
                let copX = cx + 15
                
                context.fill(Path(ellipseIn: CGRect(x: cogX - 4, y: cy - 4, width: 8, height: 8)), with: .color(.white))
                context.draw(Text("CoG").font(.system(size: 8, weight: .bold)).foregroundColor(.white), at: CGPoint(x: cogX, y: cy - 12))
                
                context.fill(Path(ellipseIn: CGRect(x: copX - 5, y: cy - 5, width: 10, height: 10)), with: .color(Theme.Colors.stateStable))
                context.draw(Text("CoP").font(.system(size: 8, weight: .bold)).foregroundColor(Theme.Colors.stateStable), at: CGPoint(x: copX, y: cy + 15))
                
                // Balance scale indicator
                var scale = Path()
                scale.move(to: CGPoint(x: cogX, y: h * 0.8))
                scale.addLine(to: CGPoint(x: copX, y: h * 0.8))
                context.stroke(scale, with: .color(Theme.Colors.stateStable), style: StrokeStyle(lineWidth: 1.5))
            }
            .frame(height: 80)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.Colors.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.dataOrange.opacity(0.15), lineWidth: 1))
        )
    }
}
