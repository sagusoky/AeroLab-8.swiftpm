import SwiftUI

enum TrackConcept: String, CaseIterable {
    case hairpin
    case apex
    case sweeper
    case straight
}

struct TrackTerminologyView: View {
    @Binding var path: NavigationPath
    @State private var selectedConcept: TrackConcept? = nil
    
    var body: some View {
        DualPanelLabView(
            title: "Track Concepts",
            currentPage: 4,
            totalPages: 5,
            glossaryTerms: [],
            canvasContent: {
                // LEFT: Circuit layout overview
                ZStack(alignment: .topLeading) {
                    CircuitLayoutView(showBadges: true, activeConcept: selectedConcept)
                        .padding(20)
                        
                    Text("Circuit layout overview")
                        .font(Theme.Fonts.body())
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(24)
                }
            },
            theoryContent: {
                // RIGHT: Theory Content with Grid
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Track Terminology")
                                .font(Theme.Fonts.moduleTitle())
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Tap each concept to explore its aerodynamic demands")
                                .font(Theme.Fonts.body())
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        // 2x2 Grid of cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            
                            // Hairpin
                            TerminologyCard(
                                concept: .hairpin,
                                title: "Hairpin",
                                icon: "arrow.uturn.down",
                                iconColor: Theme.Colors.dataOrange,
                                description: "Very tight slow corner. Maximum downforce needed for braking stability and traction.",
                                badgeLabel: "High downforce",
                                isSelected: selectedConcept == .hairpin,
                                action: { toggleConcept(.hairpin) }
                            )
                            
                            // Apex
                            TerminologyCard(
                                concept: .apex,
                                title: "Apex",
                                icon: "chevron.up",
                                iconColor: .purple,
                                description: "Innermost clipping point of a corner. The critical grip moment where the car is closest to the inside.",
                                badgeLabel: "Grip critical",
                                isSelected: selectedConcept == .apex,
                                action: { toggleConcept(.apex) }
                            )
                            
                            // Sweeper
                            TerminologyCard(
                                concept: .sweeper,
                                title: "Sweeper",
                                icon: "arc",
                                iconColor: Theme.Colors.accentBlue,
                                description: "Fast, long-radius corner. Requires consistent aero grip and stable balance at high speed.",
                                badgeLabel: "Balanced aero",
                                isSelected: selectedConcept == .sweeper,
                                action: { toggleConcept(.sweeper) }
                            )
                            
                            // Straight
                            TerminologyCard(
                                concept: .straight,
                                title: "Straight",
                                icon: "arrow.right",
                                iconColor: Theme.Colors.dataGreen,
                                description: "High-speed section. Minimise drag for maximum top speed. Low wing angle setup preferred.",
                                badgeLabel: "Low drag",
                                isSelected: selectedConcept == .straight,
                                action: { toggleConcept(.straight) }
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Legend
                        HStack(spacing: 16) {
                            LegendItem(color: Theme.Colors.dataOrange, text: "Hairpins → max downforce")
                            LegendItem(color: Theme.Colors.dataGreen, text: "Straights → low drag")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        
                        HStack {
                            LegendItem(color: .purple, text: "Engineers find the compromise")
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer(minLength: 40)
                    }
                }
            },
            onNext: {
                path.append(AppScreen.perfectLap)
            },
            onBack: {
                path.removeLast()
            }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedConcept)
    }
    
    private func toggleConcept(_ concept: TrackConcept) {
        if selectedConcept == concept {
            selectedConcept = nil
        } else {
            selectedConcept = concept
        }
    }
}

struct TerminologyCard: View {
    let concept: TrackConcept
    let title: String
    let icon: String // SF Symbol name
    let iconColor: Color
    let description: String
    let badgeLabel: String
    
    let isSelected: Bool
    let action: () -> Void
    
    @State private var backDegree = 90.0
    @State private var frontDegree = 0.0
    @State private var isFlipped = false
    
    let durationAndDelay: CGFloat = 0.3
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                // Front (Icon and Title)
                CardFront(title: title, icon: icon, iconColor: iconColor, isSelected: isSelected)
                    .rotation3DEffect(Angle(degrees: frontDegree), axis: (x: 0, y: 1, z: 0))
                
                // Back (Description and Badge)
                CardBack(title: title, description: description, badgeLabel: badgeLabel, iconColor: iconColor, isSelected: isSelected)
                    .rotation3DEffect(Angle(degrees: backDegree), axis: (x: 0, y: 1, z: 0))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isSelected) { _, _ in
            flipCard()
        }
    }
    
    private func flipCard() {
        isFlipped = isSelected
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                backDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                frontDegree = 0
            }
        }
    }
}

// Front side of flip card
struct CardFront: View {
    let title: String
    let icon: String
    let iconColor: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 48, height: 48)
                
                if icon == "arc" {
                     // Custom drawing for sweeper arc
                    Path { p in
                        p.move(to: CGPoint(x: 12, y: 32))
                        p.addQuadCurve(to: CGPoint(x: 36, y: 32), control: CGPoint(x: 24, y: 6))
                    }
                    .stroke(iconColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 48, height: 48)
                } else {
                    Image(systemName: icon)
                        .font(Theme.Fonts.sectionTitle())
                        .foregroundColor(iconColor)
                }
            }
            
            Text(title)
                .font(Theme.Fonts.sectionTitle())
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(20)
        .frame(height: 200, alignment: .topLeading)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
        )
    }
}

// Back side of flip card
struct CardBack: View {
    let title: String
    let description: String
    let badgeLabel: String
    let iconColor: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.Fonts.buttonLabel())
                .foregroundColor(.white)
            
            Text(description)
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
            
            // Text Badge
            Text(badgeLabel)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(iconColor)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(iconColor.opacity(0.2))
                .cornerRadius(6)
        }
        .padding(20)
        .frame(height: 200, alignment: .topLeading)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(iconColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(iconColor.opacity(0.5), lineWidth: 2)
                        .shadow(color: iconColor.opacity(0.3), radius: 8)
                )
        )
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}
