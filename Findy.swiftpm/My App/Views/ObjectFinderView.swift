//
//  ImmersiveView.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 24/01/25.
//
//

import SwiftUI

struct ObjectFinderView: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARCoordinator.self) private var arCoordinator
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    
    var body: some View {
        let arContainer: ARContainer = .init(coordinator: arCoordinator)
        
        arContainer
            .overlay {
                DebugObjectDetectionView()
            }
        
            .overlay{
                FocusBoxParentView()
            }
        
            .overlay{
                RoundedRectangle(cornerRadius: getCornerRadius())
                    .stroke(.green, lineWidth: appViewModel.hasObjectBeenDetected ? 10 : 0, antialiased: true)
                    .animation(.spring, value: appViewModel.hasObjectBeenDetected)
            }
        
            .ignoresSafeArea()
        
            .onChange(of: arCoordinator.detectionResults) {
                shootRaycastAtDetectedResult()
            }
        
            .overlay{
                DebugView()
            }
        
            .overlay{
                if let degrees = arCoordinator.currentMeasurement?.rotation {
                    VStack{
                        ArrowView(degrees: Double(degrees))

                        Text("Pointing: \(getDirection(degrees: Double(degrees)))")
                            .padding()
                            .font(.title)
                    }
                }
            }
    }
    
    func shootRaycastAtDetectedResult() {
        let targetObject = appViewModel.targetDetectionObject
        let matchingResults = arCoordinator.detectionResults.filter { $0.label == targetObject }

        guard !matchingResults.isEmpty else { return }

        // Process and select the most prominent observation
        let adjustedResults = adjustObservations(
            detectionResults: matchingResults,
            cameraImageDimensions: appViewModel.cameraImageDimensions
        )

        guard let selectedObservation = selectMostProminentObservation(from: adjustedResults, targetObject: targetObject) else {
            return
        }

        // Perform raycast and handle detection announcement
        let raycastPoint = CGPoint(x: selectedObservation.boundingBox.midX, y: selectedObservation.boundingBox.midY)
        arCoordinator.handleRaycast(at: raycastPoint)

        if !appViewModel.hasObjectBeenDetected {
            speechSynthesizer.speak(text: "\(targetObject) detected!")
            
            if let distance = arCoordinator.currentMeasurement?.formatDistance() {
                speechSynthesizer.speak(text: "\(targetObject) is \(distance) away.")
            }
            
            appViewModel.hasObjectBeenDetected = true
        }

    }
    
}

/// Filters and selects the most prominent ProcessedObservation based on target object and bounding box area
/// - Parameters:
///   - observations: Array of ProcessedObservation to filter
///   - targetObject: The target object name to filter by
/// - Returns: The ProcessedObservation with the largest bounding box area for the target object
func selectMostProminentObservation(from observations: [ProcessedObservation], targetObject: String) -> ProcessedObservation? {
    // Filter observations by target object
    let filteredObservations = observations.filter { $0.label == targetObject }
    
    guard !filteredObservations.isEmpty else {
        return nil
    }
    
    // If only one observation, return it immediately
    guard filteredObservations.count > 1 else {
        return filteredObservations.first
    }
    
    var maxArea: CGFloat = 0
    var mostProminentObservation: ProcessedObservation?
    
    // Find observation with largest bounding box area
    for observation in filteredObservations {
        let area = observation.boundingBox.width * observation.boundingBox.height
        if area > maxArea {
            maxArea = area
            mostProminentObservation = observation
        }
    }
    
    return mostProminentObservation
}
