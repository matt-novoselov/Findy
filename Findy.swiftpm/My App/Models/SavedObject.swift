#if canImport(CreateML)
import CreateML
#endif
import UIKit

struct SavedObject {
    var takenPhotos: [CapturedPhoto] = []
    var targetDetectionObject: String?
    var visionClassification: [String]?
    var objectCutOutImage: UIImage?
    #if canImport(CreateML)
    var imageClassifier: MLImageClassifier?
    #endif
}

struct CapturedPhoto {
    let photo: CGImage
    let processedObservation: ProcessedObservation
}
