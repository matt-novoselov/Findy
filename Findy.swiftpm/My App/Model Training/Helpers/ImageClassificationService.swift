import UIKit
import Vision

struct ImageClassificationService {
    static func classify(image: UIImage) async throws -> [ClassificationObservation]? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let request = ClassifyImageRequest()
        return try await request.perform(on: ciImage)
    }
    
    static func filterIdentifiers(
        from observations: [ClassificationObservation]?
    ) -> [String] {
        guard let observations = observations else { return [] }
        return observations.filter { $0.confidence > 0.1 }.map { $0.identifier }
    }
}
