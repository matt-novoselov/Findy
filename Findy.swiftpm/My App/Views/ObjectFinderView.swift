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
    
    @State private var hasObjectBeenDetected: Bool = false
    
    var body: some View {
        let arContainer: ARContainer = .init(coordinator: arCoordinator)
        
        arContainer
            .overlay {
                DebugObjectDetectionView()
            }
        
            .overlay{
                RoundedRectangle(cornerRadius: getCornerRadius())
                    .stroke(.green, lineWidth: hasObjectBeenDetected ? 10 : 0, antialiased: true)
                    .animation(.spring, value: hasObjectBeenDetected)
            }
        
            .overlay{
                Button("Reset Object Detection"){
                    hasObjectBeenDetected.toggle()
                }
            }
        
            .ignoresSafeArea()
        
            .onChange(of: arCoordinator.detectionResults) {
                shootRaycastAtDetectedResult()
            }
        
            .overlay{
                DebugView()
            }
        
            .overlay{
                Text(arCoordinator.currentMeasurement?.rotation.description ?? "N/A")
            }
        
            .overlay{
                arrowView(degrees: Double(arCoordinator.currentMeasurement?.rotation ?? 0))
            }
        
            .overlay(alignment: .topLeading){
                @Bindable var appViewModel = appViewModel
                
                Toggle("Debug", isOn: $appViewModel.isDebugMode)
                    .toggleStyle(.switch)
                    .padding()
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                    .padding()
                    .frame(width: 200)
            }
        
    }
    
    func shootRaycastAtDetectedResult() {
        for result in arCoordinator.detectionResults {
            guard result.label == appViewModel.targetDetectionObject else { return }
            
            let adjustedResults = adjustObservations(
                detectionResults: [result],
                cameraImageDimensions: appViewModel.cameraImageDimensions
            )
            
            if let debugBox = adjustedResults.first?.boundingBox {
                arCoordinator.handleRaycast(at: .init(x: debugBox.midX, y: debugBox.midY))
            }
            
            if !hasObjectBeenDetected{
                speechSynthesizer.speak(text: "\(appViewModel.targetDetectionObject) detected!")
                
                if let distance = arCoordinator.currentMeasurement?.formatDistance(){
                    speechSynthesizer.speak(text: "\(appViewModel.targetDetectionObject) is \(distance) away.")
                }

                hasObjectBeenDetected = true
            }
        }
    }
    
}

struct arrowView: View {
    var degrees: Double = 0
    
    var body: some View {
        Image(systemName: "arrow.up")
            .rotationEffect(.init(degrees: -degrees))
            .foregroundStyle(.blue)
            .font(.largeTitle)
    }
}
