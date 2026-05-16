import SwiftUI

// MARK: - App Screen Routing
enum AppScreen: Int, Hashable, CaseIterable {
    case home = 0
    case learningPath = 1
    case groundEffect = 2
    case wingAngle = 3
    case aeroBalance = 4
    case trackTerminology = 5
    case perfectLap = 6
    case completion = 7
    /// The ordered list of module screens (after learningPath, before completion)
    static let moduleFlow: [AppScreen] = [
        .groundEffect, .wingAngle, .aeroBalance, .trackTerminology, .perfectLap
    ]
    
    /// Number of internal slides for each module
    var slideCount: Int {
        switch self {
        case .groundEffect: return 1
        case .wingAngle: return 1
        case .aeroBalance: return 1
        case .trackTerminology: return 1
        case .perfectLap: return 1
        default: return 0
        }
    }
    
    /// Returns the next module in the flow, or .completion if this is the last
    func nextModule() -> AppScreen {
        guard let idx = AppScreen.moduleFlow.firstIndex(of: self) else { return .completion }
        let nextIdx = idx + 1
        return nextIdx < AppScreen.moduleFlow.count ? AppScreen.moduleFlow[nextIdx] : .completion
    }
    
    /// Total slides from this module to the end of the flow
    static func totalSlidesFrom(_ start: AppScreen) -> Int {
        guard let startIdx = moduleFlow.firstIndex(of: start) else { return 1 }
        return moduleFlow[startIdx...].reduce(0) { $0 + $1.slideCount }
    }
    
    /// Current slide position in the overall flow
    static func currentSlidePosition(current: AppScreen, startedFrom: AppScreen) -> Int {
        guard let startIdx = moduleFlow.firstIndex(of: startedFrom),
              let currIdx = moduleFlow.firstIndex(of: current) else { return 1 }
        return moduleFlow[startIdx..<currIdx].reduce(0) { $0 + $1.slideCount } + 1
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen {
                    case .home:
                        HomeView(path: $path)
                    case .learningPath:
                        LearningPathView(path: $path)
                    case .groundEffect:
                        GroundEffectView(path: $path)
                    case .wingAngle:
                        WingAngleView(path: $path)
                    case .aeroBalance:
                        AeroBalanceView(path: $path)
                    case .trackTerminology:
                        TrackTerminologyView(path: $path)
                    case .perfectLap:
                        PerfectLapView(path: $path)
                    case .completion:
                        CompletionView(path: $path)
                    }
                }
        }
    }
}
