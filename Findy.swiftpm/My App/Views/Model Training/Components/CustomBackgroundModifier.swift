import SwiftUI

struct SeparatorBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                Color(hex: 0x5E5E5E)
                    .opacity(0.1)
                    .blendMode(.colorDodge)
            )
            .background(
                Color.white
                    .opacity(0.05)
                    .blendMode(.lighten)
            )
            .clipShape(.rect(cornerRadius: 20))
    }
}
extension View {
    func separatorBackground() -> some View {
        self.modifier(SeparatorBackgroundModifier())
    }
}
