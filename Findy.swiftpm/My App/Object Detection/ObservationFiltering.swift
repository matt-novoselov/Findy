import Foundation

// MARK: - Observation Filtering
func selectDominantObservation(
    from observations: [ProcessedObservation],
    targetObject: String? = nil
) -> ProcessedObservation? {
    
    let relevantObservations: [ProcessedObservation]
    
    if let target = targetObject {
        relevantObservations = observations.filter { $0.label == target }
        guard !relevantObservations.isEmpty else { return nil }
    } else {
        relevantObservations = observations
    }
    
    guard relevantObservations.count > 1 else {
        return relevantObservations.first
    }
    
    return relevantObservations.max(by: {
        $0.boundingBox.area < $1.boundingBox.area
    })
}
