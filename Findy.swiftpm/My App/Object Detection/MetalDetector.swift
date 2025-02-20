import AVFoundation
import RealityKit

class MetalDetector {
    // Configuration for beep timing based on distance
    private let minDistance: Double = 0.0
    private let maxDistance: Double = 10.0
    private let minTimeInterval: TimeInterval = 0.05
    private let maxTimeInterval: TimeInterval = 2.0
    private let checkTimeInterval: TimeInterval = 0.05
    
    private var timer: Timer?
    private var lastBeepTime: Date?
    
    // The audio resource and the entity used to play it
    private var beepAudioResource: AudioFileResource?
    private var beepEntity: Entity?
    
    weak var arCoordinator: ARSceneCoordinator?
    
    init() {
        startDetection()
    }
    
    deinit {
        stopDetection()
    }
    
    /// Loads the beep audio file and creates an entity with spatial audio component
    public func setupBeepAudio(anchor: AnchorEntity) {
        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "mp3")
        else {
            print("Unable to find beep.mp3 in the bundle.")
            return
        }
        
        do {
            // Load the audio resource with new configuration
            let resource = try AudioFileResource.load(
                contentsOf: soundURL,
                withName: "beep",
                configuration: .init(
                    shouldLoop: false
                )
            )
            self.beepAudioResource = resource
            
            // Create an entity with spatial audio component
            let entity = Entity()
            
            // Configure spatial audio component
            entity.spatialAudio = SpatialAudioComponent(
                gain: -5, // Adjust gain as needed (-5 dB reduction from nominal level)
                directivity: .beam(focus: 0.8), // Focused directional sound
                distanceAttenuation: .rolloff(factor: 1.5) // Sound attenuation with distance
            )
            
            // Optional: Configure reverb level if needed
            entity.spatialAudio?.reverbLevel = -12 // Less reverberant, more direct sound
            
            self.beepEntity = entity
            anchor.addChild(entity)
            
        } catch {
            print("Error loading beep audio resource: \(error)")
        }
    }
    
    private func startDetection() {
        timer = Timer.scheduledTimer(withTimeInterval: checkTimeInterval,
                                   repeats: true) { [weak self] _ in
            self?.checkForBeep()
        }
    }
    
    private func stopDetection() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForBeep() {
        guard let currentDistance = arCoordinator?.currentMeasurement?.meterDistance else {
            return
        }
        guard arCoordinator?.appViewModel?.isMetalDetectionSoundEnabled == true else {
            return
        }
        
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
        let normalized = (clampedDistance - minDistance) /
        (maxDistance - minDistance)
        return minTimeInterval + normalized * (maxTimeInterval - minTimeInterval)
    }
    
    private func playBeep() {
        guard let resource = beepAudioResource, let beepEntity = beepEntity else {
            return
        }
        
        beepEntity.playAudio(resource)
    }
}
