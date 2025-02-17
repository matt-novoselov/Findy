import SwiftUI

struct ARControllerView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        ARViewContainer(coordinator: arCoordinator)
            .blurredOverlay(isEnabled: appViewModel.shouldBlurScreenOnboarding)
            .overlay{ DebugView() }
            .ignoresSafeArea()

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
