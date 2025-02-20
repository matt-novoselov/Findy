import SwiftUI
import RealityKit

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    let coordinator: ARSceneCoordinator
    
    // Creates the ARView.
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        // Add coaching overlay to the ARView.
        self.coordinator.coachingOverlayView = view.addCoaching()
        // Initialize the AR scene with the view.
        coordinator.initializeARScene(with: view)
        return view
    }
    
    // Updates the ARView
    func updateUIView(_ uiView: ARView, context: Context) {}
}
