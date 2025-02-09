//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 09/02/25.
//

import SwiftUI

struct GenerationAnimationView: View {

    @State private var shouldAnimate: Bool = false
    let columns = Array(repeating: GridItem(.fixed(100)), count: 3)
    @State private var ScaleOverTime: Bool = false
    @State private var IsProcessingFinished: Bool = false
    @State private var transition: Bool = false
    @State private var transition2: Bool = false
    
    @Environment(AppViewModel.self) private var appViewModel
    
#if canImport(CreateML)
    @State private var imageClassifierModel: MLImageClassifier?
#endif
    
    
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
            
#if canImport(CreateML)
            if (imageClassifierModel != nil) {
                Button("Predict"){
                    let prediction = try! imageClassifierModel?.prediction(from: appViewModel.lastCroppedImage!)
                    print(prediction?.description)
                }
            }
#endif
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
#if canImport(CreateML)
            do {
                imageClassifierModel = try await trainModel()
            } catch {
                print(error)
            }
#endif
        }
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

#if canImport(CreateML)
import CreateML
import CoreML
func trainModel() async throws -> MLImageClassifier {
    // 1. Get all jpg file URLs from the main bundle.
    guard let jpgURLs = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: nil) else {
        throw NSError(
            domain: "ModelTraining",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "No jpg files found in the bundle"]
        )
    }

    // 2. Filter to files whose name starts with "GeneralObject".
    let generalObjectURLs = jpgURLs.filter { $0.lastPathComponent.hasPrefix("GeneralObject") }
    
    // 1. Get all png file URLs from the main bundle.
    guard let pngURLs = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: nil) else {
        throw NSError(
            domain: "ModelTraining",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "No png files found in the bundle"]
        )
    }

    // 2. Filter to files whose name starts with "myObject".
    let myObjectURLs = pngURLs.filter { $0.lastPathComponent.hasPrefix("myObject") }

    // 3. Create the dictionary
    let generalObjectsDict: [String: [URL]] = [
        "GeneralObject": generalObjectURLs,
        "myObject": myObjectURLs
    ]

    let dataset: MLImageClassifier.DataSource = .filesByLabel(generalObjectsDict)

    let trainParameters: MLImageClassifier.ModelParameters = .init(
        validation: .split(strategy: .automatic),
        maxIterations: 100,
        augmentation: [.blur, .exposure, .flip, .noise, .rotation]
    )
    
    // Use Task to perform the heavy computation
    return try await Task.detached(priority: .userInitiated) {
        let imageClassifierModel = try MLImageClassifier(
            trainingData: dataset,
            parameters: trainParameters
        )
        
        print("Model training done")
        return imageClassifierModel
    }.value
}

#endif
