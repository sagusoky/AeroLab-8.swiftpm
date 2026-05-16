import SwiftUI

struct LearningPathView: View {
  @Binding var path: NavigationPath

  private let learningModules: [(title: String, icon: String, iconColor: Color, destination: AppScreen)] = [
    ("Ground Effect", "arrow.down.to.line.compact", Theme.Colors.accentBlue, .groundEffect),
    ("Wing Angle", "wind", Theme.Colors.moduleYellow, .wingAngle),
    ("Aerodynamic Balance", "plus", Theme.Colors.moduleGreen, .aeroBalance),
    ("Track Terminology", "pentagon", Theme.Colors.moduleOrange, .trackTerminology),
    ("Perfect Lap Challenge", "flag.checkered", Theme.Colors.accentBlue, .perfectLap),
  ]

  var body: some View {
    ZStack {
      Theme.Colors.background.ignoresSafeArea()

      VStack(alignment: .leading, spacing: 24) {
        // Header
        VStack(alignment: .leading, spacing: 6) {
          Text("Learning Path")
            .font(Theme.Fonts.moduleTitle())
            .foregroundColor(Theme.Colors.textPrimary)
          Text("Select a module below to begin.")
            .font(Theme.Fonts.body())
            .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.horizontal, 32)
        .padding(.top, 16)

        // Module List
        ScrollView {
          VStack(spacing: 14) {
            ForEach(Array(learningModules.enumerated()), id: \.offset) { index, module in
              Button {
                HapticManager.shared.navigate()
                path.append(module.3)
              } label: {
                HStack(spacing: 16) {
                  // Icon
                  RoundedRectangle(cornerRadius: 10)
                    .fill(module.2)
                    .frame(width: 42, height: 42)
                    .overlay(
                      Image(systemName: module.1)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    )

                  Text(module.0)
                    .font(Theme.Fonts.subsectionTitle())
                    .foregroundColor(Theme.Colors.textPrimary)

                  Spacer()

                  Image(systemName: "chevron.right")
                    .font(Theme.Fonts.body())
                    .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                  RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                    .fill(Theme.Colors.cardBackground)
                    .overlay(
                      RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                        .stroke(module.2.opacity(0.25), lineWidth: 1)
                    )
                )
              }
            }
          }
          .padding(.horizontal, 32)
        }

        Spacer()
      }
    }
    .hideNavigationBar()
    .toolbar {
#if os(iOS)
      ToolbarItem(placement: .navigationBarLeading) {

        Button {
          HapticManager.shared.lightTap()
          path.removeLast()
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
            Text("Back")
          }
          .foregroundColor(Theme.Colors.accentBlue)
        }
      }
#endif
    }
  }
}

