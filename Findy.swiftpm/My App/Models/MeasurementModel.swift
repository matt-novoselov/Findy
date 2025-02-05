
//
//  Measurement.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 26/01/25.
//

import ARKit

// MARK: - Measurement Model
struct Measurement: Equatable {
    let meterDistance: Float
    let rotation: Float  // in degrees

    func formatDistance() -> String {
        if meterDistance >= 1 {
            return String(format: "%.2f m", meterDistance)
        } else {
            return String(format: "%.0f cm", meterDistance * 100)
        }
    }
}
