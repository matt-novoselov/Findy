import Foundation

/// Standardized detection result format
struct ProcessedObservation: Equatable {
    let id: UUID = .init()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}
