import SwiftUI

/// A full-screen confetti burst animation, Apple-style.
/// Particles shoot upward in an arc, spin, and fade as they fall.
struct CelebrationConfettiView: View {
    @Binding var isActive: Bool
    
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        Color(red: 0.2, green: 0.8, blue: 1.0),  // cyan
        Color(red: 1.0, green: 0.84, blue: 0.0),  // gold
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle, containerSize: geo.size)
                }
            }
            .allowsHitTesting(false)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    HapticManager.shared.celebration()
                    spawnConfetti(in: geo.size)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func spawnConfetti(in size: CGSize) {
        // Generate 80 particles in a burst
        var newParticles: [ConfettiParticle] = []
        for _ in 0..<80 {
            let particle = ConfettiParticle(
                color: colors.randomElement()!,
                startX: CGFloat.random(in: size.width * 0.2...size.width * 0.8),
                startY: size.height * 0.35,
                velocityX: CGFloat.random(in: -180...180),
                velocityY: CGFloat.random(in: -500 ... -200),
                rotationSpeed: Double.random(in: -720...720),
                scale: CGFloat.random(in: 0.4...1.0),
                shape: Int.random(in: 0...2) // 0=rect, 1=circle, 2=strip
            )
            newParticles.append(particle)
        }
        particles = newParticles
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                particles = []
                isActive = false
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let velocityX: CGFloat
    let velocityY: CGFloat
    let rotationSpeed: Double
    let scale: CGFloat
    let shape: Int // 0=rect, 1=circle, 2=strip
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let containerSize: CGSize
    
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Group {
            switch particle.shape {
            case 0:
                Rectangle()
                    .fill(particle.color)
                    .frame(width: 8 * particle.scale, height: 6 * particle.scale)
            case 1:
                Circle()
                    .fill(particle.color)
                    .frame(width: 6 * particle.scale, height: 6 * particle.scale)
            default:
                RoundedRectangle(cornerRadius: 1)
                    .fill(particle.color)
                    .frame(width: 3 * particle.scale, height: 12 * particle.scale)
            }
        }
        .rotationEffect(.degrees(rotation))
        .rotation3DEffect(.degrees(rotation * 0.7), axis: (x: 1, y: 0, z: 0))
        .position(position)
        .opacity(opacity)
        .onAppear {
            position = CGPoint(x: particle.startX, y: particle.startY)
            
            // Phase 1: Burst upward (0.5s)
            withAnimation(.easeOut(duration: 0.5)) {
                position = CGPoint(
                    x: particle.startX + particle.velocityX * 0.3,
                    y: particle.startY + particle.velocityY * 0.3
                )
                rotation = particle.rotationSpeed * 0.3
                opacity = 1.0
            }
            
            // Phase 2: Fall with gravity and drift (0.5s - 2.5s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 2.5)) {
                    position = CGPoint(
                        x: particle.startX + particle.velocityX * 0.8 + CGFloat.random(in: -40...40),
                        y: containerSize.height + 50
                    )
                    rotation = particle.rotationSpeed
                }
            }
            
            // Phase 3: Fade out (2.0s - 3.0s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                }
            }
        }
    }
}
