import AVFoundation

class MetalDetector {
    
    // Configuration
    private let minDistance: Double = 0.0
    private let maxDistance: Double = 10.0
    private let minTimeInterval: TimeInterval = 0.05
    private let maxTimeInterval: TimeInterval = 2.0
    private let checkTimeInterval: TimeInterval = 0.05
    
    private var timer: Timer?
    private var lastBeepTime: Date?
    weak var arCoordinator: ARSceneCoordinator?
    
    init() {
        startDetection()
    }
    
    deinit {
        stopDetection()
    }
    
    private func startDetection() {
        timer = Timer.scheduledTimer(withTimeInterval: checkTimeInterval, repeats: true) { [weak self] _ in
            self?.checkForBeep()
        }
    }
    
    private func stopDetection() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForBeep() {
        guard let currentDistance = arCoordinator?.currentMeasurement?.meterDistance else { return }
        guard arCoordinator?.appViewModel?.isMetalDetectionSoundEnabled == true else { return }
        
        let now = Date()
        let elapsed = lastBeepTime.map { now.timeIntervalSince($0) } ?? maxTimeInterval
        let requiredInterval = calculateCurrentInterval(for: Double(currentDistance))
        
        if elapsed >= requiredInterval {
            playBeep()
            lastBeepTime = now
        }
    }
    
    private func calculateCurrentInterval(for currentDistance: Double) -> TimeInterval {
        let clampedDistance = max(minDistance, min(currentDistance, maxDistance))
        let normalized = (clampedDistance - minDistance) / (maxDistance - minDistance)
        return minTimeInterval + normalized * (maxTimeInterval - minTimeInterval)
    }
    
    private func playBeep() {
//        AudioServicesPlaySystemSound(beepSoundID)
    }
}
