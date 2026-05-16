import Foundation

// MARK: - Lap Simulator
// Simulates lap performance based on user's aerodynamic configuration.

public struct LapSimulator {

  // MARK: - Track Section
  public enum SectionType: String {
    case straight = "Straight"
    case hairpin = "Hairpin"
    case sweeper = "Sweeper"
  }

  public struct TrackSection {
    let name: String
    let type: SectionType
    let length: Double  // meters
    let cornerRadius: Double  // meters (0 for straights)
  }

  // MARK: - Lap Result
  public struct LapResult {
    public let totalTime: Double
    public let sectionTimes: [(TrackSection, Double)]
    public let topSpeed: Double
    public let avgCornerSpeed: Double
    public let gripEfficiency: Double  // 0-100
    public let speedTradeoff: Double  // 0-100 (higher = better straight speed)
    public let stabilityScore: Double  // 0-100
    public let feedback: String
    public let frontWingAngle: Double
    public let rearWingAngle: Double
    public let rideHeight: Double
  }

  // MARK: - Reference Track
  public static let defaultTrack: [TrackSection] = [
    TrackSection(name: "Main Straight", type: .straight, length: 300, cornerRadius: 0),
    TrackSection(name: "Turn 1 Hairpin", type: .hairpin, length: 80, cornerRadius: 25),
    TrackSection(name: "Back Straight", type: .straight, length: 200, cornerRadius: 0),
    TrackSection(name: "Turn 2 Sweeper", type: .sweeper, length: 150, cornerRadius: 80),
    TrackSection(name: "Short Straight", type: .straight, length: 120, cornerRadius: 0),
    TrackSection(name: "Turn 3 Hairpin", type: .hairpin, length: 60, cornerRadius: 20),
    TrackSection(name: "Final Sweep", type: .sweeper, length: 130, cornerRadius: 65),
  ]

  // MARK: - Simulation

  public static func simulateLap(
    rideHeight: Double,
    frontWingAngle: Double,
    rearWingAngle: Double
  ) -> LapResult {

    let track = defaultTrack
    var sectionTimes: [(TrackSection, Double)] = []
    var topSpeed: Double = 0
    var cornerSpeeds: [Double] = []

    // Body base drag coefficient (chassis, floor, wheels, etc.)
    let bodyDragCd = 0.35

    // We compute aero forces at section-relevant speeds for accuracy

    for section in track {
      let sectionTime: Double

      switch section.type {
      case .straight:
        // Max speed limited by drag: P = F_drag × v → v = (P / (½ρCdA))^(1/3)
        // Compute wing drag at a high reference speed (~80 m/s ≈ 288 km/h)
        let straightRefV = 80.0
        let fwStraight = AeroPhysics.wing(
          angleDegrees: frontWingAngle, velocity: straightRefV, wingArea: 0.6)
        let rwStraight = AeroPhysics.wing(
          angleDegrees: rearWingAngle, velocity: straightRefV, wingArea: 0.7)
        // Total Cd = sum of wing Cd values + body drag (not averaged)
        let totalDragCd = fwStraight.cd + rwStraight.cd + bodyDragCd
        let dragFactor = 0.5 * AeroPhysics.airDensity * totalDragCd * AeroPhysics.referenceArea
        let vMax = pow(AeroPhysics.maxPower / dragFactor, 1.0 / 3.0)
        let avgSpeed = vMax * 0.85  // Avg ≈ 85% of top speed (accel/braking zones)
        sectionTime = section.length / avgSpeed
        topSpeed = max(topSpeed, vMax)

      case .hairpin, .sweeper:
        // Corner speed limited by grip: v = √((μ × F_normal × r) / m)
        // F_normal = weight + full aerodynamic downforce
        let cornerRefV = section.type == .hairpin ? 25.0 : 55.0
        let groundResult = AeroPhysics.groundEffect(rideHeight: rideHeight, velocity: cornerRefV)
        let balance = AeroPhysics.balance(
          frontAngle: frontWingAngle, rearAngle: rearWingAngle, velocity: cornerRefV)

        let mu = 1.6  // Tire friction coefficient (F1 slick tyres)
        let totalDownforce = groundResult.downforce + balance.totalDownforce
        // Use FULL downforce — this is the real physics (no artificial dampening)
        let normalForce = AeroPhysics.carMass * AeroPhysics.gravity + totalDownforce
        let cornerSpeed = sqrt(mu * normalForce * section.cornerRadius / AeroPhysics.carMass)

        // Stability penalty based on aero balance
        let stabilityFactor = 0.8 + 0.2 * balance.stabilityScore
        let effectiveSpeed = cornerSpeed * stabilityFactor

        // Stall penalty (ride height too low → floor stalls)
        let stallFactor = groundResult.isStalled ? 0.85 : 1.0
        let finalSpeed = effectiveSpeed * stallFactor

        sectionTime = section.length / max(finalSpeed, 10)
        cornerSpeeds.append(finalSpeed)
      }

      sectionTimes.append((section, sectionTime))
    }

    let totalTime = sectionTimes.reduce(0) { $0 + $1.1 }
    let avgCorner =
      cornerSpeeds.isEmpty ? 0 : cornerSpeeds.reduce(0, +) / Double(cornerSpeeds.count)

    // Scores (0-100)
    let gripEfficiency = min(100, (avgCorner / 40.0) * 100.0)
    let speedTradeoff = min(100, (topSpeed / 95.0) * 100.0)
    // Use balance at a mid-range speed for final scores
    let finalBalance = AeroPhysics.balance(
      frontAngle: frontWingAngle, rearAngle: rearWingAngle, velocity: 50)
    let finalGround = AeroPhysics.groundEffect(rideHeight: rideHeight, velocity: 50)
    let stabilityPct = finalBalance.stabilityScore * 100.0

    // Feedback
    let feedback = generateFeedback(
      gripEfficiency: gripEfficiency,
      speedTradeoff: speedTradeoff,
      stability: stabilityPct,
      isStalled: finalGround.isStalled,
      handling: finalBalance.handlingState
    )

    return LapResult(
      totalTime: totalTime,
      sectionTimes: sectionTimes,
      topSpeed: topSpeed,
      avgCornerSpeed: avgCorner,
      gripEfficiency: gripEfficiency,
      speedTradeoff: speedTradeoff,
      stabilityScore: stabilityPct,
      feedback: feedback,
      frontWingAngle: frontWingAngle,
      rearWingAngle: rearWingAngle,
      rideHeight: rideHeight
    )
  }

  private static func generateFeedback(
    gripEfficiency: Double,
    speedTradeoff: Double,
    stability: Double,
    isStalled: Bool,
    handling: AeroPhysics.HandlingState
  ) -> String {
    var lines: [String] = []

    if isStalled {
      lines.append(
        "⚠️ Ride height is too low — the floor has stalled, losing downforce in the corners.")
    }

    switch handling {
    case .oversteer:
      lines.append(
        "🔶 The car oversteers: too much front downforce causes the rear to slide in corners.")
    case .understeer:
      lines.append(
        "🔵 The car understeers: not enough front downforce, so it pushes wide in corners.")
    case .neutral:
      lines.append("✅ Handling is balanced — the car rotates predictably through corners.")
    }

    if gripEfficiency > 80 {
      lines.append("🟢 Excellent corner grip. The downforce setup is strong for technical sections.")
    } else if gripEfficiency > 50 {
      lines.append("🟡 Decent grip, but there's room to improve corner speed with more downforce.")
    } else {
      lines.append("🔴 Low grip. Consider increasing wing angles or lowering ride height.")
    }

    if speedTradeoff > 80 {
      lines.append("🟢 Great straight-line speed. Low drag lets the car accelerate well.")
    } else if speedTradeoff > 50 {
      lines.append("🟡 Moderate top speed. The drag is manageable but costs some time on straights.")
    } else {
      lines.append("🔴 High drag is limiting top speed. Reduce wing angles for faster straights.")
    }

    return lines.joined(separator: "\n\n")
  }
}
