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
    @State private var geometrySize: CGRect = .zero
    
    var body: some View {
        let arContainer: ARContainer = .init(coordinator: arCoordinator)
        
        arContainer
            .overlay {
                DebugObjectDetectionView()
            }
        
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newValue in
                self.geometrySize = newValue
            }
        
            .ignoresSafeArea()
        
            .onChange(of: arCoordinator.detectionResults) {
                shootRaycastAtDetectedResult()
            }
        
            .overlay{
                DebugView()
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
                geometrySize: geometrySize.size,
                cameraImageDimensions: appViewModel.cameraImageDimensions
            )
            
            if let debugBox = adjustedResults.first?.boundingBox {
                arCoordinator.handleRaycast(at: .init(x: debugBox.midX, y: debugBox.midY))
            }
        }
    }
    
}
