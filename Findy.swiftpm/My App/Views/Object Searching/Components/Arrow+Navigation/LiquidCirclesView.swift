import SwiftUI

// This view creates a liquid-like effect using circles and a mask.
struct LiquidCirclesView: View {
    var degrees: Double
    
    var body: some View {
        Color.white
            .mask {
                Canvas { context, size in
                    // Apply filters to create the liquid effect.
                    context.addFilter(.alphaThreshold(min: 0.8, color: .black))
                    context.addFilter(.blur(radius: 10))
                    
                    context.drawLayer { ctx in
                        // Draw the symbols on the canvas.
                        if let resolvedOne = context.resolveSymbol(id: 1) {
                            ctx.draw(resolvedOne, at: CGPoint(x: size.width/2, y: size.height/2))
                        }
                        if let resolvedTwo = context.resolveSymbol(id: 2) {
                            ctx.draw(resolvedTwo, at: CGPoint(x: size.width/2, y: size.height/2))
                        }
                        if let resolvedThree = context.resolveSymbol(id: 3) {
                            ctx.draw(resolvedThree, at: CGPoint(x: size.width/2, y: size.height/2))
                        }
                    }
                } symbols: {
                    // Define the symbols to be drawn.
                    Circle()
                        .frame(height: 50)
                        .offset(y: -160)
                        .aspectRatio(1, contentMode: .fit)
                        .rotationEffect(.init(degrees: -degrees))
                        .tag(1)
                    
                    Circle()
                        .frame(height: 50)
                        .offset(y: -160)
                        .aspectRatio(1, contentMode: .fit)
                        .tag(2)
                    
                    CircularProgressView(degrees: -degrees)
                        .frame(width: 320, height: 320)
                        .tag(3)
                }
            }
    }
}
