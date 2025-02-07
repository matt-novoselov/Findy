//
//  LiquidCirclesView.swift
//  Findy
//
//  Created by Matt Novoselov on 06/02/25.
//

import SwiftUI

struct LiquidCirclesView: View {
    var offset: Double
    
    var body: some View {
        Color.white
            .mask {
                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.8, color: .black))
                    context.addFilter(.blur(radius: 10))
                    
                    context.drawLayer { ctx in
                        if let resolvedOne = context.resolveSymbol(id: 1) {
                            ctx.draw(resolvedOne, at: CGPoint(x: size.width/2, y: size.height/2))
                        }
                        if let resolvedTwo = context.resolveSymbol(id: 2) {
                            ctx.draw(resolvedTwo, at: CGPoint(x: size.width/2, y: size.height/2))
                        }
                    }
                } symbols: {
                    Circle()
                        .frame(height: 50)
                        .offset(y: -160)
                        .aspectRatio(1, contentMode: .fit)
                        .rotationEffect(.init(degrees: -offset))
                        .tag(1)
                    
                    Circle()
                        .frame(height: 50)
                        .offset(y: -160)
                        .aspectRatio(1, contentMode: .fit)
                        .tag(2)
                }
            }
    }
}
