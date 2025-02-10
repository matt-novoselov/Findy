import SwiftUI

@Observable
class AppViewModel {
    var isDebugMode: Bool = true
    var cameraImageDimensions: CGSize = .init()
    var isMetalDetectionSoundEnabled: Bool = true
    var hasObjectBeenDetected: Bool = false
    var isAnyObjectDetected: Bool = false
    var state: AppState = .scanning
    
    
    #warning("")
    var takenPhotos: [CGImage] = []
    var lastCroppedImage: CGImage?
    var targetDetectionObject: String = "bottle"
}

enum AppState: String, CaseIterable {
    case onboarding = "Onboarding"
    case scanning = "Scanning"
    case searching = "Searching"
}
