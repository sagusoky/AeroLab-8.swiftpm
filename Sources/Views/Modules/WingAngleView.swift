import SwiftUI
import Charts

struct WingAngleView: View {
    @Binding var path: NavigationPath
    
    @State private var wingAngle: Double = 7
    private let refVelocity: Double = 60
    
    // Interactive state
    @State private var selectedTab: Int = 0
    @State private var expandedConcept: String? = nil
    @State private var challengeAnswer: Int? = nil
    @State private var showChallengeResult = false
    @State private var pulseAnimation = false
    @State private var showConfetti = false
    
    private var physics: AeroPhysics.WingResult {
        AeroPhysics.wing(angleDegrees: wingAngle, velocity: refVelocity)
    }
    
    private let glossary: [(String, String)] = [
        ("Angle of Attack (α)", "Angle between the wing chord and airflow direction."),
        ("Lift Coefficient (Cₗ)", "Dimensionless number for how much lift a wing generates."),
        ("Drag Coefficient (Cd)", "Dimensionless number for aerodynamic resistance."),
        ("L/D Ratio", "Lift-to-drag ratio — higher is more efficient."),
    ]
    
    private let totalModules = 5
    private let currentModule = 2
    
    // Chart data: Lift & Drag vs Angle
    private var chartData: [(angle: Double, lift: Double, drag: Double)] {
        stride(from: 0.0, through: 15.0, by: 1.0).map { a in
            let r = AeroPhysics.wing(angleDegrees: a, velocity: refVelocity)
            return (angle: a, lift: r.downforce, drag: r.drag)
        }
    }
    
    var body: some View {
        DualPanelLabView(
            title: "Wing Angle & Tradeoff",
            currentPage: currentModule,
            totalPages: totalModules,
            glossaryTerms: glossary,
            canvasContent: {
                VStack(spacing: 6) {
                    // 3D Car Model
                    CarModelView(
                        mode: .wingAngle,
                        downforce: physics.downforce,
                        drag: physics.drag,
                        frontWingAngle: wingAngle,
                        rearWingAngle: wingAngle
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    // Live Values
                    LiveValueBar(items: [
                        (label: "DOWNFORCE", value: "\(Int(physics.downforce)) N", color: Theme.Colors.dataGreen),
                        (label: "DRAG", value: "\(Int(physics.drag)) N", color: Theme.Colors.dataOrange),
                        (label: "L/D RATIO", value: physics.drag > 0 ? String(format: "%.1f", physics.downforce / physics.drag) : "—", color: Theme.Colors.accentBlue),
                    ])
                    .padding(.horizontal, 12)
                    
                    // Mini Chart: Lift & Drag vs Angle
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Text("Lift & Drag vs Angle")
                                .font(Theme.Fonts.smallCaption())
                                .foregroundColor(Theme.Colors.textTertiary)
                                .padding(.bottom, 4)
                            Spacer()
                            HStack(spacing: 8) {
                                HStack(spacing: 3) {
                                    Circle().fill(Theme.Colors.dataGreen).frame(width: 5, height: 5)
                                    Text("Lift").font(Theme.Fonts.smallCaption()).foregroundColor(Theme.Colors.textTertiary)
                                }
                                HStack(spacing: 3) {
                                    Circle().fill(Theme.Colors.dataOrange).frame(width: 5, height: 5)
                                    Text("Drag").font(Theme.Fonts.smallCaption()).foregroundColor(Theme.Colors.textTertiary)
                                }
                            }
                        }
                        
                        Chart {
                            ForEach(chartData, id: \.angle) { d in
                                LineMark(
                                    x: .value("Angle", d.angle),
                                    y: .value("Force", d.lift),
                                    series: .value("Type", "Lift")
                                )
                                .foregroundStyle(Theme.Colors.dataGreen)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                LineMark(
                                    x: .value("Angle", d.angle),
                                    y: .value("Force", d.drag),
                                    series: .value("Type", "Drag")
                                )
                                .foregroundStyle(Theme.Colors.dataOrange)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            }
                            // Current position
                            PointMark(x: .value("Angle", wingAngle), y: .value("Force", physics.downforce))
                                .foregroundStyle(Theme.Colors.dataGreen)
                                .symbolSize(50)
                            PointMark(x: .value("Angle", wingAngle), y: .value("Force", physics.drag))
                                .foregroundStyle(Theme.Colors.dataOrange)
                                .symbolSize(50)
                            // Vertical rule at current angle
                            RuleMark(x: .value("Angle", wingAngle))
                                .foregroundStyle(Theme.Colors.textTertiary.opacity(0.4))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        }
                        .chartXAxis {
                            AxisMarks(values: [0, 5, 10, 15]) { v in
                                AxisValueLabel { Text("\(v.as(Int.self) ?? 0)°").font(Theme.Fonts.smallCaption()) }
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
                    .background(RoundedRectangle(cornerRadius: 8).fill(Theme.Colors.cardBackground))
                    .padding(.horizontal, 12)
                    
                    // Slider
                    AeroSlider(label: "Wing Angle", value: $wingAngle, range: 0...15, unit: "°", minLabel: "0° Low", maxLabel: "15° Max")
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
                path.append(AppScreen.wingAngle.nextModule())
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
                
            // Concept 1: Angle of Attack
            expandableConceptCard(
                id: "aoa",
                icon: "arrow.up.left.and.arrow.down.right",
                color: Theme.Colors.accentBlue,
                title: "Angle of Attack (α)",
                summary: "Angle between wing and incoming air",
                detail: "The steeper the angle, the more air is deflected upward, pushing the car downward harder (downforce). But this also blocks the air more, creating drag.",
                liveValue: "\(Int(wingAngle))°",
                liveLabel: "Current"
            )
            
            // Concept 2: Lift & Drag Tradeoff
            expandableConceptCard(
                id: "tradeoff",
                icon: "scale.3d",
                color: Theme.Colors.moduleYellow,
                title: "The L/D Tradeoff",
                summary: "More grip means less speed",
                detail: "Adding wing angle increases downforce for faster cornering, but the extra drag significantly reduces top speed on straights. Teams must find the perfect balance.",
                liveValue: physics.drag > 0 ? String(format: "%.1f", physics.downforce / physics.drag) : "—",
                liveLabel: "L/D Ratio"
            )
            
            // Formulas
            HStack(spacing: 8) {
                FormulaBox(
                    formula: "L = ½ρv²CₗA",
                    variables: [("Cₗ", "lift coeff"), ("A", "wing area")],
                    accentColor: Theme.Colors.dataGreen
                )
                FormulaBox(
                    formula: "D = ½ρv²CdA",
                    variables: [("Cd", "drag coeff"), ("A", "wing area")],
                    accentColor: Theme.Colors.dataOrange
                )
            }
            
            // Interactive hint
            HStack(spacing: 8) {
                Image(systemName: "hand.point.left.fill")
                    .foregroundColor(Theme.Colors.accentBlue)
                    .font(Theme.Fonts.body())
                    .opacity(pulseAnimation ? 1.0 : 0.4)
                
                Text("Try changing the Wing Angle slider to see the effect on Downforce and Drag!")
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
            
            // Lift vs Drag Force Diagram
            LiftDragDiagram(angle: wingAngle, downforce: physics.downforce, drag: physics.drag)
                .padding(.bottom, 8)
                
            // Setup Tradeoff comparison
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("↑ More Angle")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.dataOrange)
                    Text("+ Downforce\n+ Cornering Speed\n− More Drag\n− Lower Top Speed")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 6).fill(Theme.Colors.dataOrange.opacity(0.06)))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("↓ Less Angle")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textTertiary)
                    Text("+ Less Drag\n+ Higher Top Speed\n− Less Downforce\n− Less Grip in Corners")
                        .font(Theme.Fonts.smallCaption())
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            }
            
            // Track specific Context
            VStack(alignment: .leading, spacing: 12) {
                Text("Track Specific Setup Examples")
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textPrimary)
                
                HStack(spacing: 12) {
                    Text("🏎️").font(Theme.Fonts.dataHeadline())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monaco Grand Prix (High Angle)")
                            .font(Theme.Fonts.caption())
                            .foregroundColor(Theme.Colors.dataGreen)
                        Text("Tight corners, short straights. Teams run maximum wing angle for highest downforce possible to grip the tight turns.")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.Colors.cardBackground))
                
                HStack(spacing: 12) {
                    Text("💨").font(Theme.Fonts.dataHeadline())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monza (Low Angle)")
                            .font(Theme.Fonts.caption())
                            .foregroundColor(Theme.Colors.dataOrange)
                        Text("Long straights, few corners. Teams run minimum wing angle ('skinny wings') to minimize drag and maximize top speed.")
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
                Text("Test your understanding of wing angle tradeoff!")
                    .font(Theme.Fonts.caption())
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, 12)
            
            // Question card
            VStack(alignment: .leading, spacing: 14) {
                Text("To maximize top speed on the long straight at Monza, what should a team do to their rear wing?")
                    .font(Theme.Fonts.bodySemibold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                challengeOption(index: 0, text: "Increase the angle for better cornering", isCorrect: false)
                challengeOption(index: 1, text: "Keep it the same, it doesn't affect speed", isCorrect: false)
                challengeOption(index: 2, text: "Decrease the angle to reduce drag", isCorrect: true)
                challengeOption(index: 3, text: "Increase angle and add more ride height", isCorrect: false)
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
                    Image(systemName: challengeAnswer == 2 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(Theme.Fonts.dataHeadline())
                        .foregroundColor(challengeAnswer == 2 ? Theme.Colors.dataGreen : Theme.Colors.dataRed)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challengeAnswer == 2 ? "Correct! 🎉" : "Not quite!")
                            .font(Theme.Fonts.bodySemibold())
                            .foregroundColor(challengeAnswer == 2 ? Theme.Colors.dataGreen : Theme.Colors.dataRed)
                        Text("Decreasing the wing angle (running 'skinny wings') minimizes drag, allowing the car to reach the highest possible top speed on long straights.")
                            .font(Theme.Fonts.smallCaption())
                            .foregroundColor(Theme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill((challengeAnswer == 2 ? Theme.Colors.dataGreen : Theme.Colors.dataRed).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((challengeAnswer == 2 ? Theme.Colors.dataGreen : Theme.Colors.dataRed).opacity(0.2), lineWidth: 1)
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
                Text("Move the Wing Angle slider to 0° and observe how significantly the Drag value drops.")
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
}
