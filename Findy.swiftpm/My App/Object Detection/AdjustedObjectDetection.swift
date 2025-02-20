import SwiftUI

/// Adjusts observation bounding boxes from camera image coordinates to view coordinates
func adjustObservations(detectionResults: [ProcessedObservation], cameraImageDimensions: CGSize) -> [ProcessedObservation] {
    // Get the size of the screen's geometry.
    let geometrySize = UIScreen.main.bounds.size
    // Calculate the scale factors for the X and Y axes.
    let scaleX = geometrySize.width / cameraImageDimensions.width
    let scaleY = geometrySize.height / cameraImageDimensions.height
    
    // Adjust each observation's bounding box using the calculated scale factors.
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
    // Get the original bounding box.
    let originalRect = observation.boundingBox
    
    // Scale the width and height of the bounding box.
    let scaledWidth = originalRect.width * scaleX
    let scaledHeight = originalRect.height * scaleY
    // Scale the midpoints of the bounding box.
    let scaledMidX = originalRect.midX * scaleX
    let scaledMidY = originalRect.midY * scaleY
    
    // Create a new CGRect with the scaled values.
    let scaledRect = CGRect(
        x: scaledMidX - scaledWidth / 2,
        y: scaledMidY - scaledHeight / 2,
        width: scaledWidth,
        height: scaledHeight
    )
    
    // Return a new ProcessedObservation with the adjusted bounding box.
    return ProcessedObservation(
        label: observation.label,
        confidence: observation.confidence,
        boundingBox: scaledRect
    )
}
