import UIKit
#if canImport(CreateML)
import CreateML
#endif

// Service to train an image classifier.
struct ImageClassifierTrainerService {
    #if canImport(CreateML)
    // Trains an image classifier with the given images.
    static func train(with images: [UIImage]) async throws -> MLImageClassifier? {
        // Use a Task to perform the training asynchronously.
        return try await Task { () -> MLImageClassifier? in
            let trainer = ImageClassifierTrainer()
            // Train the classifier and return the result.
            return try await trainer.train(on: images)
        }.value
    }
    #else
    // Placeholder for when CreateML is not available.
    static func train(with images: [UIImage]) throws -> String? {
        return nil
    }
    #endif
}
