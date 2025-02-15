import UIKit
import Vision

struct AestheticsEvaluationService {
    static func evaluate(
        for images: [UIImage]
    ) async throws -> [(image: UIImage, score: ImageAestheticsScoresObservation?)] {
        try await withThrowingTaskGroup(
            of: (UIImage, ImageAestheticsScoresObservation?).self
        ) { group in
            for image in images {
                group.addTask {
                    let score = try? await calculateAestheticsScore(image: image)
                    return (image, score)
                }
            }
            
            var results = [(UIImage, ImageAestheticsScoresObservation?)]()
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    private static func calculateAestheticsScore(
        image: UIImage
    ) async throws -> ImageAestheticsScoresObservation? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let request = CalculateImageAestheticsScoresRequest()
        return try await request.perform(on: ciImage)
    }
}
