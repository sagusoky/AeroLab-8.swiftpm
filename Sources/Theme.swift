import SwiftUI

// MARK: - AeroLab Design System
// Centralized design tokens matching the dark Figma UI

enum Theme {

  // MARK: - Colors
  enum Colors {
    // Backgrounds
    static let background = Color(hex: 0x0A0E1A)
    static let cardBackground = Color(hex: 0x1A1F2E)
    static let cardBorder = Color(hex: 0x2A3040)
    static let surfaceDark = Color(hex: 0x12162A)

    // Accent
    static let accentBlue = Color(hex: 0x3B82F6)
    static let accentBlueDark = Color(hex: 0x2563EB)

    // Module Icon Colors
    static let moduleBlue = Color(hex: 0x3B82F6)
    static let moduleYellow = Color(hex: 0xF59E0B)
    static let moduleGreen = Color(hex: 0x22C55E)
    static let moduleOrange = Color(hex: 0xF97316)

    // Force Colors
    static let forceDownforce = Color(hex: 0xF97316)  // Orange
    static let forceDrag = Color(hex: 0xEF4444)  // Red
    static let forceCoM = Color(hex: 0x6B7280)  // Gray
    static let forceCoP = Color(hex: 0x3B82F6)  // Blue

    // Alert / State Colors
    static let stateStable = Color(hex: 0x22C55E)  // Green
    static let stateOversteer = Color(hex: 0xF97316)  // Orange
    static let stateUndersteer = Color(hex: 0x3B82F6)  // Blue

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x9CA3AF)
    static let textTertiary = Color(hex: 0x6B7280)

    // Formula / Data
    static let dataGreen = Color(hex: 0x22C55E)
    static let dataOrange = Color(hex: 0xF97316)
    static let dataRed = Color(hex: 0xEF4444)
  }

  // MARK: - Typography
  enum Fonts {
    // Structural
    static func heroTitle() -> Font { .system(size: 42, weight: .bold, design: .default) }
    static func moduleTitle() -> Font { .system(size: 28, weight: .bold) }
    static func sectionTitle() -> Font { .system(size: 20, weight: .bold) }
    static func subsectionTitle() -> Font { .system(size: 16, weight: .bold) }
    
    // Body & Text
    static func body() -> Font { .system(size: 15, weight: .regular) }
    static func bodySemibold() -> Font { .system(size: 15, weight: .semibold) }
    static func caption() -> Font { .system(size: 13, weight: .medium) }
    static func smallCaption() -> Font { .system(size: 11, weight: .medium) }
    
    // UI Elements
    static func buttonLabel() -> Font { .system(size: 16, weight: .bold) }
    static func sliderLabel() -> Font { .system(size: 13, weight: .medium) }
    static func badgeLabel() -> Font { .system(size: 13, weight: .bold, design: .monospaced) }
    
    // Data & Numbers (Monospaced for alignment)
    static func dataHeadline() -> Font { .system(size: 24, weight: .bold, design: .monospaced) }
    static func dataReadout() -> Font { .system(size: 16, weight: .bold, design: .monospaced) }
    static func formulaFont() -> Font { .system(size: 14, weight: .medium, design: .monospaced) }
  }

  // MARK: - Layout
  enum Layout {
    static let cardCornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16
    static let cardBorderWidth: CGFloat = 1
    static let canvasWidthRatio: CGFloat = 0.58
    static let theoryWidthRatio: CGFloat = 0.42
  }
}

// MARK: - Color Hex Initializer
extension Color {
  init(hex: UInt, alpha: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255.0,
      green: Double((hex >> 8) & 0xFF) / 255.0,
      blue: Double(hex & 0xFF) / 255.0,
      opacity: alpha
    )
  }
}

// MARK: - Grid Background
struct GridBackground: View {
  var body: some View {
    Canvas { context, size in
      let spacing: CGFloat = 40
      let lineColor = Color.white.opacity(0.03)

      // Vertical lines
      var x: CGFloat = 0
      while x <= size.width {
        var path = Path()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: size.height))
        context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
        x += spacing
      }

      // Horizontal lines
      var y: CGFloat = 0
      while y <= size.height {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: size.width, y: y))
        context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
        y += spacing
      }
    }
    .ignoresSafeArea()
  }
}

// MARK: - Card Modifier
struct CardStyle: ViewModifier {
  var borderColor: Color = Theme.Colors.cardBorder

  func body(content: Content) -> some View {
    content
      .padding(Theme.Layout.cardPadding)
      .background(
        RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
          .fill(Theme.Colors.cardBackground)
          .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
              .stroke(borderColor, lineWidth: Theme.Layout.cardBorderWidth)
          )
      )
  }
}

extension View {
  func cardStyle(borderColor: Color = Theme.Colors.cardBorder) -> some View {
    modifier(CardStyle(borderColor: borderColor))
  }
}

// MARK: - Cross-Platform Navigation Helpers
extension View {
  @ViewBuilder
  func dualPanelToolbarStyle() -> some View {
    #if os(iOS)
    self.toolbarBackground(Theme.Colors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    #else
    self
    #endif
  }

  @ViewBuilder
  func hideNavigationBar() -> some View {
    #if os(iOS)
    self.navigationBarBackButtonHidden(true)
    #else
    self
    #endif
  }

  @ViewBuilder
  func inlineNavigationTitle(_ title: String) -> some View {
    #if os(iOS)
    self.navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    #else
    self.navigationTitle(title)
    #endif
  }
}

