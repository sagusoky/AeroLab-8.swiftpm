import SwiftUI

/// 2D Top-down Canvas drawing of F1 car with CoM, CoP, and front/rear downforce arrows.
struct AeroBalanceCanvas: View {
    let frontAngle: Double
    let rearAngle: Double
    let frontDownforce: Double
    let rearDownforce: Double
    let copPosition: Double  // -1 (front) to +1 (rear)
    let handlingState: AeroPhysics.HandlingState
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let carW = w * 0.28
                let carH = h * 0.65
                let carX = (w - carW) / 2
                let carY = (h - carH) / 2
                
                // Car body (top-down)
                var bodyPath = Path()
                // Nose — pointed
                bodyPath.move(to: CGPoint(x: carX + carW * 0.3, y: carY))
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.5, y: carY - carH * 0.05))
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.7, y: carY))
                // Right side
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.80, y: carY + carH * 0.15))
                bodyPath.addCurve(
                    to: CGPoint(x: carX + carW * 0.85, y: carY + carH * 0.40),
                    control1: CGPoint(x: carX + carW * 0.85, y: carY + carH * 0.20),
                    control2: CGPoint(x: carX + carW * 0.90, y: carY + carH * 0.30)
                )
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.80, y: carY + carH * 0.85))
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.70, y: carY + carH * 1.0))
                // Rear
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.30, y: carY + carH * 1.0))
                // Left side
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.20, y: carY + carH * 0.85))
                bodyPath.addCurve(
                    to: CGPoint(x: carX + carW * 0.15, y: carY + carH * 0.40),
                    control1: CGPoint(x: carX + carW * 0.10, y: carY + carH * 0.80),
                    control2: CGPoint(x: carX + carW * 0.10, y: carY + carH * 0.30)
                )
                bodyPath.addLine(to: CGPoint(x: carX + carW * 0.20, y: carY + carH * 0.15))
                bodyPath.closeSubpath()
                
                context.fill(bodyPath, with: .linearGradient(
                    Gradient(colors: [
                        Color(hex: 0x1A2744).opacity(0.8),
                        Color(hex: 0x0E1628).opacity(0.6)
                    ]),
                    startPoint: CGPoint(x: carX, y: carY),
                    endPoint: CGPoint(x: carX, y: carY + carH)
                ))
                context.stroke(bodyPath, with: .color(Theme.Colors.accentBlue.opacity(0.4)), lineWidth: 1.5)
                
                // Front wing elements (two bars)
                let fwY = carY + carH * 0.02
                let fwW = carW * 0.32
                // Left
                var fwLeft = Path()
                fwLeft.addRoundedRect(in: CGRect(x: carX - fwW * 0.5, y: fwY, width: fwW, height: h * 0.015),
                                     cornerSize: CGSize(width: 2, height: 2))
                context.fill(fwLeft, with: .color(Color(hex: 0x2A3040).opacity(0.8)))
                context.stroke(fwLeft, with: .color(Theme.Colors.accentBlue.opacity(0.3)), lineWidth: 1)
                // Right
                var fwRight = Path()
                fwRight.addRoundedRect(in: CGRect(x: carX + carW - fwW * 0.5, y: fwY, width: fwW, height: h * 0.015),
                                      cornerSize: CGSize(width: 2, height: 2))
                context.fill(fwRight, with: .color(Color(hex: 0x2A3040).opacity(0.8)))
                context.stroke(fwRight, with: .color(Theme.Colors.accentBlue.opacity(0.3)), lineWidth: 1)
                
                // Rear wing element (single bar across)
                let rwY = carY + carH * 0.95
                var rwPath = Path()
                rwPath.addRoundedRect(in: CGRect(x: carX + carW * 0.1, y: rwY, width: carW * 0.8, height: h * 0.015),
                                     cornerSize: CGSize(width: 2, height: 2))
                context.fill(rwPath, with: .color(Color(hex: 0x2A3040).opacity(0.8)))
                context.stroke(rwPath, with: .color(Theme.Colors.accentBlue.opacity(0.3)), lineWidth: 1)
                
                // Wheels (rectangles, top-down view)
                let wheelW: CGFloat = carW * 0.12
                let wheelH: CGFloat = carH * 0.12
                let wheels: [CGRect] = [
                    CGRect(x: carX - wheelW * 0.3, y: carY + carH * 0.12, width: wheelW, height: wheelH),
                    CGRect(x: carX + carW - wheelW * 0.7, y: carY + carH * 0.12, width: wheelW, height: wheelH),
                    CGRect(x: carX - wheelW * 0.3, y: carY + carH * 0.78, width: wheelW, height: wheelH),
                    CGRect(x: carX + carW - wheelW * 0.7, y: carY + carH * 0.78, width: wheelW, height: wheelH),
                ]
                for rect in wheels {
                    var wheelPath = Path()
                    wheelPath.addRoundedRect(in: rect, cornerSize: CGSize(width: 3, height: 3))
                    context.fill(wheelPath, with: .color(Color(hex: 0x3A4050)))
                    context.stroke(wheelPath, with: .color(Theme.Colors.textTertiary.opacity(0.3)), lineWidth: 1)
                }
                
                // CoM marker (fixed at 46% from front)
                let comY = carY + carH * 0.46
                let comX = carX + carW * 0.5
                let comCircle = Path(ellipseIn: CGRect(x: comX - 6, y: comY - 6, width: 12, height: 12))
                context.fill(comCircle, with: .color(Theme.Colors.forceCoM))
                context.stroke(comCircle, with: .color(.white.opacity(0.5)), lineWidth: 1)
                context.draw(
                    Text("CoM")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.forceCoM),
                    at: CGPoint(x: comX + 20, y: comY)
                )
                
                // CoP marker (moves with balance)
                let copNorm = copPosition // -1 front, +1 rear
                let copY = carY + carH * (0.46 + copNorm * 0.20)
                let copCircle = Path(ellipseIn: CGRect(x: comX - 6, y: copY - 6, width: 12, height: 12))
                context.fill(copCircle, with: .color(Theme.Colors.stateStable))
                context.stroke(copCircle, with: .color(.white.opacity(0.5)), lineWidth: 1)
                context.draw(
                    Text("CoP")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.stateStable),
                    at: CGPoint(x: comX - 20, y: copY)
                )
            }
            
            // Force arrows overlay
            VStack {
                // FDF (Front Downforce) arrow — pointing up
                VStack(spacing: 1) {
                    ForceArrow(
                        label: "FDF",
                        magnitude: frontDownforce,
                        maxMagnitude: 5000,
                        color: Theme.Colors.stateUndersteer,
                        direction: .up
                    )
                }
                .offset(y: 10)
                
                Spacer()
                
                // RDF (Rear Downforce) arrow — pointing down
                VStack(spacing: 1) {
                    ForceArrow(
                        label: "RDF",
                        magnitude: rearDownforce,
                        maxMagnitude: 5000,
                        color: Theme.Colors.forceDownforce,
                        direction: .down
                    )
                }
                .offset(y: -10)
            }
            .padding(.vertical, 30)
        }
    }
}
