import UIKit
import Vision

struct AestheticsEvaluationService {
    // Asynchronously evaluates the aesthetics of multiple images.
    static func evaluate(
        for images: [UIImage]
    ) async throws -> [(image: UIImage, score: ImageAestheticsScoresObservation?)] {
        // Use a task group to process images concurrently.
        try await withThrowingTaskGroup(
            of: (UIImage, ImageAestheticsScoresObservation?).self
        ) { group in
            // Add a task for each image to calculate its aesthetics score.
            for image in images {
                group.addTask {
                    let score = try? await calculateAestheticsScore(image: image)
                    return (image, score)
                }
            }
            
            // Collect the results from the task group.
            var results = [(UIImage, ImageAestheticsScoresObservation?)]()
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    // Calculates the aesthetics score for a single image.
    private static func calculateAestheticsScore(
        image: UIImage
    ) async throws -> ImageAestheticsScoresObservation? {
        // Convert the UIImage to a CIImage.
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Create a request to calculate the aesthetics scores.
        let request = CalculateImageAestheticsScoresRequest()
        
        // Perform the request and return the result.
        return try await request.perform(on: ciImage)
    }
}
