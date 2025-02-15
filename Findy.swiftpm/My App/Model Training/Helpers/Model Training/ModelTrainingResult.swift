import UIKit
import CreateML

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

enum TrainingError: Error {
    case noBeautifulImage
}
