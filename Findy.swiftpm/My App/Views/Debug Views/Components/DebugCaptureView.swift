import SwiftUI

struct DebugCaptureView: View {
    
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        if let captureImage = arCoordinator.processedFrameImage, let cgImage = captureImage.toCGImage() {
            Image(decorative: cgImage, scale: 7)
                .clipShape(.rect(cornerRadius: 4))
        } else {
            Text("No capture")
                .fontDesign(.rounded)
        }
    }
}
