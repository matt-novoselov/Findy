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
//
//import AVFoundation
//import RealityKit
//
//class MetalDetector {
//    // Configuration for beep timing based on distance
//    private let minDistance: Double = 0.0
//    private let maxDistance: Double = 10.0
//    private let minTimeInterval: TimeInterval = 0.05
//    private let maxTimeInterval: TimeInterval = 2.0
//    private let checkTimeInterval: TimeInterval = 0.05
//
//    private var timer: Timer?
//    private var lastBeepTime: Date?
//
//    // The spatial audio resource and the entity used to play it.
//    private var beepAudioResource: AudioFileResource?
//    private var beepEntity: Entity?
//
//    // Your AR scene coordinator—for example, this might hold your ARView.
//    weak var arCoordinator: ARSceneCoordinator?
//
//    init() {
//        // Start checking the distance for beeping
//        startDetection()
//    }
//
//    deinit {
//        stopDetection()
//    }
//
//    /// Loads the beep audio file as a spatial resource and creates an entity
//    /// for sound playback.
//    public func setupBeepAudio(anchor: AnchorEntity) {
//        // Adjust the file name and extension as needed (e.g., beep.mp3 or beep.wav)
//        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "mp3")
//        else {
//            print("Unable to find beep.mp3 in the bundle.")
//            return
//        }
//
//        do {
//            // Use a configuration for the audio resource instead of the deprecated
//            // inputMode parameter. Adjust shouldLoop or other options as needed.
//            let configuration = AudioFileResource.Configuration(shouldLoop: false)
//            let resource = try AudioFileResource.load(
//                contentsOf: soundURL,
//                withName: "beep",
//                configuration: configuration
//            )
//            self.beepAudioResource = resource
//
//            // Create an entity that will play the beep sound.
//            let entity = Entity()
//
//            // Attach a SpatialAudioComponent to the entity to enable spatial sound.
//            // You can adjust the gain, directLevel, reverbLevel, and other properties.
//            entity.spatialAudio = SpatialAudioComponent(gain: -5)
//
//            self.beepEntity = entity
//
//            // Add the spatial audio entity to the provided anchor.
//            anchor.addChild(entity)
//        } catch {
//            print("Error loading beep audio resource: \(error)")
//        }
//    }
//
//    /// Starts a timer to continuously check if it’s time to play a beep.
//    private func startDetection() {
//        timer = Timer.scheduledTimer(withTimeInterval: checkTimeInterval,
//                                     repeats: true) { [weak self] _ in
//            self?.checkForBeep()
//        }
//    }
//
//    /// Stops the detection timer.
//    private func stopDetection() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    /// Checks the current distance and, if conditions are met, plays the beep sound.
//    private func checkForBeep() {
//        // Ensure we have a valid distance measurement
//        guard let currentDistance = arCoordinator?.currentMeasurement?.meterDistance else {
//            return
//        }
//        // Ensure metal detection sound is enabled in your view-model.
//        guard arCoordinator?.appViewModel?.isMetalDetectionSoundEnabled == true else {
//            return
//        }
//
//        let now = Date()
//        let elapsed = lastBeepTime.map { now.timeIntervalSince($0) } ?? maxTimeInterval
//        let requiredInterval = calculateCurrentInterval(for: currentDistance)
//
//        if elapsed >= requiredInterval {
//            playBeep()
//            lastBeepTime = now
//        }
//    }
//
//    /// Calculates the interval required between beeps based on the current distance.
//    private func calculateCurrentInterval(for currentDistance: Double) -> TimeInterval {
//        let clampedDistance = max(minDistance, min(currentDistance, maxDistance))
//        let normalized = (clampedDistance - minDistance) / (maxDistance - minDistance)
//        return minTimeInterval + normalized * (maxTimeInterval - minTimeInterval)
//    }
//
//    /// Plays the beep sound using the spatial audio resource.
//    private func playBeep() {
//        guard let resource = beepAudioResource, let beepEntity = beepEntity else {
//            return
//        }
//
//        // Play the audio from the entity.
//        _ = beepEntity.playAudio(resource)
//    }
//}
