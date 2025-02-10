import SwiftUI

// Custom ViewModifier for the blur and overlay effects
struct BlurredOverlayModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .brightness(-0.1)
                .blur(radius: 20)
                .overlay(
                    GeometryReader { geometry in
                        RadialGradient(
                            gradient: Gradient(colors: [.clear, .black]),
                            center: .center,
                            startRadius: 0,
                            endRadius: max(geometry.size.width, geometry.size.height) / 2
                        )
                        .opacity(1)
                    }
                )
                .allowsHitTesting(false)
        } else {
            content
        }
    }
}

extension View {
    func blurredOverlay(isEnabled: Bool = true) -> some View {
        modifier(BlurredOverlayModifier(isEnabled: isEnabled))
    }
}
