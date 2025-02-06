//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 06/02/25.
//

import SwiftUI

struct FocusBoxParentView: View {
    
    @Environment(ARCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        
        let adjustedResults = adjustObservations(
            detectionResults: arCoordinator.detectionResults,
            cameraImageDimensions: appViewModel.cameraImageDimensions
        )
        
        let mostProminentResult = selectMostProminentObservation(from: adjustedResults, targetObject: appViewModel.targetDetectionObject)
        
        if let selectedResult = mostProminentResult {
            FocusBoxView(result: selectedResult)
                .allowsHitTesting(false)
                .aspectRatio(appViewModel.cameraImageDimensions.width / appViewModel.cameraImageDimensions.height, contentMode: .fit)
        }
        
    }
}

struct FocusBoxView: View {
    var result: ProcessedObservation
    
    var body: some View {
        let rect = result.boundingBox
        
        ZStack{
            // Top left
            DashedRoundedRectangle(cornerRadius: 20)
                .stroke(.yellow, style: StrokeStyle(lineWidth:4 , lineCap: .round))
            
            // Top right
            DashedRoundedRectangle(cornerRadius: 20)
                .flippedHorizontally()
                .stroke(.yellow, style: StrokeStyle(lineWidth:4 , lineCap: .round))
            
            // Bottom right
            DashedRoundedRectangle(cornerRadius: 20)
                .flippedHorizontally()
                .flippedVertically()
                .stroke(.yellow, style: StrokeStyle(lineWidth:4 , lineCap: .round))
            
            // Bottom left
            DashedRoundedRectangle(cornerRadius: 20)
                .flippedVertically()
                .stroke(.yellow, style: StrokeStyle(lineWidth:4 , lineCap: .round))
        }
        .frame(width: rect.width + 50, height: rect.height + 50)
        .position(x: rect.midX, y: rect.midY)
        .animation(.easeInOut(duration: 0.2), value: rect)
    }
}

struct DashedRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top-left corner with a quarter-circle arc
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),  // Start at the left side
                    endAngle: .degrees(270),     // End at the bottom side
                    clockwise: false)
        
        return path
    }
}
