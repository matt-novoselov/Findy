#if canImport(CreateML)
import CreateML
#endif
import CoreGraphics

struct SavedObject {
    var takenPhotos: [CGImage] = []
    var lastCroppedImage: CGImage?
    var targetDetectionObject: String = "mouse"
    #if canImport(CreateML)
    var imageClassifier: MLImageClassifier?
    #endif
}
