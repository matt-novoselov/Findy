//
//  MetalDetector.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//


import AVFoundation

class MetalDetector {
    
    // Configuration
    private let minDistance: Double = 0.0
    private let maxDistance: Double = 10.0
    private let minInterval: TimeInterval = 0.05
    private let maxInterval: TimeInterval = 2.0
    private let soundID: SystemSoundID = 1052
    private let checkInterval: TimeInterval = 0.05
    
    private var timer: Timer?
    private var lastBeepTime: Date?
    weak var arCoordinator: ARCoordinator?
    
    init() {
        startDetection()
    }
    
    deinit {
        stopDetection()
    }
    
    private func startDetection() {
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            self?.checkForBeep()
        }
    }
    
    private func stopDetection() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForBeep() {
        guard let currentDistance = arCoordinator?.currentMeasurement?.meterDistance else { return }
        
        let now = Date()
        let elapsed = lastBeepTime.map { now.timeIntervalSince($0) } ?? maxInterval
        let requiredInterval = calculateCurrentInterval(for: Double(currentDistance))
        
        if elapsed >= requiredInterval {
            playBeep()
            lastBeepTime = now
        }
    }
    
    private func calculateCurrentInterval(for currentDistance: Double) -> TimeInterval {
        let clampedDistance = max(minDistance, min(currentDistance, maxDistance))
        let normalized = (clampedDistance - minDistance) / (maxDistance - minDistance)
        return minInterval + normalized * (maxInterval - minInterval)
    }
    
    private func playBeep() {
        AudioServicesPlaySystemSound(soundID)
    }
}
