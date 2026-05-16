import Combine
import SwiftUI

struct PerfectLapView: View {
  @Binding var path: NavigationPath

  // Live Setup
  @State private var frontWingAngle: Double = 7.0
  @State private var rearWingAngle: Double = 7.0
  @State private var rideHeight: Double = 22.0

  // Simulation state
  @State private var isRacing = false
  @State private var elapsedTime: Double = 0.0
  @State private var lapProgress: CGFloat = 0.0
  @State private var lapResult: LapSimulator.LapResult? = nil

  @State private var currentSectionIndex: Int = 0
  @State private var sectionStars: [Int] = [0, 0, 0, 0, 0, 0, 0]  // 0 to 3 stars per section

  @State private var showResults = false

  // Timer
  let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

  var body: some View {
    DualPanelLabView(
      title: "Perfect Lap Challenge",
      currentPage: 5,
      totalPages: 5,
      glossaryTerms: [],
      canvasContent: {
        // LEFT: Animated Circuit
        ZStack {
          CircuitLayoutView(showBadges: true)
            .padding(32)

          // Glowing Car Dot
          if isRacing || lapResult != nil {
            CarDotIndicator(progress: lapProgress)
              .padding(32)
          }
        }
      },
      theoryContent: {
        // RIGHT: Lap Summary & Live Telemetry
        VStack(alignment: .leading, spacing: 10) {

          // Top Summary Header
          VStack(alignment: .leading, spacing: 4) {
            Text("Lap Summary")
              .font(Theme.Fonts.sectionTitle())
              .foregroundColor(Theme.Colors.textPrimary)

            HStack {
              Text("Current Section:")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.textSecondary)
              Text(currentSectionName)
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.textPrimary)
            }

            GeometryReader { geo in
              ZStack(alignment: .leading) {
                Rectangle()
                  .fill(Color.white.opacity(0.1))
                  .frame(height: 2)
                Rectangle()
                  .fill(
                    LinearGradient(
                      colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                  )
                  .frame(width: geo.size.width * CGFloat(sectionProgress), height: 2)
              }
            }
            .frame(height: 2)
            .padding(.top, 2)
          }

          // Live Telemetry Grid
          VStack(spacing: 8) {
            telemetryRow("Wing Angle", "\(Int(rearWingAngle))°", .white)
            telemetryRow("Speed", "\(Int(liveSpeed)) km/h", Theme.Colors.dataGreen)
            telemetryRow("Grip Level", "\(Int(liveGrip))%", Theme.Colors.dataOrange)
            telemetryRow("Drag Level", "\(Int(liveDrag)) N", Theme.Colors.dataOrange)
          }

          // Optimal Hint
          HStack(spacing: 8) {
            Text("OPTIMAL:")
              .font(Theme.Fonts.smallCaption())
              .foregroundColor(Theme.Colors.textSecondary)
            Text(currentOptimalDisplay)
              .font(Theme.Fonts.dataReadout())
              .foregroundColor(Theme.Colors.moduleYellow)
          }

          Divider().background(Color.white.opacity(0.1))

          // Section Ratings — compact
          VStack(alignment: .leading, spacing: 6) {
            Text("Section Ratings")
              .font(Theme.Fonts.caption())
              .foregroundColor(Theme.Colors.textPrimary)

            ForEach(Array(LapSimulator.defaultTrack.enumerated()), id: \.offset) { idx, section in
              HStack {
                Text(section.name)
                  .font(Theme.Fonts.caption())
                  .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                RatingStars(stars: sectionStars[idx])
              }
            }
          }

          // Quick controls
          AeroSlider(
            label: "Rear Wing Angle",
            value: $rearWingAngle,
            range: 0...15,
            unit: "°",
            minLabel: "0° Low drag",
            maxLabel: "15° Max"
          )
          .disabled(isRacing && lapProgress > 0 && lapProgress < 1.0)

          // Action Button — always visible
          Button {
            if lapProgress >= 1.0 && !isRacing {
              path.append(LapSimulator.LapResultScreenProxy(result: lapResult!))
            } else if !isRacing {
              startLap()
            }
          } label: {
            Text(buttonText)
              .font(Theme.Fonts.buttonLabel())
              .foregroundColor(isRacing ? Theme.Colors.moduleYellow : .white)
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(isRacing ? Theme.Colors.moduleYellow.opacity(0.1) : Theme.Colors.accentBlue)
                  .overlay(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(
                        isRacing ? Theme.Colors.moduleYellow.opacity(0.3) : .clear, lineWidth: 1)
                  )
              )
          }
          .disabled(isRacing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
      },
      onNext: {
        if let res = lapResult, lapProgress >= 1.0 {
          path.append(LapSimulator.LapResultScreenProxy(result: res))
        }
      },
      onBack: {
        path.removeLast()
      }
    )
    .onReceive(timer) { _ in
      if isRacing {
        updateSimulation()
      }
    }
    .navigationDestination(for: LapSimulator.LapResultScreenProxy.self) { proxy in
      LapResultsView(
        result: proxy.result,
        onDone: { path.append(AppScreen.completion) },
        onRetry: { resetLap() }
      )
    }
  }

  // MARK: - Computed Properties
  private var currentSectionName: String {
    guard let res = lapResult, currentSectionIndex < res.sectionTimes.count else { return "Grid" }
    return res.sectionTimes[currentSectionIndex].0.name
  }

  private var sectionProgress: Double {
    guard let res = lapResult, currentSectionIndex < res.sectionTimes.count else { return 0 }
    // Compute how far into the current section we are
    var precedingTime = 0.0
    for i in 0..<currentSectionIndex {
      precedingTime += res.sectionTimes[i].1
    }
    let sectionDuration = res.sectionTimes[currentSectionIndex].1
    let timeInSection = elapsedTime - precedingTime
    return min(max(timeInSection / sectionDuration, 0), 1)
  }

  private var liveSpeed: Double {
    guard let res = lapResult else { return 0 }
    if currentSectionIndex < res.sectionTimes.count {
      // Speed roughly inverse to duration, let's just make it look good for UI
      let section = res.sectionTimes[currentSectionIndex].0
      let time = res.sectionTimes[currentSectionIndex].1
      let mps = section.length / time
      return mps * 3.6  // km/h
    }
    return 0
  }

  private var liveDrag: Double {
    let wing = AeroPhysics.wing(angleDegrees: rearWingAngle, velocity: 60, wingArea: 0.7)
    return wing.drag * (liveSpeed / 100.0) * 10.0  // Visual scale for UI
  }

  private var liveGrip: Double {
    let wing = AeroPhysics.wing(angleDegrees: rearWingAngle, velocity: 60, wingArea: 0.7)
    return 100 + (wing.downforce * 0.5)
  }

  private var currentOptimalDisplay: String {
    guard currentSectionIndex < LapSimulator.defaultTrack.count else { return "--" }
    let type = LapSimulator.defaultTrack[currentSectionIndex].type
    switch type {
    case .straight: return "2° ± 2°"
    case .hairpin: return "14° ± 1°"
    case .sweeper: return "8° ± 2°"
    }
  }

  private var buttonText: String {
    if isRacing { return "Lap in progress..." }
    if lapProgress >= 1.0 { return "View Analysis →" }
    return "Start Lap"
  }

  // MARK: - Handlers
  private func startLap() {
    // Pre-simulate the entire lap to get the times and result
    lapResult = LapSimulator.simulateLap(
      rideHeight: rideHeight,
      frontWingAngle: frontWingAngle,
      rearWingAngle: rearWingAngle
    )

    HapticManager.shared.engineStart()
    EngineSynthesizer.shared.startEngine()

    // Reset state
    elapsedTime = 0
    lapProgress = 0
    currentSectionIndex = 0
    sectionStars = [0, 0, 0, 0, 0, 0, 0]
    isRacing = true
  }

  private func updateSimulation() {
    guard let res = lapResult else { return }

    // Fast-forward simulation to save judges time (3x speed)
    elapsedTime += 0.15  // 3x multiplier of the 0.05s timer tick

    if elapsedTime >= res.totalTime {
      // Finished
      lapProgress = 1.0
      isRacing = false
      EngineSynthesizer.shared.stopEngine()
      return
    }

    // Update audio based on calculated speed
    EngineSynthesizer.shared.updateSpeed(liveSpeed)

    // Update lap progress 0...1
    lapProgress = CGFloat(elapsedTime / res.totalTime)

    // Update current section index
    var accum = 0.0
    for i in 0..<res.sectionTimes.count {
      accum += res.sectionTimes[i].1
      if elapsedTime <= accum {
        if currentSectionIndex != i {
          // We entered a new section, score the previous one
          scoreSection(currentSectionIndex)
          currentSectionIndex = i
        }
        break
      }
    }
  }

  private func scoreSection(_ index: Int) {
    guard let res = lapResult, index < res.sectionTimes.count else { return }
    let section = res.sectionTimes[index].0
    let time = res.sectionTimes[index].1
    let speedMps = section.length / time
    let speedKmh = speedMps * 3.6

    var stars = 1

    // Dynamic scoring — thresholds tuned to the physics engine's output ranges
    // so wing angle changes produce visibly different star ratings
    switch section.type {
    case .straight:
      // Fast straights reward low-drag setups
      if speedKmh >= 310 { stars = 3 } else if speedKmh >= 280 { stars = 2 }
    case .hairpin:
      // Tight hairpins reward high-downforce setups
      if speedKmh >= 95 { stars = 3 } else if speedKmh >= 75 { stars = 2 }
    case .sweeper:
      // Fast sweepers need balanced downforce
      if speedKmh >= 220 { stars = 3 } else if speedKmh >= 185 { stars = 2 }
    }

    // Penalty if stalled (ride height too low)
    let groundResult = AeroPhysics.groundEffect(rideHeight: rideHeight, velocity: 60)
    if groundResult.isStalled {
      stars = max(1, stars - 1)
    }

    sectionStars[index] = stars
  }

  private func resetLap() {
    elapsedTime = 0
    lapProgress = 0
    isRacing = false
    EngineSynthesizer.shared.stopEngine()
    lapResult = nil
    sectionStars = [0, 0, 0, 0, 0, 0, 0]
    currentSectionIndex = 0
  }

  // MARK: - View Helpers
  private func telemetryRow(_ label: String, _ val: String, _ color: Color) -> some View {
    HStack {
      Text(label)
        .font(Theme.Fonts.caption())
        .foregroundColor(Theme.Colors.textSecondary)
      Spacer()
      Text(val)
        .font(Theme.Fonts.formulaFont())
        .foregroundColor(color)
    }
  }
}

// Proxy struct for Navigating
extension LapSimulator {
  struct LapResultScreenProxy: Hashable {
    let id = UUID()
    let result: LapResult
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: LapResultScreenProxy, rhs: LapResultScreenProxy) -> Bool {
      lhs.id == rhs.id
    }
  }
}

// MARK: - Car Dot Indicator
struct CarDotIndicator: View {
  var progress: CGFloat  // 0.0 to 1.0 over the lap

  var body: some View {
    GeometryReader { geo in
      let path = getTrackPath(w: geo.size.width, h: geo.size.height)
      let trimmed = path.trimmedPath(from: 0, to: progress)
      let currentPoint =
        trimmed.currentPoint ?? CGPoint(x: geo.size.width * 0.15, y: geo.size.height * 0.80)

      // Draw a trailing glow line
      path.trimmedPath(from: max(0, progress - 0.05), to: progress)
        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
        .shadow(color: .white, radius: 4)

      // The car dot
      Circle()
        .fill(Color.white)
        .frame(width: 12, height: 12)
        .shadow(color: .white, radius: 8)
        .position(currentPoint)
        .animation(.linear(duration: 0.05), value: progress)
    }
  }

  // Must exactly match the drawing in CircuitLayoutView
  private func getTrackPath(w: CGFloat, h: CGFloat) -> Path {
    var trackPath = Path()

    // Start Finish Straight (Bottom left to right)
    trackPath.move(to: CGPoint(x: w * 0.15, y: h * 0.85))
    trackPath.addLine(to: CGPoint(x: w * 0.70, y: h * 0.85))  // Straight

    // Turn 1: Hairpin (Right side, tight curve going back up-left)
    let hairpinCenter = CGPoint(x: w * 0.70, y: h * 0.70)
    trackPath.addArc(
      center: hairpinCenter, radius: h * 0.15, startAngle: .degrees(90), endAngle: .degrees(-60),
      clockwise: true)

    // Short chute leading to Sweeper
    trackPath.addLine(to: CGPoint(x: w * 0.75, y: h * 0.40))

    // Turn 2: Sweeper (Top right, fast long radius curve)
    trackPath.addCurve(
      to: CGPoint(x: w * 0.40, y: h * 0.15),
      control1: CGPoint(x: w * 0.85, y: h * 0.15),
      control2: CGPoint(x: w * 0.60, y: h * 0.10)
    )

    // Back Straight (Top)
    trackPath.addLine(to: CGPoint(x: w * 0.25, y: h * 0.15))

    // Turn 3: Apex / 90 degree corner (Top left)
    trackPath.addCurve(
      to: CGPoint(x: w * 0.10, y: h * 0.40),
      control1: CGPoint(x: w * 0.10, y: h * 0.15),
      control2: CGPoint(x: w * 0.05, y: h * 0.25)
    )

    // Final transition back to Start/Finish
    trackPath.addCurve(
      to: CGPoint(x: w * 0.15, y: h * 0.85),
      control1: CGPoint(x: w * 0.15, y: h * 0.60),
      control2: CGPoint(x: w * 0.10, y: h * 0.75)
    )

    return trackPath
  }
}

struct RatingStars: View {
  let stars: Int

  var body: some View {
    HStack(spacing: 2) {
      ForEach(0..<3) { i in
        Image(systemName: i < stars ? "star.fill" : "star")
          .foregroundColor(i < stars ? Theme.Colors.moduleYellow : Theme.Colors.textTertiary)
          .font(Theme.Fonts.smallCaption())
      }
    }
  }
}
