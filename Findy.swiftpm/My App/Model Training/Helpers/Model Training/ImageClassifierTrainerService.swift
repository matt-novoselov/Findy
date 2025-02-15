import UIKit
#if canImport(CreateML)
import CreateML
#endif

struct ImageClassifierTrainerService {
    static func train(with images: [UIImage]) async throws -> MLImageClassifier? {
        return try await Task { () -> MLImageClassifier? in
            #if canImport(CreateML)
            let trainer = ImageClassifierTrainer()
            return try await trainer.train(on: images)
            #else
            return nil
            #endif
        }.value
    }
}
