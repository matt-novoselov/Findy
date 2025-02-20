import SwiftUI

@Observable
class AppViewModel {
    var isDebugMode: Bool = false
    var cameraImageDimensions: CGSize = .init()
    var state: AppState = .onboarding
    var isPingSoundEnabled: Bool = true
    var savedObject: SavedObject = .init()
    var isTrainingCoverPresented: Bool = false
    var shouldBlurScreenOnboarding: Bool = false
}

enum AppState: String, CaseIterable {
    case onboarding = "Onboarding"
    case scanning = "Scanning"
    case searching = "Searching"
    case dimmed = "Dimmed"
}
