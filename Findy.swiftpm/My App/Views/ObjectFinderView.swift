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
        
        var maxArea: CGFloat = 0
        var selectedAdjustedObservation: ProcessedObservation?
        
        // Process each matching result to find the one with the largest adjusted bounding box
        for result in matchingResults {
            let adjustedResults = adjustObservations(
                detectionResults: [result],
                cameraImageDimensions: appViewModel.cameraImageDimensions
            )
            
            guard let adjustedResult = adjustedResults.first else { continue }
            
            let currentArea = adjustedResult.boundingBox.width * adjustedResult.boundingBox.height
            if currentArea > maxArea {
                maxArea = currentArea
                selectedAdjustedObservation = adjustedResult
            }
        }
        
        // Perform raycast and handle detection announcement
        if let selected = selectedAdjustedObservation {
            let raycastPoint = CGPoint(x: selected.boundingBox.midX, y: selected.boundingBox.midY)
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
    
}

