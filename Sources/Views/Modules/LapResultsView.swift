import SwiftUI

struct LapResultsView: View {
  let result: LapSimulator.LapResult
  var onDone: () -> Void
  var onRetry: () -> Void

  // Baseline: computed from a ~7° rear wing angle (balanced setup) using the physics engine
  private let baselineLapTime = 72.5   // ~1:12.50 for a balanced setup
  private let baselineTopSpeed = 300.0

  @State private var showConfetti = false

  var body: some View {
    ZStack {
      Theme.Colors.background.ignoresSafeArea()

      VStack(spacing: 0) {

        VStack(spacing: 12) {

          // Top row of 3 big metric cards
          HStack(spacing: 12) {
            bigMetricCard(
              title: "Lap Time", value: formatTime(result.totalTime), color: Theme.Colors.accentBlue
            )
            bigMetricCard(
              title: "Grip Efficiency", value: "\(Int(result.gripEfficiency))%",
              color: Theme.Colors.dataGreen)
            bigMetricCard(
              title: "Top Speed", value: "\(Int(result.topSpeed * 3.6))\nkm/h",
              color: Theme.Colors.moduleYellow)
          }

          // vs Baseline Setup
          VStack(alignment: .leading, spacing: 10) {
            Text("vs Baseline Setup")
              .font(Theme.Fonts.caption())
              .foregroundColor(.white)

            baselineComparisonRow(
              label: "Lap Time",
              oldVal: formatTime(baselineLapTime),
              newVal: formatTime(result.totalTime),
              isBetter: result.totalTime < baselineLapTime,
              color: Theme.Colors.dataGreen
            )

            baselineComparisonRow(
              label: "Top Speed",
              oldVal: "\(Int(baselineTopSpeed)) km/h",
              newVal: "\(Int(result.topSpeed * 3.6)) km/h",
              isBetter: false,
              color: Theme.Colors.moduleYellow
            )
          }
          .padding(14)
          .background(Theme.Colors.surfaceDark)
          .clipShape(RoundedRectangle(cornerRadius: 12))

          // Tradeoff Analysis
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle")
              .foregroundColor(Theme.Colors.dataGreen)
              .font(Theme.Fonts.sectionTitle())

            VStack(alignment: .leading, spacing: 4) {
              Text("Tradeoff Analysis")
                .font(Theme.Fonts.caption())
                .foregroundColor(.white)

              Text(tradeoffText)
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)
            }
          }
          .padding(14)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Theme.Colors.surfaceDark)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Theme.Colors.dataGreen.opacity(0.2), lineWidth: 1)
          )

          // Real-World F1 Context
          VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
              Image(systemName: "info.circle.fill")
                .foregroundColor(Theme.Colors.accentBlue)
              Text("Real-World F1 Context")
                .font(Theme.Fonts.caption())
                .foregroundColor(Theme.Colors.accentBlue)
            }

            Text(realWorldContextText)
              .font(Theme.Fonts.caption())
              .foregroundColor(Theme.Colors.textSecondary)
              .lineSpacing(3)

          }
          .padding(14)
          .background(Theme.Colors.surfaceDark)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Theme.Colors.accentBlue.opacity(0.2), lineWidth: 1)
          )

          // Bottom summary + Continue button
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text("Wing Angle")
                .font(Theme.Fonts.smallCaption())
                .foregroundColor(Theme.Colors.textSecondary)
              Text("\(Int(result.rearWingAngle))°")
                .font(Theme.Fonts.bodySemibold())
                .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
              Text("Ride Height")
                .font(Theme.Fonts.smallCaption())
                .foregroundColor(Theme.Colors.textSecondary)
              Text("\(Int(result.rideHeight)) mm")
                .font(Theme.Fonts.bodySemibold())
                .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
              Text("Stability")
                .font(Theme.Fonts.smallCaption())
                .foregroundColor(Theme.Colors.textSecondary)
              Text("\(Int(result.stabilityScore))")
                .font(Theme.Fonts.bodySemibold())
                .foregroundColor(.white)
            }
          }
          .padding(14)
          .background(Theme.Colors.cardBackground)
          .clipShape(RoundedRectangle(cornerRadius: 12))

          Button {
            HapticManager.shared.buttonTap()
            onDone()
          } label: {
            Text("Continue to Conclusion →")
              .font(Theme.Fonts.buttonLabel())
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(
                    LinearGradient(
                      colors: [Theme.Colors.accentBlue, Theme.Colors.accentBlueDark],
                      startPoint: .leading, endPoint: .trailing
                    ))
              )
          }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 800)
        .padding(.top, 32)

        Spacer()
      }
      .frame(maxHeight: .infinity, alignment: .top)

      CelebrationConfettiView(isActive: $showConfetti)
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        showConfetti = true
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          HapticManager.shared.lightTap()
          onRetry()
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
            Text("Back")
          }
          .foregroundColor(Theme.Colors.accentBlue)
          .font(Theme.Fonts.bodySemibold())
        }
      }
      ToolbarItem(placement: .principal) {
        Text("Performance Analysis")
          .font(Theme.Fonts.sectionTitle())
          .foregroundColor(Theme.Colors.textPrimary)
      }
    }
    .dualPanelToolbarStyle()
  }

  // MARK: - Helpers
  private func bigMetricCard(title: String, value: String, color: Color) -> some View {
    VStack(spacing: 12) {
      Text(title)
        .font(Theme.Fonts.caption())
        .foregroundColor(Theme.Colors.textSecondary)
      Text(value)
        .font(Theme.Fonts.dataHeadline())
        .foregroundColor(color)
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(Theme.Colors.surfaceDark)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private func baselineComparisonRow(
    label: String, oldVal: String, newVal: String, isBetter: Bool, color: Color
  ) -> some View {
    HStack {
      Text(label)
        .font(Theme.Fonts.caption())
        .foregroundColor(Theme.Colors.textSecondary)
      Spacer()
      HStack(spacing: 8) {
        Text(oldVal)
          .font(Theme.Fonts.caption())
          .foregroundColor(Theme.Colors.textTertiary)
          .strikethrough()

        Text(newVal)
          .font(Theme.Fonts.formulaFont())
          .foregroundColor(color)

        Image(systemName: isBetter ? "arrow.down.right" : "arrow.up.right")
          .foregroundColor(color)
          .font(Theme.Fonts.caption())
      }
    }
  }

  private var tradeoffText: String {
    let diff = baselineLapTime - result.totalTime
    let speedDiff = baselineTopSpeed - (result.topSpeed * 3.6)

    if diff > 0 {
      return
        "You gained \(String(format: "%.2f", diff))s in sweepers but lost \(Int(abs(speedDiff))) km/h on straights. This is the classic high-downforce tradeoff — prioritising corner grip over straight-line speed."
    } else {
      return
        "Your setup was slower overall. While you may have gained \(Int(abs(speedDiff))) km/h straight-line speed, the massive time loss in technical corners ruins the lap time. You need more downforce."
    }
  }

  private var realWorldContextText: String {
    let isHighDownforce = result.gripEfficiency > 75
    let isLowDrag = result.speedTradeoff > 75

    if isHighDownforce {
      return
        "At circuits like Monaco or Singapore, F1 teams run maximum wing angles. Drag doesn't matter much on short straights, but every bit of corner grip is crucial to navigate tight city streets without hitting the walls."
    } else if isLowDrag {
      return
        "At Monza (The Temple of Speed), F1 cars use 'skinny' rear wings. They sacrifice cornering grip to achieve top speeds over 350 km/h on the massive straights, where the race is won."
    } else {
      return
        "In 2022, F1 reintroduced ground-effect floors to reduce turbulent wake and allow closer racing. Teams spent race-by-race optimising ride height vs porpoising risk — every millimetre of ride height affected balance."
    }
  }

  private func formatTime(_ seconds: Double) -> String {
    let mins = Int(seconds) / 60
    let secs = seconds.truncatingRemainder(dividingBy: 60)
    return String(format: "%d:%05.2f", mins, secs)
  }
}
