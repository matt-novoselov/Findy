//
//  AdjustedObjectDetection.swift
//  Findy
//
//  Created by Matt Novoselov on 27/01/25.
//

import SwiftUI

/// Adjusts observation bounding boxes from camera image coordinates to view coordinates
func adjustObservations(detectionResults: [ProcessedObservation], cameraImageDimensions: CGSize) -> [ProcessedObservation] {
    let geometrySize = UIScreen.main.bounds.size
    let scaleX = geometrySize.width / cameraImageDimensions.width
    let scaleY = geometrySize.height / cameraImageDimensions.height
    
    return detectionResults.map { observation in
        adjustObservation(
            observation,
            scaleX: scaleX,
            scaleY: scaleY
        )
    }
}

/// Adjusts a single observation's bounding box using provided scale factors
func adjustObservation(
    _ observation: ProcessedObservation,
    scaleX: CGFloat,
    scaleY: CGFloat
) -> ProcessedObservation {
    let originalRect = observation.boundingBox
    
    let scaledWidth = originalRect.width * scaleX
    let scaledHeight = originalRect.height * scaleY
    let scaledMidX = originalRect.midX * scaleX
    let scaledMidY = originalRect.midY * scaleY
    
    let scaledRect = CGRect(
        x: scaledMidX - scaledWidth / 2,
        y: scaledMidY - scaledHeight / 2,
        width: scaledWidth,
        height: scaledHeight
    )
    
    return ProcessedObservation(
        label: observation.label,
        confidence: observation.confidence,
        boundingBox: scaledRect
    )
}
