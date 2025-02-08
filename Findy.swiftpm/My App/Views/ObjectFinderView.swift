//
//  ImmersiveView.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 24/01/25.
//
//

import SwiftUI
import AVFoundation

struct ObjectFinderView: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARCoordinator.self) private var arCoordinator
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    
    @State private var cameraShutterToggle: Bool = false
    
    var body: some View {
        let arContainer: ARContainer = .init(coordinator: arCoordinator)
        
        arContainer
        
//            .brightness(-0.1)
//            .overlay(
//                GeometryReader { geometry in
//                    RadialGradient(
//                        gradient: Gradient(colors: [.clear, .black]),
//                        center: .center,
//                        startRadius: 0,
//                        endRadius: max(geometry.size.width, geometry.size.height) / 2
//                    )
//                    .opacity(1)
//                }
//            )
//            .blur(radius: 20)
        
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
        
            .overlay{
                CameraShutterView(isShutterActive: $cameraShutterToggle)
            }
        
            .ignoresSafeArea()
        
            .onChange(of: arCoordinator.detectionResults) {
                shootRaycastAtDetectedResult()
            }
        
            .overlay{
                DebugView()
            }
        
            .overlay{
                PhotoCollectionView()
            }
        
            .overlay{
                CameraShutterButton(action: {
                    takePhoto()
                })
                .disabled(appViewModel.isAnyObjectDetected ? false : true)
                .opacity(appViewModel.isAnyObjectDetected ? 1 : 0.2)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
        
            .overlay{
                if let degrees = arCoordinator.currentMeasurement?.rotation {
                    VStack{
                        ArrowView(degrees: Double(degrees))

                        Text("Pointing: \(getDirection(degrees: Double(degrees)))")
                            .padding()
                            .font(.title)
                    }
                    .allowsHitTesting(false)
                }
            }
    }
    
    func takePhoto(){
        // Play shutter animation
        cameraShutterToggle.toggle()
        
        // Play shutter sound
        AudioServicesPlaySystemSound(1108)
        
        if appViewModel.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity {
            if let capturedImage = arCoordinator.normalizedCaptureImage?.toCGImage() {
                appViewModel.takenPhotos.append(capturedImage)
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
        let raycastPoint = CGPoint(x: selectedObservation.boundingBox.midX, y: selectedObservation.boundingBox.minY)
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
func selectMostProminentObservation(from observations: [ProcessedObservation], targetObject: String? = nil) -> ProcessedObservation? {
    
    let filteredObservations: [ProcessedObservation]
    
    if (targetObject != nil){
        // Filter observations by target object
        filteredObservations = observations.filter { $0.label == targetObject }
        
        guard !filteredObservations.isEmpty else {
            return nil
        }
    } else {
        filteredObservations = observations
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
