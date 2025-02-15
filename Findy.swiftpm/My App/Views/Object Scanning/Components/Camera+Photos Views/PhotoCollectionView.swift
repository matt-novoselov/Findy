import SwiftUI

struct PhotoCollectionView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        GeometryReader{ proxy in
            ForEach(Array(appViewModel.savedObject.takenPhotos.enumerated()), id: \.offset) { index, capturedPhoto in
                ImageCollectionView(photo: capturedPhoto.photo, index: index, geometryReaderSize: proxy.size)
            }
        }
        .ignoresSafeArea()
    }
}

struct ImageCollectionView: View {
    var photo: CGImage
    var index: Int
    var geometryReaderSize: CGSize
    let imageSize = 100.0
    @State private var imageScale: CGFloat = 0.2
    @State private var imageOffset: CGSize
    @State private var currentRotation: Double = 0
    
    init(photo: CGImage, index: Int, geometryReaderSize: CGSize) {
        self.photo = photo
        self.index = index
        self.geometryReaderSize = geometryReaderSize
        self.imageOffset = .init(width: geometryReaderSize.width - imageSize, height: geometryReaderSize.height/2 - imageSize/2)
    }
    
    var body: some View {
        Image(decorative: photo, scale: 20)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .clipShape(.rect(cornerRadius: 10))
            .rotationEffect(.degrees(currentRotation), anchor: .bottom)
            .scaleEffect(imageScale)
            .offset(imageOffset)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .opacity(imageScale)
            .onAppear{
                withAnimation(.bouncy){
                    imageOffset = .init(width: 0, height: geometryReaderSize.height - imageSize)
                    imageScale = 1
                    currentRotation = index % 2 == 0 ? 5 : -5
                }
            }
    }
}
