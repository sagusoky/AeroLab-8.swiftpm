import SwiftUI
#if os(iOS)
import UIKit
import AudioToolbox
#endif

/// Centralized haptic feedback and system sound manager.
/// Uses only built-in iOS haptic engines — zero file size overhead.
final class HapticManager {
    static let shared = HapticManager()
    
    #if os(iOS)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    #endif
    
    private init() {
        #if os(iOS)
        // Pre-warm the generators for instant response
        impactLight.prepare()
        impactMedium.prepare()
        selection.prepare()
        notification.prepare()
        #endif
    }
    
    // MARK: - Slider Interactions
    
    /// Soft tick when slider value changes — feels like notches
    func sliderTick() {
        #if os(iOS)
        selection.selectionChanged()
        selection.prepare()
        #endif
    }
    
    // MARK: - Button Taps
    
    /// Standard button press feedback
    func buttonTap() {
        #if os(iOS)
        impactMedium.impactOccurred()
        impactMedium.prepare()
        #endif
    }
    
    /// Light tap for secondary actions (back, dismiss)
    func lightTap() {
        #if os(iOS)
        impactLight.impactOccurred()
        impactLight.prepare()
        #endif
    }
    
    // MARK: - Simulation Events
    
    /// Heavy rumble when lap simulation starts — feels like engine ignition
    func engineStart() {
        #if os(iOS)
        impactHeavy.impactOccurred(intensity: 1.0)
        // Follow up with a second lighter hit for a "rev" feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactMedium.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactLight.impactOccurred(intensity: 0.4)
            self.impactHeavy.prepare()
        }
        #endif
    }
    
    /// Celebration feedback when lap completes or module finishes
    func celebration() {
        #if os(iOS)
        notification.notificationOccurred(.success)
        // Play system success sound
        AudioServicesPlaySystemSound(1025) // subtle chime
        notification.prepare()
        #endif
    }
    
    /// Warning feedback when stall detected
    func stallWarning() {
        #if os(iOS)
        notification.notificationOccurred(.warning)
        notification.prepare()
        #endif
    }
    
    /// Error feedback
    func error() {
        #if os(iOS)
        notification.notificationOccurred(.error)
        notification.prepare()
        #endif
    }
    
    // MARK: - Navigation
    
    /// Subtle tick when navigating between modules
    func navigate() {
        #if os(iOS)
        impactLight.impactOccurred(intensity: 0.5)
        impactLight.prepare()
        #endif
    }
}
