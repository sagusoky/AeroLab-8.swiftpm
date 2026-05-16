import SwiftUI

/// Dark-themed card for presenting theory sections.
struct TheoryCard<Content: View>: View {
    var borderColor: Color
    @ViewBuilder var content: () -> Content
    
    init(borderColor: Color = Theme.Colors.cardBorder, @ViewBuilder content: @escaping () -> Content) {
        self.borderColor = borderColor
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(borderColor: borderColor)
    }
}
