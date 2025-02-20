import SwiftUI

struct ContentView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        // Use a TabView to switch between different views.
        TabView {
            // Viewfinder tab with the ARControllerView.
            Tab("Viewfinder", systemImage: "camera.viewfinder") {
                ARControllerView()
                    .onAppear{ arCoordinator.isARContainerVisible = true }
                    .onDisappear{ arCoordinator.isARContainerVisible = false }
            }

            // Settings tab with the SettingsView.
            Tab("Settings", systemImage: "gearshape.2.fill") {
                SettingsView()
            }
        }
        // Set the tab view style to show only the tab bar.
        .tabViewStyle(.tabBarOnly)
        
        // MARK: Training cover
        // Overlay for the model training view.
        .overlay{
            Group{
                if appViewModel.isTrainingCoverPresented{
                    ModelTrainingView()
                        .padding(10)
                        .onAppear{ arCoordinator.isARContainerVisible = false; appViewModel.state = .dimmed }
                        .onDisappear{ arCoordinator.isARContainerVisible = true }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            // Apply a spring animation to the training cover's visibility.
            .animation(.spring, value: appViewModel.isTrainingCoverPresented)
            // Ignore safe area insets for the overlay.
            .ignoresSafeArea()
        }
        
    }
}
