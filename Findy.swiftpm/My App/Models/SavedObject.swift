#if canImport(CreateML)
import CreateML
#endif
import CoreGraphics

struct SavedObject {
    var takenPhotos: [CapturedPhoto] = []
    var lastCroppedImage: CGImage?
    var targetDetectionObject: String = "mouse"
    #if canImport(CreateML)
    var imageClassifier: MLImageClassifier?
    #endif
}

struct CapturedPhoto {
    let photo: CGImage
    let processedObservation: ProcessedObservation
}
