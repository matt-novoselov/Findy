import SwiftUI

struct PhotoCollectionView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        ForEach(Array(appViewModel.takenPhotos.enumerated()), id: \.offset) { index, photo in
            ImageCollectionView(photo: photo, index: index)
        }
    }
}

struct ImageCollectionView: View {
    var photo: CGImage
    var index: Int
    var body: some View {
        Image(decorative: photo, scale: 20)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(.rect(cornerRadius: 10))
            .rotationEffect(.degrees(index % 2 == 0 ? 5 : -5), anchor: .bottom)
//            .offset(x: CGFloat(index) * 8, y: CGFloat(index) * 8)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
