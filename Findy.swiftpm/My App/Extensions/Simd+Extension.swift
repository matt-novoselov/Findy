//
//  Simd+Extension.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 26/01/25.
//

import simd

extension float4x4 {
    var position: SIMD3<Float> {
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
