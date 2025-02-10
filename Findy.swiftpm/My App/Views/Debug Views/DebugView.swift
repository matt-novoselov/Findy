import SwiftUI

struct DebugView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        Group{
            if appViewModel.isDebugMode {
                DebugObjectDetectionView()
                DebugCaptureView()
            }
        }
        .allowsHitTesting(false)
    }
}
