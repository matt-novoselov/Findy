import SwiftUI

struct ARControllerView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        // ARViewContainer to display the AR scene.
        ARViewContainer(coordinator: arCoordinator)

            .blurredOverlay(isEnabled: appViewModel.shouldBlurScreenOnboarding)
            
            // Overlay the DebugView.
            .overlay{ DebugView() }
            
            // Ignore safe area insets.
            .ignoresSafeArea()

            // Overlay different views based on the app state.
            .overlay {
                Group{
                    switch appViewModel.state {
                    case .onboarding:
                        OnboardingView()
                    case .scanning:
                        ObjectScanningView()
                    case .dimmed:
                        DimmedView()
                    case .searching:
                        ObjectSearchingView()
                    }
                }

                .transition(.opacity)
                .animation(.spring, value: appViewModel.state)
                
            }
    }
}
