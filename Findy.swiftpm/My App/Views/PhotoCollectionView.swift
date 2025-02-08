//
//  PhotoCollectionView.swift
//  Findy
//
//  Created by Matt Novoselov on 07/02/25.
//

import SwiftUI

struct PhotoCollectionView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack{
                ForEach(Array(appViewModel.takenPhotos.enumerated()), id: \.offset) { index, photo in
                    ImageCollectionView(photo: photo, index: index)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct ImageCollectionView: View {
    var photo: CGImage
    var index: Int
    var body: some View {
        Image(decorative: photo, scale: 20)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .rotationEffect(.degrees(index % 2 == 0 ? 5 : -5))
            .offset(x: CGFloat(index) * 8, y: CGFloat(index) * 8)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
