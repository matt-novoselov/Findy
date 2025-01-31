//
//  DebugCaptureView.swift
//  Findy
//
//  Created by Matt Novoselov on 27/01/25.
//

import SwiftUI

struct DebugCaptureView: View {
    
    @Environment(ARCoordinator.self) private var arCoordinator
    
    var body: some View {
        ZStack {
            if let captureImage = arCoordinator.normalizedCaptureImage, let cgImage = captureImage.toCGImage() {
                Image(decorative: cgImage, scale: 7)
                    .clipShape(.rect(cornerRadius: 4))
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
