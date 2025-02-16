import SwiftUI

struct PhotoCollectionView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        ZStack {
            ForEach(Array(appViewModel.savedObject.takenPhotos.enumerated()), id: \.offset) { index, capturedPhoto in
                ImageCollectionView(photo: capturedPhoto.photo, index: index)
            }
        }
        .ignoresSafeArea()
    }
}

struct ImageCollectionView: View {
    var photo: CGImage
    var index: Int
    let imageSize: CGFloat = 100
    @State private var imageScale: CGFloat = 0.2
    @State private var currentRotation: Double = 0
    @State private var alignment: Alignment = .trailing

    var body: some View {
        ZStack(alignment: alignment) {
            Color.clear  // Fills the space
            Image(decorative: photo, scale: 20)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .rotationEffect(.degrees(currentRotation), anchor: .bottom)
                .scaleEffect(imageScale)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .opacity(Double(imageScale))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.bouncy) {
                alignment = .bottomLeading
                imageScale = 1
                currentRotation = index % 2 == 0 ? 5 : -5
            }
        }
    }
}
