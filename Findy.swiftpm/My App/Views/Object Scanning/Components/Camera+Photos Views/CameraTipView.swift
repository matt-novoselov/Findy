import SwiftUI
import TipKit

struct CameraTipView: View {
    var isOnboardingActive: Bool
    private let tip = CameraButtonTip()
    var body: some View {
        Group{
            if !isOnboardingActive{
                TipView(tip, arrowEdge: .trailing)
                    .tipImageStyle(Color.secondary)
                    .ignoresSafeArea()
                    .frame(width: 400)
                    .padding(.trailing, 90)
                    .transition(.blurReplace)
            }
        }
        .animation(.spring, value: isOnboardingActive)
    }
}
