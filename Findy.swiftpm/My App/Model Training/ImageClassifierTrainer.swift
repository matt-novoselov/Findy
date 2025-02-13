#if canImport(CreateML)
import CreateML
import Foundation
import UIKit

final class ImageClassifierTrainer {
    public func train(on customImages: [UIImage]) async throws -> MLImageClassifier {
        let generalObjects = try ImageClassifierTrainer.loadImageURLs(
            extension: "jpg",
            prefix: "GeneralObject"
        )
        
        let customObjects: [URL] = getImageURLs(from: customImages)
        
        let trainingData: [String: [URL]] = [
            "GeneralObject": generalObjects,
            "myObject": customObjects
        ]
        
        let parameters = MLImageClassifier.ModelParameters(
            validation: .split(strategy: .automatic),
            maxIterations: 100,
            augmentation: [.blur, .exposure, .flip, .noise, .rotation]
        )
        
        return try await Task.detached(priority: .userInitiated) {
            try MLImageClassifier(
                trainingData: .filesByLabel(trainingData),
                parameters: parameters
            )
        }.value
    }
}
#endif
