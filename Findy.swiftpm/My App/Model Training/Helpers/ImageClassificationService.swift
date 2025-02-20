import UIKit
import Vision

struct ImageClassificationService {
    // Asynchronously classifies an image using Vision.
    static func classify(image: UIImage) async throws -> [ClassificationObservation]? {
        // Convert the UIImage to a CIImage.
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Create a request to classify the image.
        let request = ClassifyImageRequest()
        
        // Perform the classification and return the results.
        return try await request.perform(on: ciImage)
    }
    
    // Filters the classification observations based on confidence.
    static func filterIdentifiers(
        from observations: [ClassificationObservation]?
    ) -> [String] {
        // Return an empty array if the observations are nil.
        guard let observations = observations else { return [] }
        
        // Filter the observations to include only those with a confidence greater than 0.1.
        return observations.filter { $0.confidence > 0.1 }.map { $0.identifier }
    }
}
