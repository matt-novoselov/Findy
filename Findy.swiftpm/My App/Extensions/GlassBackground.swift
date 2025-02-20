import SwiftUI

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat
    private let gradientColors = [
        Color.white.opacity(0.4),
        Color.clear,
        Color.clear,
        Color.white.opacity(0.1)
    ]
    
    func body(content: Content) -> some View {
        // Create a linear gradient for the stroke effect.
        let linearGradient = LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
        
        content
            .background {
                // Apply the ultra thin material background with a rounded rectangle.
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
            }
            .overlay {
                // Apply the stroke with the linear gradient.
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(linearGradient, lineWidth: 1.5)
            }
    }
}

// Extension to apply the glass background modifier
extension View {
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
