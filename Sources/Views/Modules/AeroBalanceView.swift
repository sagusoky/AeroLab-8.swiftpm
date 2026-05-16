import SwiftUI
import Charts

struct AeroBalanceView: View {
    @Binding var path: NavigationPath
    private let totalModules = 5
    private let currentModule = 3
    
    @State private var frontWingAngle: Double = 6
    @State private var rearWingAngle: Double = 7
    
    // Interactive state
    @State private var selectedTab: Int = 0
    @State private var expandedConcept: String? = nil
    @State private var challengeAnswer: Int? = nil
    @State private var showChallengeResult = false
    @State private var pulseAnimation = false
    @State private var showConfetti = false
    
    private var physics: AeroPhysics.BalanceResult {
        AeroPhysics.balance(frontAngle: frontWingAngle, rearAngle: rearWingAngle)
    }
    
    private let glossary: [(String, String)] = [
        ("Center of Mass (CoM)", "Fixed point where the vehicle weight acts."),
        ("Center of Pressure (CoP)", "Where combined aero forces act. Moves with wing settings."),
        ("Oversteer", "Rear loses grip first — rear slides out."),
        ("Understeer", "Front loses grip first — car pushes wide."),
        ("Neutral Balance", "Equal grip front & rear. Optimal: 44–48% front."),
    ]
    
    var body: some View {
        DualPanelLabView(
            title: "Aerodynamic Balance",
            currentPage: currentModule,
            totalPages: totalModules,
            glossaryTerms: glossary,
            canvasContent: {
                VStack(spacing: 6) {
                    // 3D Car Model
                    CarModelView(
                        mode: .aeroBalance,
                        downforce: physics.totalDownforce,
                        frontWingAngle: frontWingAngle,
                        rearWingAngle: rearWingAngle,
                        copPosition: physics.copPosition,
                        frontDownforce: physics.frontDownforce,
                        rearDownforce: physics.rearDownforce
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    // Live Values
                    LiveValueBar(items: [
                        (label: "FRONT %", value: String(format: "%.1f%%", physics.frontPercentage), color: Theme.Colors.accentBlue),
                        (label: "REAR %", value: String(format: "%.1f%%", 100 - physics.frontPercentage), color: Theme.Colors.dataOrange),
                        (label: "STATUS", value: physics.handlingState.rawValue.uppercased(), color: handlingColor),
                    ])
                    .padding(.horizontal, 12)
                    
                    // Balance Distribution Bar Chart
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Force Distribution")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textTertiary)
                            .padding(.bottom, 4)
                        
                        GeometryReader { geo in
                            let frontFrac = physics.frontPercentage / 100.0
                            HStack(spacing: 2) {
                                // Front bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.Colors.accentBlue)
                                    .frame(width: geo.size.width * frontFrac)
                                    .overlay(
                                        Text("F: \(Int(physics.frontDownforce))N")
                                            .font(Theme.Fonts.smallCaption())
                                            .foregroundColor(.white)
                                            .opacity(frontFrac > 0.15 ? 1 : 0)
                                    )
                                // Rear bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.Colors.dataOrange)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        Text("R: \(Int(physics.rearDownforce))N")
                                            .font(Theme.Fonts.smallCaption())
                                            .foregroundColor(.white)
                                            .opacity((1 - frontFrac) > 0.15 ? 1 : 0)
                                    )
                            }
                        }
                        .frame(height: 32)
                        
                        // Optimal range indicator
                        HStack {
                            Spacer()
                            Text("Optimal: 44–48% front")
                                .font(Theme.Fonts.smallCaption())
                                .foregroundColor(Theme.Colors.stateStable)
                            Spacer()
                        }
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Theme.Colors.cardBackground))
                    .padding(.horizontal, 12)
                    
                    // CoM / CoP legend
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Circle().fill(Theme.Colors.forceCoM).frame(width: 8, height: 8)
                            Text("CoM").font(Theme.Fonts.smallCaption()).foregroundColor(Theme.Colors.textSecondary)
                        }
                        HStack(spacing: 4) {
                            Circle().fill(Theme.Colors.stateStable).frame(width: 8, height: 8)
                            Text("CoP").font(Theme.Fonts.smallCaption()).foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                    
                    // Sliders
                    HStack(spacing: 12) {
                        AeroSlider(label: "Front Wing", value: $frontWingAngle, range: 0...15, unit: "°", minLabel: "0°", maxLabel: "15°")
                        AeroSlider(label: "Rear Wing", value: $rearWingAngle, range: 0...15, unit: "°", minLabel: "0°", maxLabel: "15°")
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
                    ScrollView(showsIndicators: false) {
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
                }
            },
            onNext: {
                path.append(AppScreen.aeroBalance.nextModule())
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
            Text("Tap each concept to explore")
                .font(Theme.Fonts.smallCaption())
                .foregroundColor(Theme.Colors.textTertiary)
                .padding(.top, 8)
                
            // Concept 1: CoM vs CoP
            expandableConceptCard(
                id: "comcop",
                icon: "arrow.up.and.down.and.arrow.left.and.right",
                color: Theme.Colors.accentBlue,
                title: "CoM vs CoP",
                summary: "Points of mass vs aerodynamic forces",
                detail: "Balance depends entirely on the relationship between the fixed Center of Mass (CoM, where gravity acts) and the moving Center of Pressure (CoP, where aero forces act).",
                liveValue: String(format: "%.1f%%", physics.frontPercentage),
                liveLabel: "Front Balance"
            )
            
            // Concept 2: Oversteer
            expandableConceptCard(
                id: "oversteer",
                icon: "arrow.uturn.right",
                color: Theme.Colors.stateOversteer,
                title: "Oversteer",
                summary: "Rear loses grip first — car spins",
                detail: "When the CoP is too far forward (too much front wing), the rear of the car doesn't have enough downforce and grip. The rear slides out during cornering.",
                liveValue: physics.handlingState == .oversteer ? "ACTIVE" : "—",
                liveLabel: "Status"
            )
            
            // Concept 3: Understeer
            expandableConceptCard(
                id: "understeer",
                icon: "arrow.uturn.left",
                color: Theme.Colors.stateUndersteer,
                title: "Understeer",
                summary: "Front loses grip first — car pushes",
                detail: "When the CoP is too far back (too much rear wing), the front doesn't have enough grip to turn. The car 'pushes' straight even when steering.",
                liveValue: physics.handlingState == .understeer ? "ACTIVE" : "—",
                liveLabel: "Status"
            )
            
            // Formula
            FormulaBox(
                formula: "Balance = F/(F+R) × 100%",
                variables: [
                    ("F", "Front downforce (N)"),
                    ("R", "Rear downforce (N)"),
                ],
                accentColor: Theme.Colors.accentBlue
            )
            
            // Interactive hint
            HStack(spacing: 8) {
                Image(systemName: "hand.point.left.fill")
                    .foregroundColor(Theme.Colors.accentBlue)
                    .font(Theme.Fonts.body())
                    .opacity(pulseAnimation ? 1.0 : 0.4)
                
                Text("Try adjusting the wings to see the handling status change!")
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual Breakdown")
                .font(Theme.Fonts.buttonLabel())
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.top, 12)
                
            // Handling Balance Diagram
            HandlingBalanceDiagram(handlingState: physics.handlingState)
                .padding(.bottom, 8)
                
            // Handling states visual Guide

            
            // Handling states visual Guide
            VStack(alignment: .leading, spacing: 12) {
                Text("Understanding Handling Traits")
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textPrimary)
                
                handlingRow(
                    color: Theme.Colors.stateOversteer, 
                    title: "Oversteer", 
                    desc: "Too much front wing. Car wants to spin in corners. Scary for the driver, but sometimes fast if controlled."
                )
                
                handlingRow(
                    color: Theme.Colors.stateUndersteer, 
                    title: "Understeer", 
                    desc: "Too much rear wing. Car won't turn, running wide. Very frustrating, kills lap time as you wait for the front to grip."
                )
                
                handlingRow(
                    color: Theme.Colors.stateStable, 
                    title: "Neutral ✓", 
                    desc: "Perfectly balanced. All 4 tires share the load equally through the corner."
                )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.Colors.cardBorder.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Real-world context
            VStack(alignment: .leading, spacing: 12) {
                Text("Setup Examples")
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textPrimary)
                
                HStack(spacing: 12) {
                    Text("🏎️").font(Theme.Fonts.dataHeadline())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("The 'Optimal' Window")
                            .font(Theme.Fonts.caption())
                            .foregroundColor(Theme.Colors.stateStable)
                        Text("Real F1 cars target 44–48% front aero balance for natural handling. Why not 50%? The rear tires are much wider and have more mechanical grip, so they need slightly more aero load to truly match the front grip.")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.Colors.cardBackground))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.Colors.cardBorder.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer(minLength: 30)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - CHALLENGE TAB
    private var challengeTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(Theme.Colors.moduleYellow)
                    Text("Quick Challenge")
                        .font(Theme.Fonts.buttonLabel())
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                Text("Test your understanding of aero balance!")
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, 12)
            
            // Question card
            VStack(alignment: .leading, spacing: 14) {
                Text("The driver complains the car is 'understeering' (won't turn) in fast corners. Which adjustment will help fix this?")
                    .font(Theme.Fonts.bodySemibold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                challengeOption(index: 0, text: "Increase front wing angle", isCorrect: true)
                challengeOption(index: 1, text: "Decrease front wing angle", isCorrect: false)
                challengeOption(index: 2, text: "Increase rear wing angle", isCorrect: false)
                challengeOption(index: 3, text: "Add more fuel to the car", isCorrect: false)
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
                    Image(systemName: challengeAnswer == 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(Theme.Fonts.dataHeadline())
                        .foregroundColor(challengeAnswer == 0 ? Theme.Colors.dataGreen : Theme.Colors.dataRed)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challengeAnswer == 0 ? "Correct! 🎉" : "Not quite!")
                            .font(Theme.Fonts.bodySemibold())
                            .foregroundColor(challengeAnswer == 0 ? Theme.Colors.dataGreen : Theme.Colors.dataRed)
                        Text("Increasing the front wing angle shifts the aerodynamic balance (CoP) forward, giving the front tires more grip to help the car turn into the corner.")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill((challengeAnswer == 0 ? Theme.Colors.dataGreen : Theme.Colors.dataRed).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((challengeAnswer == 0 ? Theme.Colors.dataGreen : Theme.Colors.dataRed).opacity(0.2), lineWidth: 1)
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
                Text("Set the Front Wing to 15° and Rear Wing to 0°. Notice how the status changes to Oversteer!")
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
    
    private var handlingColor: Color {
        switch physics.handlingState {
        case .oversteer: return Theme.Colors.stateOversteer
        case .understeer: return Theme.Colors.stateUndersteer
        case .neutral: return Theme.Colors.stateStable
        }
    }
    
    private func handlingRow(color: Color, title: String, desc: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Fonts.caption())
                    .foregroundColor(color)
                Text(desc)
                    .font(Theme.Fonts.smallCaption())
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
