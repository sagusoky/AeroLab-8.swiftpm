import SwiftUI

/// Glossary "?" button that shows term definitions in a popover.
struct GlossaryButton: View {
    let terms: [(String, String)]
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 20))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                ZStack {
                    Theme.Colors.background.ignoresSafeArea()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(terms.enumerated()), id: \.offset) { _, term in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(term.0)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Theme.Colors.accentBlue)
                                    Text(term.1)
                                        .font(Theme.Fonts.body())
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                                .cardStyle()
                            }
                        }
                        .padding()
                    }
                }
                .inlineNavigationTitle("Glossary")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showSheet = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
