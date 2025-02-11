import ARKit

// MARK: - Environment Analysis
extension ARSceneCoordinator{
    func evaluateLightingConditions(frame: ARFrame) {
        let lowLightThreshold: CGFloat = 500
        
        guard let lightEstimate = frame.lightEstimate else {
            print("Light estimation unavailable")
            return
        }
        
        let ambientLumens = lightEstimate.ambientIntensity
        if ambientLumens < lowLightThreshold {
            self.toastManager?.showToast(ToastTemplates.lowLightDetected)
        }
    }
}
