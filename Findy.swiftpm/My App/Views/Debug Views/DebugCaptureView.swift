//
//  DebugCaptureView.swift
//  Findy
//
//  Created by Matt Novoselov on 27/01/25.
//

import SwiftUI

struct DebugCaptureView: View {
    
    @Environment(ARCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        let mostProminentResult = selectMostProminentObservation(
            from: arCoordinator.detectionResults,
            targetObject: appViewModel.targetDetectionObject
        )
        
        ZStack {
            if let captureImage = arCoordinator.normalizedCaptureImage, let cgImage = captureImage.toCGImage() {
                Image(decorative: cgImage, scale: 7)
                    .clipShape(.rect(cornerRadius: 4))
                
                if let mostProminentResult {
                    CroppedImage(cgImage: cgImage, cropRect: mostProminentResult.boundingBox)
                        .frame(height: 100)
                } else {
                    Text("No object detected")
                }
            } else {
                Text("No capture")
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding()
    }
}

struct CroppedImage: View {
    let cgImage: CGImage
    let cropRect: CGRect
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        Image(uiImage: UIImage(cgImage: cropImage(cgImage, to: cropRect)!))
            .resizable()
            .scaledToFit()
    }
    
    func cropImage(_ image: CGImage, to rect: CGRect) -> CGImage? {
        guard rect.size.width > 0, rect.size.height > 0 else { return nil }
        appViewModel.lastCroppedImage = image.cropping(to: rect)
        return image.cropping(to: rect)
    }
}
