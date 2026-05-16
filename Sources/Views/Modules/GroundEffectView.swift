import SwiftUI
import Charts

struct GroundEffectView: View {
    @Binding var path: NavigationPath
    
    @State private var rideHeight: Double = 25
    @State private var velocity: Double = 50
    
    // Interactive state
    @State private var selectedTab: Int = 0
    @State private var expandedConcept: String? = nil
    @State private var challengeAnswer: Int? = nil
    @State private var showChallengeResult = false
    @State private var pulseAnimation = false
    @State private var showConfetti = false
    
    private var physics: AeroPhysics.GroundEffectResult {
        AeroPhysics.groundEffect(rideHeight: rideHeight, velocity: velocity)
    }
    
    private let glossary: [(String, String)] = [
        ("Downforce", "Vertical force pushing the car into the track, increasing grip."),
        ("Venturi Effect", "Air squeezed through a narrow gap accelerates → pressure drops."),
        ("Ground Effect", "Downforce from the shaped car floor interacting with the ground."),
        ("Ride Height", "Gap between car floor and track. Lower = more downforce, risk of stall."),
        ("Porpoising", "Oscillation from floor stalling at very low ride heights."),
    ]
    
    private let totalModules = 5
    private let currentModule = 1
    
    /// Generate chart data: downforce at different ride heights
    private var chartData: [(rideHeight: Double, downforce: Double)] {
        stride(from: 10.0, through: 50.0, by: 2.0).map { rh in
            let result = AeroPhysics.groundEffect(rideHeight: rh, velocity: velocity)
            return (rideHeight: rh, downforce: result.downforce)
        }
    }
    
    var body: some View {
        DualPanelLabView(
            title: "Ground Effect",
            currentPage: currentModule,
            totalPages: totalModules,
            glossaryTerms: glossary,
            canvasContent: {
                VStack(spacing: 6) {
                    // 3D Car Model
                    CarModelView(
                        mode: .groundEffect,
                        rideHeight: rideHeight,
                        downforce: physics.downforce,
                        isStalled: physics.isStalled
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    // Live Values
                    LiveValueBar(items: [
                        (label: "DOWNFORCE", value: "\(Int(physics.downforce)) N", color: physics.isStalled ? Theme.Colors.dataRed : Theme.Colors.dataGreen),
                        (label: "ΔP", value: "\(Int(physics.pressureDiff)) Pa", color: Theme.Colors.accentBlue),
                        (label: "STATUS", value: physics.isStalled ? "STALLED" : "ACTIVE", color: physics.isStalled ? Theme.Colors.dataRed : Theme.Colors.stateStable),
                    ])
                    .padding(.horizontal, 12)
                    
                    // Mini Chart: Downforce vs Ride Height
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Downforce vs Ride Height")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textTertiary)
                            .padding(.bottom, 4)
                        
                        Chart {
                            ForEach(chartData, id: \.rideHeight) { d in
                                LineMark(
                                    x: .value("Ride Height", d.rideHeight),
                                    y: .value("Downforce", d.downforce)
                                )
                                .foregroundStyle(Theme.Colors.accentBlue)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            }
                            // Current position marker
                            PointMark(
                                x: .value("Ride Height", rideHeight),
                                y: .value("Downforce", physics.downforce)
                            )
                            .foregroundStyle(physics.isStalled ? Theme.Colors.dataRed : Theme.Colors.dataGreen)
                            .symbolSize(60)
                        }
                        .chartXAxis {
                            AxisMarks(values: [10, 20, 30, 40, 50]) { v in
                                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)").font(Theme.Fonts.smallCaption()) }
                                AxisGridLine().foregroundStyle(Theme.Colors.cardBorder)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { v in
                                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)").font(Theme.Fonts.smallCaption()) }
                                AxisGridLine().foregroundStyle(Theme.Colors.cardBorder)
                            }
                        }
                        .frame(height: 90)
                    }
                    .padding(.horizontal, 12)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.Colors.cardBackground)
                    )
                    .padding(.horizontal, 12)
                    
                    // Sliders
                    VStack(spacing: 6) {
                        AeroSlider(label: "Ride Height", value: $rideHeight, range: 10...50, unit: "mm", minLabel: "10", maxLabel: "50")
                        AeroSlider(label: "Velocity", value: $velocity, range: 20...100, unit: "m/s", minLabel: "20", maxLabel: "100")
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            },
            theoryContent: {
                VStack(spacing: 0) {
                    // === INTERACTIVE TAB BAR ===
                    HStack(spacing: 0) {
                        tabButton(title: "Learn", icon: "book.fill", index: 0)
                        tabButton(title: "Explore", icon: "eye.fill", index: 1)
                        tabButton(title: "Challenge", icon: "bolt.fill", index: 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // === TAB CONTENT ===
                    Group {
                        switch selectedTab {
                        case 0: learnTab
                        case 1: exploreTab
                        case 2: challengeTab
                        default: learnTab
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
            },
            onNext: {
                path.append(AppScreen.groundEffect.nextModule())
            },
            onBack: {
                path.removeLast()
            }
        )
        .overlay {
            CelebrationConfettiView(isActive: $showConfetti)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    // MARK: - Tab Button
    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(Theme.Fonts.smallCaption())
                    Text(title)
                        .font(Theme.Fonts.caption())
                }
                .foregroundColor(selectedTab == index ? Theme.Colors.accentBlue : Theme.Colors.textTertiary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                
                // Active indicator
                Rectangle()
                    .fill(selectedTab == index ? Theme.Colors.accentBlue : .clear)
                    .frame(height: 2)
                    .cornerRadius(1)
            }
        }
    }
    
    // MARK: - LEARN TAB
    private var learnTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Animated interactive concept cards
            Text("Tap each concept to explore")
                .font(Theme.Fonts.smallCaption())
                .foregroundColor(Theme.Colors.textTertiary)
                .padding(.top, 8)
            
            // Concept 1: What is Downforce?
            expandableConceptCard(
                id: "downforce",
                icon: "arrow.down.circle.fill",
                color: Theme.Colors.dataGreen,
                title: "What is Downforce?",
                summary: "The force pushing the car into the track",
                detail: "F1 cars generate over 3× their weight in downforce at speed. At 250 km/h, an F1 car could theoretically drive upside-down on the ceiling!",
                liveValue: "\(Int(physics.downforce)) N",
                liveLabel: "Current"
            )
            
            // Concept 2: Venturi Effect
            expandableConceptCard(
                id: "venturi",
                icon: "wind",
                color: Theme.Colors.accentBlue,
                title: "Venturi Effect",
                summary: "Air squeezed through narrow gap → speeds up",
                detail: "As the car floor narrows near the ground, air accelerates underneath. Bernoulli's principle tells us: faster air = lower pressure. This creates a suction that pulls the car down.",
                liveValue: "\(Int(physics.pressureDiff)) Pa",
                liveLabel: "ΔP"
            )
            
            // Concept 3: Ride Height
            expandableConceptCard(
                id: "rideheight",
                icon: "ruler",
                color: Theme.Colors.moduleYellow,
                title: "Ride Height",
                summary: "The gap between floor and track",
                detail: "Lower ride height = narrower gap = faster airflow = more downforce. But go too low and the airflow separates — the floor 'stalls' and downforce drops suddenly. This is called porpoising.",
                liveValue: "\(Int(rideHeight)) mm",
                liveLabel: "Current"
            )
            
            // Concept 4: The Stall
            expandableConceptCard(
                id: "stall",
                icon: "exclamationmark.triangle.fill",
                color: Theme.Colors.dataOrange,
                title: "Flow Separation (Stall)",
                summary: "When downforce suddenly vanishes",
                detail: "Below ~12mm ride height, airflow can't follow the floor shape. It separates, pressure equalizes, and downforce collapses. In real F1, this causes dangerous porpoising bouncing at 300+ km/h.",
                liveValue: physics.isStalled ? "⚠️ STALLED" : "✓ ACTIVE",
                liveLabel: "Status"
            )
            
            // Formula
            FormulaBox(
                formula: "P₁ + ½ρv₁² = P₂ + ½ρv₂²",
                variables: [
                    ("P", "Pressure"),
                    ("ρ", "Air density (1.225 kg/m³)"),
                    ("v", "Air velocity"),
                ],
                accentColor: Theme.Colors.accentBlue
            )
            
            // Interactive hint
            HStack(spacing: 8) {
                Image(systemName: "hand.point.left.fill")
                    .foregroundColor(Theme.Colors.accentBlue)
                    .font(Theme.Fonts.body())
                    .opacity(pulseAnimation ? 1.0 : 0.4)
                
                Text("Try moving the Ride Height slider to see the stall effect!")
                    .font(Theme.Fonts.smallCaption())
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.Colors.accentBlue.opacity(0.06))
            )
            
            Spacer(minLength: 30)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - EXPLORE TAB
    private var exploreTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Visual Breakdown")
                .font(Theme.Fonts.buttonLabel())
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.top, 8)
            
            // Venturi Tunnel — reactive to slider
            VenturiTunnelDiagram(rideHeight: rideHeight)
            
            // Forces Diagram — reactive to downforce
            AeroForcesDiagram(downforce: physics.downforce, isStalled: physics.isStalled)
            
            // Pressure Zones
            PressureZonesDiagram()
            
            // Real-world context
            F1FactCard(
                icon: "🔧",
                title: "2022 Regulation Change",
                fact: "F1 reintroduced ground-effect floors in 2022. Teams battled 'porpoising' — violent bouncing from floor stalling at speed.",
                accentColor: Theme.Colors.accentBlue
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - CHALLENGE TAB
    private var challengeTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Challenge header
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(Theme.Colors.moduleYellow)
                    Text("Quick Challenge")
                        .font(Theme.Fonts.buttonLabel())
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                Text("Test your understanding of ground effect!")
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, 12)
            
            // Question card
            VStack(alignment: .leading, spacing: 14) {
                Text("What happens when you lower the ride height too much?")
                    .font(Theme.Fonts.bodySemibold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                challengeOption(index: 0, text: "Downforce increases forever", isCorrect: false)
                challengeOption(index: 1, text: "Airflow stalls → downforce drops suddenly", isCorrect: true)
                challengeOption(index: 2, text: "The car gets faster on straights", isCorrect: false)
                challengeOption(index: 3, text: "Drag is eliminated completely", isCorrect: false)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.Colors.surfaceDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.Colors.accentBlue.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Result feedback
            if showChallengeResult {
                HStack(spacing: 10) {
                    Image(systemName: challengeAnswer == 1 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(Theme.Fonts.dataHeadline())
                        .foregroundColor(challengeAnswer == 1 ? Theme.Colors.dataGreen : Theme.Colors.dataRed)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challengeAnswer == 1 ? "Correct! 🎉" : "Not quite!")
                            .font(Theme.Fonts.bodySemibold())
                            .foregroundColor(challengeAnswer == 1 ? Theme.Colors.dataGreen : Theme.Colors.dataRed)
                        Text("When the ride height gets too low, the airflow separates from the floor and the ground effect stalls — downforce drops suddenly.")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill((challengeAnswer == 1 ? Theme.Colors.dataGreen : Theme.Colors.dataRed).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((challengeAnswer == 1 ? Theme.Colors.dataGreen : Theme.Colors.dataRed).opacity(0.2), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Try it yourself prompt
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(Theme.Colors.moduleYellow)
                    Text("Try it yourself!")
                        .font(Theme.Fonts.caption())
                        .foregroundColor(Theme.Colors.moduleYellow)
                }
                Text("Use the slider on the left to set Ride Height below 12mm and watch what happens to the downforce value.")
                    .font(Theme.Fonts.smallCaption())
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.Colors.moduleYellow.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.Colors.moduleYellow.opacity(0.15), lineWidth: 1)
                    )
            )
            
            Spacer(minLength: 30)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Expandable Concept Card
    private func expandableConceptCard(
        id: String,
        icon: String,
        color: Color,
        title: String,
        summary: String,
        detail: String,
        liveValue: String,
        liveLabel: String
    ) -> some View {
        let isExpanded = expandedConcept == id
        
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                expandedConcept = isExpanded ? nil : id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Header row (always visible)
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(Theme.Fonts.sectionTitle())
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color.opacity(0.12))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(Theme.Fonts.caption())
                            .foregroundColor(.white)
                        Text(summary)
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Live value badge
                    VStack(spacing: 1) {
                        Text(liveValue)
                            .font(Theme.Fonts.badgeLabel())
                            .foregroundColor(color)
                        Text(liveLabel)
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(12)
                
                // Expanded detail
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(color.opacity(0.15))
                            .frame(height: 1)
                        
                        Text(detail)
                            .font(Theme.Fonts.caption())
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isExpanded ? color.opacity(0.06) : Theme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isExpanded ? color.opacity(0.3) : Theme.Colors.cardBorder.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Challenge Option Button
    private func challengeOption(index: Int, text: String, isCorrect: Bool) -> some View {
        let isSelected = challengeAnswer == index
        let showResult = showChallengeResult
        var borderColor: Color {
            if showResult && isCorrect { return Theme.Colors.dataGreen }
            if showResult && isSelected && !isCorrect { return Theme.Colors.dataRed }
            if isSelected { return Theme.Colors.accentBlue }
            return Theme.Colors.cardBorder.opacity(0.3)
        }
        var bgColor: Color {
            if showResult && isCorrect { return Theme.Colors.dataGreen.opacity(0.1) }
            if showResult && isSelected && !isCorrect { return Theme.Colors.dataRed.opacity(0.1) }
            if isSelected { return Theme.Colors.accentBlue.opacity(0.08) }
            return .clear
        }
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                challengeAnswer = index
                showChallengeResult = true
                if isCorrect {
                    showConfetti = true
                }
            }
        } label: {
            HStack(spacing: 10) {
                // Letter badge
                Text(["A", "B", "C", "D"][index])
                    .font(Theme.Fonts.badgeLabel())
                    .foregroundColor(isSelected ? Theme.Colors.accentBlue : Theme.Colors.textTertiary)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Theme.Colors.accentBlue : Theme.Colors.cardBorder.opacity(0.3), lineWidth: 1)
                    )
                
                Text(text)
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if showResult && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.dataGreen)
                        .font(Theme.Fonts.body())
                }
                if showResult && isSelected && !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.Colors.dataRed)
                        .font(Theme.Fonts.body())
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(bgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(showChallengeResult)
    }
}
