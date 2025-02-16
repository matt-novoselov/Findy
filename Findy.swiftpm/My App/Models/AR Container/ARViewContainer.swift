import SwiftUI
import RealityKit

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    let coordinator: ARSceneCoordinator
    
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        self.coordinator.coachingOverlayView = view.addCoaching()
        coordinator.initializeARScene(with: view)
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
