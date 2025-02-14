import SwiftUI

struct DebugView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        if appViewModel.isDebugMode {
            ZStack{
                DebugObjectDetectionView()
                DebugCaptureView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .allowsHitTesting(false)
        }
    }
}
