import Foundation

// MARK: - Observation Filtering
// Selects the dominant observation from a list of processed observations.
func selectDominantObservation(
    from observations: [ProcessedObservation],
    targetObject: String? = nil
) -> ProcessedObservation? {
    // Filter the observations based on the target object, if provided.
    let relevantObservations: [ProcessedObservation]
    
    if let target = targetObject {
        // Filter for observations that match the target object.
        relevantObservations = observations.filter { $0.label == target }
        // Return nil if no relevant observations are found.
        guard !relevantObservations.isEmpty else { return nil }
    } else {
        // If no target object is specified, use all observations.
        relevantObservations = observations
    }
    
    // If there's only one relevant observation, return it.
    guard relevantObservations.count > 1 else {
        return relevantObservations.first
    }
    
    // Return the observation with the largest bounding box area.
    return relevantObservations.max(by: {
        $0.boundingBox.area < $1.boundingBox.area
    })
}
