//
//  File.swift
//  Findy
//
//  Created by Matt Novoselov on 06/02/25.
//

import SwiftUICore

extension Shape {
    /// Flips the shape horizontally
    func flippedHorizontally() -> ScaledShape<Self> {
        scale(x: -1, y: 1, anchor: .center)
    }
    
    /// Flips the shape vertically
    func flippedVertically() -> ScaledShape<Self> {
        scale(x: 1, y: -1, anchor: .center)
    }
}
