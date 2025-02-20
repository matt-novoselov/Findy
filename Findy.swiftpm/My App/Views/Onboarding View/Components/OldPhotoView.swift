import SwiftUI

struct OldPhotoView: View {
    @State private var didAppear = false
    var body: some View {
        Image("OldPhoto")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(!didAppear ? Angle(degrees: -180) : .zero, anchor: .bottomLeading)
            .frame(width: 350)
            .padding()
            .accessibilityHidden(true)
            .onAppear {
                withAnimation(.bouncy(duration: 3)) {
                    didAppear = true
                }
            }
    }
}
