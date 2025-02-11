import SwiftUI
import Vision
#if canImport(CreateML)
import CreateML
#endif

struct ModelTrainingView: View {
    @Binding var isTrainingCoverPresented: Bool
    
    init(isTrainingCoverPresented: Binding<Bool>) {
        self._isTrainingCoverPresented = isTrainingCoverPresented
    }
    
    @Environment(AppViewModel.self) private var appViewModel
    @State private var shouldAnimate = false
    @State private var scaleOverTime = false
    @State private var isProcessingComplete = false
    @State private var showCheckmark = false
    @State private var animateCheckmark = false
    @State private var isAnimationFinishedFinal: Bool = false
    
    // MARK: Meet requirement
    @State private var hasBaseAnimationFinished = false
    @State private var hasModelTrainingFinished = false
    private var isWrappingUpAnimations: Bool {
        return hasBaseAnimationFinished && hasModelTrainingFinished
    }
    
    private let gridColumns = Array(repeating: GridItem(.fixed(100)), count: 3)
    
#if canImport(CreateML)
    private var imageClassifierTrainer = ImageClassifierTrainer()
#endif
    
    var body: some View {
        ZStack {
            checkmarkView
            imageGridView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            AnimatedBackgroundView()
        }
        

        .overlay(alignment: .bottom){
            Group{
                #if canImport(CreateML)
                if isAnimationFinishedFinal  {
                    Button("Search for item"){
                        isTrainingCoverPresented = false
                        appViewModel.state = .searching
                    }
                    .animation(.spring, value: isAnimationFinishedFinal)
                }
                #endif
                
                if !shouldAnimate {
                    Button("Train AI Model"){
                        startModelTraining()
                    }
                    .animation(.spring, value: shouldAnimate)
                }
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .foregroundStyle(.white)
            .transition(.move(edge: .bottom).combined(with: .blurReplace).combined(with: .scale(0.5, anchor: .bottom)))
        }
        
        .onChange(of: isWrappingUpAnimations){
            wrapUpAnimations()
        }
    }
    
    private func startModelTraining() {
        startAnimations()
        
        Task {
            let takenPhotos = appViewModel.savedObject.takenPhotos
            // Calculate average label (sync operation)
            let averageLabel = average(of: takenPhotos.compactMap { $0.processedObservation.label })
            
            await MainActor.run {
                appViewModel.savedObject.targetDetectionObject = averageLabel
            }
            
            // Crop photos in parallel
            let croppedPhotos = await withTaskGroup(of: UIImage?.self) { group in
                for takenPhoto in takenPhotos {
                    group.addTask {
                        let photo: CGImage = takenPhoto.photo
                        let observation = takenPhoto.processedObservation
                        let boundingBox = observation.boundingBox
                        return UIImage(cgImage: cropImage(photo, to: boundingBox)!)
                    }
                }
                
                var results = [UIImage]()
                for await cropped in group {
                    if let cropped {
                        results.append(cropped)
                    }
                }
                return results
            }
            
            func cropImage(_ image: CGImage, to rect: CGRect) -> CGImage? {
                guard rect.size.width > 0, rect.size.height > 0 else { return nil }
                return image.cropping(to: rect)
            }
            
            // Start model loading in parallel with other tasks
            Task {
                loadImageClassifier(with: croppedPhotos)
            }
            
            // Parallel aesthetic scoring
            let aestheticScores = await withTaskGroup(of: (UIImage, ImageAestheticsScoresObservation?).self) { group in
                for photo in croppedPhotos {
                    group.addTask {
                        let score = try? await calculateAestheticsScore(image: photo)
                        return (photo, score)
                    }
                }
                
                // Collect results using async sequence instead of reduce
                var results = [(UIImage, ImageAestheticsScoresObservation?)]()
                for await result in group {
                    results.append(result)
                }
                return results
            }
            
            // Find most beautiful photo
            guard let mostBeautiful = aestheticScores.max(by: {
                ($0.1?.overallScore ?? 0) < ($1.1?.overallScore ?? 0)
            })?.0 else { return }
            
            // In an async context
            do {
                let resultImage: UIImage = try await removeBackground(from: mostBeautiful)
                // Use the resulting image with transparent background
                appViewModel.savedObject.objectCutOutImage = resultImage
            } catch {
                print("Background removal failed: \(error)")
            }
            
            
            // Parallel classification and filtering
            async let classifications = try? classify(mostBeautiful)
            let filtered = await filterIdentifiers(from: classifications ?? [])
            
            appViewModel.savedObject.visionClassification = filtered
        }
        
        self.hasModelTrainingFinished = true
    }
    
    func average(of labels: [String]) -> String? {
        guard !labels.isEmpty else { return nil }
        
        var frequencyDict = [String: Int]()
        
        // Count occurrences of each label
        for label in labels {
            frequencyDict[label] = (frequencyDict[label] ?? 0) + 1
        }
        
        // Find the maximum frequency
        guard let maxCount = frequencyDict.values.max() else { return nil }
        
        // Get all labels with maximum frequency
        let mostFrequent = frequencyDict.filter { $0.value == maxCount }.map { $0.key }
        
        // Return the first one in case of tie
        return mostFrequent.first
    }
    
    
    // MARK: - Helper Functions
    private func calculateAestheticsScore(image: UIImage) async throws -> ImageAestheticsScoresObservation? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let request = CalculateImageAestheticsScoresRequest()
        return try await request.perform(on: ciImage)
    }
    
    private func classify(_ image: UIImage) async throws -> [ClassificationObservation]? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let request = ClassifyImageRequest()
        return try await request.perform(on: ciImage)
    }
    
    private func filterIdentifiers(from observations: [ClassificationObservation]) -> [String] {
        observations.filter { $0.confidence > 0.1 }.map(\.identifier)
    }
    
    private func wrapUpAnimations() {
        withAnimation(.easeOut(duration: 3)) {
            isProcessingComplete = true
            scheduleCheckmarkAnimation()
        } completion: {
            isAnimationFinishedFinal = true
        }
    }
    
    // MARK: - Subviews
    private var checkmarkView: some View {
        Group {
            if showCheckmark, let photoCutout = appViewModel.savedObject.objectCutOutImage {
                Image(uiImage: photoCutout)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .symbolEffect(.bounce, value: animateCheckmark)
                    .symbolEffect(.pulse, value: animateCheckmark)
                    .foregroundStyle(.white)
                    .brightness(animateCheckmark ? 0 : 1)
                    .contrast(animateCheckmark ? 1 : 10)
                    .shadow(color: .white.opacity(0.8), radius: animateCheckmark ? 0 : 30)
            }
        }
    }
    
    private var imageGridView: some View {
        LazyVGrid(columns: gridColumns, spacing: 5) {
            ForEach(0..<9, id: \.self) { _ in
                if shouldAnimate && !appViewModel.savedObject.takenPhotos.isEmpty {
                    AnimatedImageCell()
                        .blur(radius: isProcessingComplete ? 20 : 0)
                }
            }
        }
        .scaleEffect(scaleOverTime ? 1.5 : 1)
        .scaleEffect(showCheckmark ? 0 : 1)
        .brightness(isProcessingComplete ? 1 : 0)
        .contrast(isProcessingComplete ? 2 : 1)
        .shadow(color: .white, radius: isProcessingComplete ? 100 : 0)
        .opacity(showCheckmark ? 0 : 1)
    }
    
    // MARK: - Actions
    private func startAnimations() {
        withAnimation {
            shouldAnimate.toggle()
        } completion: {
            withAnimation(.easeOut(duration: 10)) {
                scaleOverTime = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                hasBaseAnimationFinished = true
            }
        }
    }
    
    private func scheduleCheckmarkAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCheckmark = true
            } completion: {
                withAnimation(.spring(duration: 3)) {
                    animateCheckmark = true
                }
            }
        }
    }
    
    private func loadImageClassifier(with customImages: [UIImage] ) {
        Task {
            do {
#if canImport(CreateML)
                appViewModel.savedObject.imageClassifier = try await imageClassifierTrainer.train(on: customImages)
                print("✅ Model training done")
#endif
            } catch {
                print("Classifier training failed: \(error)")
            }
        }
    }
}


import Vision
import CoreImage
import UIKit
import CoreImage.CIFilterBuiltins

enum BackgroundRemovalError: Error {
    case ciImageConversionFailed
    case maskGenerationFailed
    case maskApplicationFailed
    case cgImageConversionFailed
}

func removeBackground(from image: UIImage) async throws -> UIImage {
    try await Task.detached(priority: .userInitiated) {
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            throw BackgroundRemovalError.ciImageConversionFailed
        }
        
        // Generate foreground mask using Vision
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try handler.perform([request])
        
        guard let result = request.results?.first else {
            throw BackgroundRemovalError.maskGenerationFailed
        }
        
        // Create scaled mask
        let maskPixelBuffer = try result.generateScaledMaskForImage(
            forInstances: result.allInstances,
            from: handler
        )
        let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        
        // Apply mask to original image
        let filter = CIFilter.blendWithMask()
        filter.inputImage = ciImage
        filter.maskImage = maskImage
        filter.backgroundImage = CIImage.empty()
        
        guard let outputCIImage = filter.outputImage else {
            throw BackgroundRemovalError.maskApplicationFailed
        }
        
        // Convert CIImage to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            throw BackgroundRemovalError.cgImageConversionFailed
        }
        
        return UIImage(cgImage: cgImage)
    }.value
}
