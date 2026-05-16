import Foundation

// MARK: - Aerodynamics Physics Engine
// All calculations use standard aerodynamic formulas with realistic F1 parameters.

public struct AeroPhysics {
    
    // MARK: - Constants
    static let airDensity: Double = 1.225       // ρ (kg/m³) at sea level
    static let referenceArea: Double = 1.5      // A (m²) reference frontal area
    static let carMass: Double = 798.0          // kg (F1 minimum weight)
    static let gravity: Double = 9.81           // m/s²
    static let maxPower: Double = 750_000.0     // Watts (~1000 HP)
    
    // MARK: - Ground Effect Model
    
    /// Calculate ground-effect downforce.
    /// Cₗ increases as ride height decreases (Venturi effect).
    /// Below a critical height, sudden Cₗ drop simulates stall/porpoising.
    public struct GroundEffectResult {
        public let downforce: Double       // Newtons
        public let liftCoefficient: Double // Cₗ
        public let pressureDiff: Double    // ΔP (Pa)
        public let isStalled: Bool
    }
    
    public static func groundEffect(rideHeight: Double, velocity: Double) -> GroundEffectResult {
        // Ride height in mm → convert to meters for physics
        let h = max(rideHeight, 5.0) / 1000.0
        let criticalHeight = 0.012  // 12mm stall threshold
        
        // Cₗ varies inversely with ride height (Venturi narrowing)
        // Peak around 15-20mm, stalls below ~12mm
        var cl: Double
        let isStalled: Bool
        
        if h < criticalHeight {
            // Stall region — sudden loss
            cl = 1.5 * (h / criticalHeight)
            isStalled = true
        } else {
            // Normal Venturi effect: narrower gap → higher Cₗ
            cl = 2.8 * (0.025 / h)
            cl = min(cl, 4.5)  // Cap at reasonable max
            isStalled = false
        }
        
        let v2 = velocity * velocity
        let downforce = 0.5 * airDensity * v2 * cl * referenceArea
        
        // Pressure difference ΔP = ½ρv²(Cₗ_bottom - Cₗ_top)
        let clTop = 0.3  // Slight positive pressure on top
        let pressureDiff = 0.5 * airDensity * v2 * (cl - clTop)
        
        return GroundEffectResult(
            downforce: downforce,
            liftCoefficient: cl,
            pressureDiff: pressureDiff,
            isStalled: isStalled
        )
    }
    
    // MARK: - Wing Model
    
    public struct WingResult {
        public let downforce: Double   // Newtons (lift directed downward)
        public let drag: Double        // Newtons
        public let cl: Double          // Lift coefficient
        public let cd: Double          // Drag coefficient
        public let ldRatio: Double     // Lift-to-drag ratio
    }
    
    /// Calculate wing downforce and drag for a given angle of attack.
    /// Uses simplified thin-airfoil theory: Cₗ ≈ 2π·sin(α)
    public static func wing(angleDegrees: Double, velocity: Double, wingArea: Double = 0.8) -> WingResult {
        let alpha = angleDegrees * .pi / 180.0
        
        // Lift coefficient: Cₗ ≈ 2π·sin(α) (simplified)
        let cl = 2.0 * .pi * sin(alpha)
        
        // Drag coefficient: Cd = Cd₀ + Cₗ²/(π·e·AR)
        let cd0 = 0.02       // Parasitic drag
        let e = 0.85          // Oswald efficiency
        let ar = 4.0          // Aspect ratio
        let cd = cd0 + (cl * cl) / (.pi * e * ar)
        
        let v2 = velocity * velocity
        let dynamicPressure = 0.5 * airDensity * v2
        
        let downforce = dynamicPressure * cl * wingArea
        let drag = dynamicPressure * cd * wingArea
        
        let ldRatio = cd > 0 ? cl / cd : 0
        
        return WingResult(downforce: downforce, drag: drag, cl: cl, cd: cd, ldRatio: ldRatio)
    }
    
    // MARK: - Aerodynamic Balance Model
    
    public struct BalanceResult {
        public let frontDownforce: Double
        public let rearDownforce: Double
        public let totalDownforce: Double
        public let frontPercentage: Double  // 0-100%
        public let copPosition: Double      // -1 (full front) to +1 (full rear), 0 = center
        public let stabilityScore: Double   // 0-100
        public let handlingState: HandlingState
    }
    
    public enum HandlingState: String {
        case oversteer = "Oversteer"
        case understeer = "Understeer"
        case neutral = "Neutral Balance"
    }
    
    /// Calculate aerodynamic balance from front & rear wing angles.
    public static func balance(frontAngle: Double, rearAngle: Double, velocity: Double = 60) -> BalanceResult {
        let frontWing = wing(angleDegrees: frontAngle, velocity: velocity, wingArea: 0.6)
        let rearWing = wing(angleDegrees: rearAngle, velocity: velocity, wingArea: 0.7)
        
        let totalDF = frontWing.downforce + rearWing.downforce
        let frontPct = totalDF > 0 ? (frontWing.downforce / totalDF) * 100.0 : 50.0
        
        // CoP position: weighted average (negative = forward, positive = rearward)
        let copPos = totalDF > 0 ? (rearWing.downforce - frontWing.downforce) / totalDF : 0
        
        // Stability score: 1.0 when perfectly balanced (CoP near CoM)
        // CoM is typically at ~46% from front in F1
        let optimalFrontPct = 46.0
        let deviation = abs(frontPct - optimalFrontPct) / 50.0 // Normalize
        let stability = max(0, 1.0 - deviation)
        
        // Determine handling state
        let state: HandlingState
        if frontPct > 48 {
            state = .oversteer    // More front grip → rear slides
        } else if frontPct < 44 {
            state = .understeer   // Less front grip → pushes wide
        } else {
            state = .neutral
        }
        
        return BalanceResult(
            frontDownforce: frontWing.downforce,
            rearDownforce: rearWing.downforce,
            totalDownforce: totalDF,
            frontPercentage: frontPct,
            copPosition: copPos,
            stabilityScore: stability,
            handlingState: state
        )
    }
}
