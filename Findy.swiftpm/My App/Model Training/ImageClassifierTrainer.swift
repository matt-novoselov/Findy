#if canImport(CreateML)
import CreateML
import Foundation
import UIKit

final class ImageClassifierTrainer {
    // Function to train an image classifier with custom images.
    public func train(on customImages: [UIImage]) async throws -> MLImageClassifier {
        // Load general object image URLs.
        let generalObjects = try ImageClassifierTrainer.loadImageURLs(
            extension: "jpg",
            prefix: "GeneralObject"
        )
        
        // Get image URLs from the provided custom UIImages.
        let customObjects: [URL] = getImageURLs(from: customImages)
        
        // Prepare the training data as a dictionary of labels and image URLs.
        let trainingData: [String: [URL]] = [
            "GeneralObject": generalObjects,
            "myObject": customObjects
        ]
        
        // Define the model parameters for training.
        let parameters = MLImageClassifier.ModelParameters(
            validation: .split(strategy: .automatic),
            maxIterations: 100,
            augmentation: [.blur, .exposure, .flip, .noise, .rotation]
        )
        
        // Perform the training in a detached task to avoid blocking the main thread.
        return try await Task.detached(priority: .userInitiated) {
            // Create and train the MLImageClassifier.
            try MLImageClassifier(
                trainingData: .filesByLabel(trainingData),
                parameters: parameters
            )
        }.value
    }
}
#endif
