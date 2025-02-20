import UIKit
#if canImport(CreateML)
import CreateML
#endif

// Structure to hold the results of the model training.
struct ModelTrainingResult {
    var objectCutOutImage: UIImage
    var averageLabel: String?
    var visionClassifications: [String]
    #if canImport(CreateML)
    var trainedModel: MLImageClassifier?
    #else
    var trainedModel: Any?
    #endif
}

// Enum to represent errors that can occur during training.
enum TrainingError: Error {
    case noBeautifulImage
}
