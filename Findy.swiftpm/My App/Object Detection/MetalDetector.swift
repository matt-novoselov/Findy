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
    
    // The spatial audio resource and the entity used to play it.
    private var beepAudioResource: AudioFileResource?
    private var beepEntity: Entity?
    
    // Your AR scene coordinator—for example, this might hold your ARView.
    weak var arCoordinator: ARSceneCoordinator?
    
    init() {
        // Start checking the distance for beeping
        startDetection()
    }
    
    deinit {
        stopDetection()
    }
    
    /// Loads the beep audio file as a spatial resource and creates an entity for sound playback.
    public func setupBeepAudio(anchor: AnchorEntity) {
        // Adjust the file name and extension as needed (e.g. beep.mp3 or beep.wav)
        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "mp3")
        else {
            print("Unable to find beep.mp3 in the bundle.")
            return
        }
        
        do {
            // Load the spatial audio resource.
            let resource = try AudioFileResource.load(
                contentsOf: soundURL,
                withName: "beep",
                    inputMode: .spatial
            )
            self.beepAudioResource = resource
            
            // Create an empty entity that will later be positioned for spatial effect.
            let entity = Entity()
            self.beepEntity = entity
            
            anchor.addChild(entity)
            
        } catch {
            print("Error loading beep audio resource: \(error)")
        }
    }
    
    /// Starts a timer to continuously check if it’s time to play a beep.
    private func startDetection() {
        timer = Timer.scheduledTimer(withTimeInterval: checkTimeInterval,
                                     repeats: true) { [weak self] _ in
            self?.checkForBeep()
        }
    }
    
    /// Stops the detection timer.
    private func stopDetection() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Checks the current distance and, if conditions are met, plays the beep sound.
    private func checkForBeep() {
        // Ensure we have a valid distance measurement
        guard let currentDistance = arCoordinator?.currentMeasurement?.meterDistance else {
            return
        }
        // Ensure metal detection sound is enabled in your view-model.
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
    
    /// Calculates the interval required between beeps based on the current distance.
    private func calculateCurrentInterval(for currentDistance: Double) -> TimeInterval {
        let clampedDistance = max(minDistance, min(currentDistance, maxDistance))
        let normalized = (clampedDistance - minDistance) /
        (maxDistance - minDistance)
        return minTimeInterval + normalized * (maxTimeInterval - minTimeInterval)
    }
    
    /// Plays the beep sound using the spatial audio resource.
    private func playBeep() {
        guard let resource = beepAudioResource, let beepEntity = beepEntity else {
            return
        }
        
        // Play the audio from the entity.
        _ = beepEntity.playAudio(resource)
    }
}
