import SwiftUI

// This is a custom view modifier to create a perfect corner radius.
struct PerfectCornerRadius: ViewModifier {
    @State private var computedRadius: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            // Use onGeometryChange to get the frame of the view.
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newValue in
                // Calculate the corner radius based on the view's height.
                computedRadius = newValue.size.height / 9 * 2
            }
            // Apply the corner radius.
            .cornerRadius(computedRadius)
    }
}

extension View {
    // This is an extension to make it easy to apply the modifier.
    func perfectCornerRadius() -> some View {
        self.modifier(PerfectCornerRadius())
    }
}
