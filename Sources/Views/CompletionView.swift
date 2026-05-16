import SwiftUI

struct CompletionView: View {
    @Binding var path: NavigationPath
    
    @State private var showConfetti = false
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            GridBackground()
            
            // Confetti particles
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 16) {
                Spacer()
                
                // Trophy / Checkered flag
                    Text("🏁")
                        .font(.system(size: 48))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Text("Well Done!")
                        .font(Theme.Fonts.heroTitle())
                        .foregroundColor(Theme.Colors.textPrimary)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Text("You've completed the AeroLab journey")
                        .font(Theme.Fonts.body())
                        .foregroundColor(Theme.Colors.textSecondary)
                        .opacity(titleOpacity)
                    
                    // Learning summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What You Learned")
                            .font(Theme.Fonts.sectionTitle())
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        summaryRow("water.waves", Theme.Colors.moduleBlue, "Ground Effect", "How the Venturi principle creates downforce through the car's floor shape and ride height.")
                        summaryRow("arrow.up.right", Theme.Colors.moduleYellow, "Wing Angles", "The tradeoff between downforce and drag as angle of attack increases.")
                        summaryRow("plus", Theme.Colors.moduleGreen, "Aero Balance", "How front/rear downforce distribution determines oversteer, understeer, or neutral handling.")
                        summaryRow("pentagon", Theme.Colors.moduleOrange, "Track Sections", "How straights, hairpins, and sweepers demand different aerodynamic setups.")
                        summaryRow("star", Theme.Colors.accentBlue, "Perfect Lap", "Applying all concepts together to optimize a lap time.")
                    }
                    .padding(16)
                    .frame(maxWidth: 600)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                            .fill(Theme.Colors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                                    .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                            )
                    )
                    
                    // Real-world connections
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Real-World F1 Connections")
                            .font(Theme.Fonts.sectionTitle())
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("The 2022 F1 regulations brought ground effect back after 40 years. Teams discovered \"porpoising\" — where the floor stalls at speed, causing the car to bounce violently. This is exactly the stall behavior you explored in Module 1!")
                            .font(Theme.Fonts.body())
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Text("Every race weekend, engineers adjust ride height, wing angles, and aero balance for each circuit — just like you did in the Perfect Lap Challenge. Monaco needs maximum downforce (steep wings), while Monza needs minimum drag (flat wings).")
                            .font(Theme.Fonts.body())
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(16)
                    .frame(maxWidth: 600)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                            .fill(Theme.Colors.accentBlue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                                    .stroke(Theme.Colors.accentBlue.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Return button
                    Button {
                        path = NavigationPath()
                    } label: {
                        Text("Return to Home")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 48)
                            .background(
                                Capsule()
                                    .fill(LinearGradient(
                                        colors: [Theme.Colors.accentBlue, Theme.Colors.accentBlueDark],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                            )
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
        }
        .hideNavigationBar()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
            }
        }
    }
    
    @ViewBuilder
    private func summaryRow(_ icon: String, _ color: Color, _ title: String, _ desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(Theme.Fonts.bodySemibold())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Fonts.bodySemibold())
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(desc)
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Confetti
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var rotation: Double
        var speed: CGFloat
        var sway: CGFloat
    }
    
    let colors: [Color] = [
        Theme.Colors.accentBlue,
        Theme.Colors.moduleYellow,
        Theme.Colors.moduleGreen,
        Theme.Colors.moduleOrange,
        Theme.Colors.dataRed,
        .white.opacity(0.8)
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    let elapsed = CGFloat(time.truncatingRemainder(dividingBy: 8.0))
                    let y = particle.y + elapsed * particle.speed * 30
                    let x = particle.x + sin(elapsed * particle.sway) * 30
                    
                    guard y < size.height + 20 else { continue }
                    
                    let rect = CGRect(x: x - particle.size / 2,
                                     y: y - particle.size / 2,
                                     width: particle.size,
                                     height: particle.size * 0.6)
                    
                    context.rotate(by: .degrees(particle.rotation + Double(elapsed) * 60))
                    context.fill(Path(rect), with: .color(particle.color))
                    context.rotate(by: .degrees(-(particle.rotation + Double(elapsed) * 60)))
                }
            }
        }
        .onAppear {
            particles = (0..<80).map { _ in
                ConfettiParticle(
                    x: CGFloat.random(in: 0...1200),
                    y: CGFloat.random(in: -200...(-20)),
                    size: CGFloat.random(in: 4...10),
                    color: colors.randomElement()!,
                    rotation: Double.random(in: 0...360),
                    speed: CGFloat.random(in: 1...4),
                    sway: CGFloat.random(in: 1...3)
                )
            }
        }
    }
}
