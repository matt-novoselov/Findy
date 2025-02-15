import UIKit
#if canImport(CreateML)
import CreateML
#endif


struct ImageClassifierTrainerService {
    #if canImport(CreateML)
    static func train(with images: [UIImage]) async throws -> MLImageClassifier? {
        return try await Task { () -> MLImageClassifier? in
            let trainer = ImageClassifierTrainer()
            return try await trainer.train(on: images)
        }.value
    }
    #else
    static func train(with images: [UIImage]) throws -> String? {
        return nil
    }
    #endif
}
