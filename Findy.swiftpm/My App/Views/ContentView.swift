import SwiftUI

struct ContentView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        TabView {
            Tab("Viewfinder", systemImage: "camera.viewfinder") {
                ARControllerView()
                    .onAppear{ arCoordinator.isARContainerVisible = true }
                    .onDisappear{ arCoordinator.isARContainerVisible = false }
            }

            Tab("Settings", systemImage: "gearshape.2.fill") {
                SettingsView()
            }
        }
        .tabViewStyle(.tabBarOnly)
        
        // MARK: Training cover
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
            .animation(.spring, value: appViewModel.isTrainingCoverPresented)
            .ignoresSafeArea()
        }
        
    }
}
