import SwiftUI

#if canImport(CreateML)
import CreateML
#endif

@Observable
class AppViewModel {
    var isDebugMode: Bool = false
    var cameraImageDimensions: CGSize = .init()
    var state: AppState = .scanning
    var isMetalDetectionSoundEnabled: Bool = true
    
    #warning("Move to equitable storage")
    var takenPhotos: [CGImage] = []
    var lastCroppedImage: CGImage?
    var targetDetectionObject: String = "mouse"
    #if canImport(CreateML)
    var imageClassifier: MLImageClassifier?
    #endif
}

enum AppState: String, CaseIterable {
    case onboarding = "Onboarding"
    case scanning = "Scanning"
    case searching = "Searching"
}
