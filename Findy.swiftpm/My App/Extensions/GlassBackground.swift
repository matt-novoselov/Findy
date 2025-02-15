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
        let linearGradient = LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottom)
        
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(linearGradient, lineWidth: 1.5)
            }
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
