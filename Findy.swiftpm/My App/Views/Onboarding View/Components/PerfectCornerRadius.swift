import SwiftUI

struct PerfectCornerRadius: ViewModifier {
    @State private var computedRadius: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newValue in
                computedRadius = newValue.size.height / 9 * 2
            }
            .cornerRadius(computedRadius)
    }
}

extension View {
    func perfectCornerRadius() -> some View {
        self.modifier(PerfectCornerRadius())
    }
}
