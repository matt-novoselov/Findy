import SwiftUI

// Observable class for managing the app's view model.
@Observable
class AppViewModel {
    // Indicates whether debug mode is enabled.
    var isDebugMode: Bool = false
    // Stores the dimensions of the camera image.
    var cameraImageDimensions: CGSize = .init()
    // Represents the current state of the app.
    var state: AppState = .onboarding
    // Indicates whether the ping sound is enabled.
    var isPingSoundEnabled: Bool = true
    // Stores the saved object information.
    var savedObject: SavedObject = .init()
    // Indicates whether the training cover is presented.
    var isTrainingCoverPresented: Bool = false
    // Indicates whether the screen should be blurred during onboarding.
    var shouldBlurScreenOnboarding: Bool = false
}

// Enum representing the different states of the app.
enum AppState: String, CaseIterable {
    case onboarding = "Onboarding"
    case scanning = "Scanning"
    case searching = "Searching"
    case dimmed = "Dimmed"
}
