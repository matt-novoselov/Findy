import SwiftUI

struct ARControllerView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        let arContainer = ARViewContainer(coordinator: arCoordinator)
        
        return arContainer
        
            .onAppear{ arCoordinator.isARContainerVisible = true }
            .onDisappear{ arCoordinator.isARContainerVisible = false }
        
            .blurredOverlay(isEnabled: appViewModel.state == .onboarding)
            .overlay{ DebugView() }
            .ignoresSafeArea()

            .overlay {
                switch appViewModel.state {
                case .onboarding:
                    OnboardingView()
                case .scanning:
                    ObjectScanningView()
                case .searching:
                    ObjectSearchingView()
                }
            }
    }
}
