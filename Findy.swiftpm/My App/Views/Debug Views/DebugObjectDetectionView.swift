//
//  DebugObjectDetectionView.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 26/01/25.
//
import SwiftUI

struct DebugObjectDetectionView: View {
    
    @Environment(ARCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        
        if appViewModel.isDebugMode{
            GeometryReader { geometry in
                let adjustedResults = adjustObservations(
                    detectionResults: arCoordinator.detectionResults,
                    geometrySize: geometry.size,
                    cameraImageDimensions: appViewModel.cameraImageDimensions
                )
                
                ForEach(adjustedResults, id: \.id) { result in
                    BoundingBox(result: result)
                }
            }
            .aspectRatio(appViewModel.cameraImageDimensions.width / appViewModel.cameraImageDimensions.height, contentMode: .fit)
            .allowsHitTesting(false)
        }

    }
}

struct BoundingBox: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    var result: ProcessedObservation
    
    var body: some View {
        let rect = result.boundingBox
        let boxColor: Color = (result.label == appViewModel.targetDetectionObject) ? Color.green : .red
        
        ZStack(alignment: .topLeading) {
            // Draw bounding box
            Rectangle()
                .stroke(boxColor, lineWidth: 2)
                .background(boxColor.opacity(0.1))
            
            // Label and confidence
            Text("\(result.label) \(String(format: "%.1f", result.confidence * 100))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(4)
                .background(.black.opacity(0.7))
                .cornerRadius(4)
                .offset(y: -20) // Position above the bounding box
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }
}
