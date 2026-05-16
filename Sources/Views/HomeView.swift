import SwiftUI

struct HomeView: View {
  @Binding var path: NavigationPath
  
  @State private var showTitle = false
  @State private var showTagline1 = false
  @State private var showTagline2 = false
  @State private var showButton = false

  var body: some View {
    ZStack {
      Theme.Colors.background.ignoresSafeArea()
      GridBackground()

      VStack(spacing: 24) {
        Spacer()

        // 3D Car Model with CFD Streamlines
        ZStack {
            CarModelView(
                mode: .wingAngle,
                rideHeight: 25,
                downforce: 0,
                drag: 0,
                isStalled: false,
                frontWingAngle: 10,
                rearWingAngle: 10,
                copPosition: 0,
                frontDownforce: 0,
                rearDownforce: 0
            )
            .scaleEffect(1.3)
            .allowsHitTesting(false)
        }
        .frame(height: 280)

        // Title
        if showTitle {
          Text("AeroLab")
            .font(Theme.Fonts.heroTitle())
            .foregroundColor(Theme.Colors.textPrimary)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            Color.clear.frame(height: 50)
        }

        // Taglines
        VStack(spacing: 6) {
          if showTagline1 {
            Text("Understand how air creates performance.")
              .font(Theme.Fonts.subsectionTitle())
              .foregroundColor(Theme.Colors.textSecondary)
              .transition(.move(edge: .bottom).combined(with: .opacity))
          } else {
              Color.clear.frame(height: 20)
          }
          if showTagline2 {
            Text("Learn the theory. Test it in real time. Apply it on track.")
              .font(Theme.Fonts.body())
              .foregroundColor(Theme.Colors.textTertiary)
              .transition(.move(edge: .bottom).combined(with: .opacity))
          } else {
              Color.clear.frame(height: 18)
          }
        }

        // CTA Button
        if showButton {
          Button {
            HapticManager.shared.buttonTap()
            path.append(AppScreen.learningPath)
          } label: {
            Text("Start Learning")
              .font(Theme.Fonts.buttonLabel())
              .foregroundColor(.white)
              .frame(width: 220, height: 52)
              .background(
                Capsule()
                  .fill(
                    LinearGradient(
                      colors: [Theme.Colors.accentBlue, Theme.Colors.accentBlueDark],
                      startPoint: .leading,
                      endPoint: .trailing
                    )
                  )
                  .shadow(color: Theme.Colors.accentBlue.opacity(0.5), radius: 16, y: 4)
              )
          }
          .padding(.top, 8)
          .transition(.opacity.combined(with: .scale))
        } else {
            Color.clear.frame(height: 60)
        }

        Spacer()
      }
    }
    .hideNavigationBar()
    .onAppear {
        // Sequenced Entrance Animations
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) { showTitle = true }
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) { showTagline1 = true }
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) { showTagline2 = true }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.5)) { showButton = true }
    }
  }
}




