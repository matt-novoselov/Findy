import SwiftUI

@Observable
class AppViewModel {
    var isDebugMode: Bool = false
    var cameraImageDimensions: CGSize = .init()
    var state: AppState = .scanning
    var isMetalDetectionSoundEnabled: Bool = true
    var savedObject: SavedObject = .init()
    var isTrainingCoverPresented: Bool = false
}

enum AppState: String, CaseIterable {
    case onboarding = "Onboarding"
    case scanning = "Scanning"
    case searching = "Searching"
}
