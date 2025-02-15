import SwiftUI

// Custom ViewModifier for the blur and overlay effects
struct BlurredOverlayModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .brightness(isEnabled ? -0.1 : 0)
            .blur(radius: isEnabled ? 20 : 0)
            .overlay(
                GeometryReader { geometry in
                    RadialGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: max(geometry.size.width, geometry.size.height) / 2
                    )
                    .opacity(isEnabled ? 1 : 0)
                }
            )
            .allowsHitTesting(false)
            .animation(.spring(duration: 5), value: isEnabled)
    }
}

extension View {
    func blurredOverlay(isEnabled: Bool = true) -> some View {
        modifier(BlurredOverlayModifier(isEnabled: isEnabled))
    }
}
