import SwiftUI

struct DebugCaptureView: View {
    
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        // Display the captured image if available.
        if let captureImage = arCoordinator.processedFrameImage, let cgImage = captureImage.toCGImage() {
            // Display the captured image.
            Image(decorative: cgImage, scale: 7)
                .clipShape(.rect(cornerRadius: cornerRadius))
                .padding(.all, 4)
                .background(Material.ultraThin, in: .rect(cornerRadius: cornerRadius + 4))
                .padding()
                .padding(.top)
        } else {
            Text("No capture")
                .fontDesign(.rounded)
        }
    }
}
