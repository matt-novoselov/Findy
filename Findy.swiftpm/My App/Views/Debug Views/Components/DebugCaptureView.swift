import SwiftUI

struct DebugCaptureView: View {
    
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    
    var body: some View {
        if let captureImage = arCoordinator.processedFrameImage,
           let cgImage = captureImage.toCGImage(){
            Image(decorative: cgImage, scale: 7)
                .padding()
        } else {
            Text("No capture")
        }
    }
}
