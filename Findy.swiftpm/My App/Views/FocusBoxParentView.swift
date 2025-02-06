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
        
        let mostProminentResult = selectMostProminentObservation(
            from: adjustedResults,
            targetObject: appViewModel.targetDetectionObject
        )
        
        if let selectedResult = mostProminentResult {
            FocusBoxView(result: selectedResult)
                .allowsHitTesting(false)
                .aspectRatio(
                    appViewModel.cameraImageDimensions.width /
                    appViewModel.cameraImageDimensions.height,
                    contentMode: .fit
                )
        }
    }
}

struct FocusBoxView: View {
    var result: ProcessedObservation
    
    var body: some View {
        let rect = result.boundingBox
        
        DashedCornersShape(cornerRadius: 20)
            .stroke(.yellow, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: rect.width + 50, height: rect.height + 50)
            .position(x: rect.midX, y: rect.midY)
            .animation(.easeInOut(duration: 0.2), value: rect)
    }
}

// Single shape that draws corner arcs on each subpath
struct DashedCornersShape: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // Top-right
        path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom-left
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        return path
    }
}
