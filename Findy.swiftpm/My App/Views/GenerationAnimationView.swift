//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 09/02/25.
//

import SwiftUI

struct GenerationAnimationView: View {
//    @State private var arrayOfImages: [CGImage] = []
    @State private var shouldAnimate: Bool = false
    let columns = Array(repeating: GridItem(.fixed(100)), count: 3)
    @State private var ScaleOverTime: Bool = false
    @State private var IsProcessingFinished: Bool = false
    @State private var transition: Bool = false
    @State private var transition2: Bool = false
    
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        VStack {
            ZStack{
                
                if transition{
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 120))
                        .symbolEffect(.bounce, value: transition2)
                        .symbolEffect(.pulse, value: transition2)
                        .foregroundStyle(.white)
                        .brightness(!transition2 ? 1 : 0)
                        .contrast(!transition2 ? 10 : 1)
                        .shadow(color: .white.opacity(0.8), radius: !transition2 ? 30 : 0)
                        .shadow(color: .white.opacity(0.8), radius: !transition2 ? 30 : 0)
                }
                
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<9, id: \.self) { _ in
                        if shouldAnimate, !appViewModel.takenPhotos.isEmpty {
                            ImageCollectionView2()
                                .blur(radius: IsProcessingFinished ? 20 : 0)
                        }
                    }
                }
                .scaleEffect(ScaleOverTime ? 1.5 : 1)
                .scaleEffect(transition ? 0 : 1)
                .brightness(IsProcessingFinished ? 1 : 0)
                .contrast(IsProcessingFinished ? 2 : 1)
                .shadow(color: .white, radius: IsProcessingFinished ? 100 : 0)
                .opacity(transition ? 0 : 1)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation{
                shouldAnimate.toggle()
            } completion: {
                withAnimation(.easeOut(duration: 10)){
                    ScaleOverTime = true
                } completion: {
                    withAnimation(.easeOut(duration: 3)){
                        IsProcessingFinished = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation{
                                transition = true
                            } completion: {
                                withAnimation(.spring(duration: 3)){
                                    transition2 = true
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
//    func loadImageAsync() {
//        let arrayOfImages: [ImageResource] = [.im1, .im2, .im3, .im4, .im5]
//        for image in arrayOfImages {
//            loadImage(from: image)
//        }
//    }
//    
//    func loadImage(from imageResource: ImageResource) {
//        let inputImage = UIImage(resource: imageResource)
//        if
//            let beginImage = CIImage(image: inputImage),
//            let finalImage = beginImage.toCGImage() {
//            arrayOfImages.append(finalImage)
//        }
//    }
}

struct ImageCollectionView2: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    @State private var displayedElement: Int?
    @State private var isScaled = false
    
    @State private var rootOffsetX: CGFloat = 1000
    @State private var rootOffsetY: CGFloat = 1000
    @State private var rootBlur: CGFloat = 100
    @State private var isAnimated: Bool = false
    
    @State private var timerTask: Task<Void, Never>? = nil
    
    var body: some View {
        let arrayOfImages = appViewModel.takenPhotos
        Image(decorative: arrayOfImages[displayedElement ?? Int.random(in: 0...arrayOfImages.count - 1)], scale: 20)
            .resizable()
            .brightness(isScaled ? 0.5 : 0)
            .scaleEffect(isScaled ? 1.2 : 1.0)
            .scaledToFill()
            .overlay{
                LinearGradient(gradient: Gradient(colors: [.pink, .red]), startPoint: .top, endPoint: .bottom)
                    .opacity(isAnimated ? 0 : 1)
            }
            .frame(width: 100, height: 100)
            .blur(radius: isScaled ? 5 : 0)
            .clipShape(.rect(cornerRadius: 10))
            .offset(x: rootOffsetX, y: rootOffsetY)
            .blur(radius: rootBlur)
        
            .onAppear {
                if Bool.random() {
                    rootOffsetX *= -1
                }
                if Bool.random() {
                    rootOffsetY *= -1
                }
                
                // Generate a random delay between 0 and 2 seconds
                let randomDelay = Double.random(in: 0...5)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                    withAnimation(.spring(duration: 1.0)) {
                        self.rootOffsetX = 0
                        self.rootOffsetY = 0
                    }
                    
                    withAnimation(.spring(duration: 1.5)) {
                        self.rootBlur = 0
                        self.isAnimated = true
                    } completion: {
                        startRepeatingTask()
                    }
                }
            }
            .onDisappear {
                timerTask?.cancel()
            }
        
    }
    
    func startRepeatingTask() {
        timerTask = Task {
            while !Task.isCancelled {
                let randomDelay = Double.random(in: 1...3)
                try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))
                performAction()
            }
        }
    }
    
    func performAction() {
        // First scale down with animation
        withAnimation(.spring) {
            isScaled = true
        } completion: {
            displayedElement = Int.random(in: 0..<appViewModel.takenPhotos.count - 1)
            withAnimation(.spring) {
                isScaled = false
            }
        }
    }
}

//
//#Preview {
//    GenerationAnimationView()
//}
