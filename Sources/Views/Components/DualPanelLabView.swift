import SwiftUI

/// Reusable split-screen layout for all interactive lab modules.
/// Left side: interactive Canvas + controls (no scroll).
/// Right side: theory content (no scroll).
/// Includes top nav bar and bottom progress bar.
struct DualPanelLabView<CanvasContent: View, TheoryContent: View>: View {
  let title: String
  let currentPage: Int
  let totalPages: Int
  let glossaryTerms: [(String, String)]
  @ViewBuilder var canvasContent: () -> CanvasContent
  @ViewBuilder var theoryContent: () -> TheoryContent
  var onNext: () -> Void
  var onBack: (() -> Void)?

  @State private var showGlossary = false

  var body: some View {
    ZStack {
      Theme.Colors.background.ignoresSafeArea()

      VStack(spacing: 0) {
        // Main content — no scroll on either side
        HStack(spacing: 0) {
          // LEFT: Interactive Simulation
          canvasContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Colors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)

          // RIGHT: Theory Panel — NO ScrollView
          VStack(alignment: .leading, spacing: 0) {
            theoryContent()
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.trailing, 16)
          .padding(.vertical, 8)
        }

        // Bottom Progress Bar
        ModuleProgressBar(
          current: currentPage,
          total: totalPages,
          onNext: onNext
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
      }
    }
    .hideNavigationBar()
    .toolbar {
#if os(iOS)
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          onBack?()
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
            Text("Back")
          }
          .foregroundColor(Theme.Colors.accentBlue)
          .font(Theme.Fonts.bodySemibold())
        }
      }
#endif
      ToolbarItem(placement: .principal) {
        Text(title)
          .font(Theme.Fonts.sectionTitle())
          .foregroundColor(Theme.Colors.textPrimary)
      }
#if os(iOS)
      ToolbarItem(placement: .navigationBarTrailing) {
        if !glossaryTerms.isEmpty {
          GlossaryButton(terms: glossaryTerms)
        }
      }
#endif
    }
    .dualPanelToolbarStyle()
  }
}

