import ARKit

// MARK: - Environment Analysis
extension ARSceneCoordinator{
    // Evaluates the lighting conditions of the AR environment.
    func evaluateLightingConditions(frame: ARFrame) {
        // Define a threshold for low light conditions.
        let lowLightThreshold: CGFloat = 500
        
        // Check if light estimation is available.
        guard let lightEstimate = frame.lightEstimate else {
            print("Light estimation unavailable")
            return
        }
        
        // Get the ambient intensity (lumens).
        let ambientLumens = lightEstimate.ambientIntensity
        
        // Show a toast if the ambient light is below the threshold.
        if ambientLumens < lowLightThreshold {
            self.toastManager?.showToast(ToastTemplates.lowLightDetected)
        }
    }
}
