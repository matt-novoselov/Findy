import SwiftUI

// Custom ViewModifier for the blur and overlay effects
struct BlurredOverlayModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .blur(radius: isEnabled ? 20 : 0)
            .overlay(
                GeometryReader { geometry in
                    RadialGradient(
                        gradient: Gradient(colors: [.black.opacity(0.3), .black.opacity(0.9)]),
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
