import SwiftUI

struct DebugView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        if appViewModel.isDebugMode {
            DebugObjectDetectionView()
                .overlay(alignment: .bottomLeading){
                    DebugCaptureView()
                }
                .allowsHitTesting(false)
        }
    }
}
