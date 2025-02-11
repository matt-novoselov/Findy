#if canImport(CreateML)
import CreateML
#endif
import CoreGraphics

struct SavedObject {
    var takenPhotos: [CapturedPhoto] = []
    var targetDetectionObject: String?
    var visionClassification: [String]?
    #if canImport(CreateML)
    var imageClassifier: MLImageClassifier?
    #endif
}

struct CapturedPhoto {
    let photo: CGImage
    let processedObservation: ProcessedObservation
}
