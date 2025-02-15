import SwiftUI

struct OldPhotoView: View {
    @State private var didAppear = false
    var body: some View {
        Image(.oldPhoto)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(!didAppear ? Angle(degrees: -180) : .zero, anchor: .bottomLeading)
            .frame(width: 350)
            .padding()
            .onAppear {
                withAnimation(.bouncy(duration: 3)) {
                    didAppear = true
                }
            }
    }
}
