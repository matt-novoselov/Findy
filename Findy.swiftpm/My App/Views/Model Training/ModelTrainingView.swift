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
    
    //////////
    @State private var croppedPhotos: [URL]?
    @State private var mostBeautifulPhoto: UIImage?
    @State private var mostBeautifulPhotoCutout: UIImage?
    //////////
    
    var body: some View {
        VStack {
            ZStack {
                checkmarkView
                imageGridView
            }
            
            if appViewModel.savedObject.imageClassifier != nil {
                Button("Search for item"){
                    isTrainingCoverPresented = false
                    appViewModel.state = .searching
                }
            }
            
            Button("Train AI Model"){
                startModelTraining()
            }
            
            HStack{
                VStack {
                    ForEach(appViewModel.savedObject.takenPhotos, id: \.photo) { takenPhoto in
                        Text(takenPhoto.processedObservation.label)
                    }
                }
                
                if let croppedPhotos = self.croppedPhotos {
                    VStack {
                        ForEach(
                            croppedPhotos.enumerated().map { ($0.offset, $0.element) },
                            id: \.0
                        ) { _, croppedPhoto in
                            AsyncImage(url: croppedPhoto) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure:
                                    Text("No image")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 100)
                        }
                    }
                }
                
                
                if let mostBeautifulPhoto = self.mostBeautifulPhoto {
                    Image(uiImage: mostBeautifulPhoto)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
                
                if let mostBeautifulPhotoCutout = self.mostBeautifulPhotoCutout {
                    Image(uiImage: mostBeautifulPhotoCutout)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
                
                if let classifications = appViewModel.savedObject.visionClassification {
                    VStack {
                        ForEach(classifications, id: \.self) { classification in
                            Text(classification)
                        }
                    }
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            AnimatedBackgroundView()
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
            print("✅ Average label: \(averageLabel)")
            await MainActor.run {
                appViewModel.savedObject.targetDetectionObject = averageLabel
            }
            
            // Crop photos in parallel
            let croppedPhotos = await withTaskGroup(of: UIImage?.self) { group in
                for takenPhoto in takenPhotos {
                    group.addTask{
                        let photo: CGImage = takenPhoto.photo
                        let observation = takenPhoto.processedObservation
                        let boundingBox = observation.boundingBox
                        return UIImage(cgImage: cropImage(photo, to: boundingBox)!)
                    }
                }
                
                return await group.reduce(into: [UIImage]()) { partialResult, cropped in
                    if let cropped { partialResult.append(cropped) }
                }
            }
            
            func cropImage(_ image: CGImage, to rect: CGRect) -> CGImage? {
                guard rect.size.width > 0, rect.size.height > 0 else { return nil }
                return image.cropping(to: rect)
            }
            
            print("✅ Cropped photos in parallel")
            
            // Start model loading in parallel with other tasks
            Task {
                loadImageClassifier(with: croppedPhotos)
            }
            
            self.croppedPhotos = getImageURLs(from: croppedPhotos)
            
            // Parallel aesthetic scoring
            let aestheticScores = await withTaskGroup(of: (UIImage, ImageAestheticsScoresObservation?).self) { group in
                for photo in croppedPhotos {
                    group.addTask {
                        let score = try? await calculateAestheticsScore(image: photo)
                        return (photo, score)
                    }
                }
                
                return await group.reduce(into: [(UIImage, ImageAestheticsScoresObservation?)]()) { partialResult, result in
                    partialResult.append(result)
                }
            }
            
            print("✅ aesthetic scored")
            
            // Find most beautiful photo
            guard let mostBeautiful = aestheticScores.max(by: {
                ($0.1?.overallScore ?? 0) < ($1.1?.overallScore ?? 0)
            })?.0 else { return }
            
            print("✅ most beautiful photo selected")
            self.mostBeautifulPhoto = mostBeautiful
            
            // In an async context
            do {
                let resultImage = try await removeBackground(from: mostBeautiful)
                // Use the resulting image with transparent background
                self.mostBeautifulPhotoCutout = resultImage
                print("✅ backgropund removed")
            } catch {
                print("Background removal failed: \(error)")
            }

            
            // Parallel classification and filtering
            async let classifications = try? classify(mostBeautiful)
            let filtered = await filterIdentifiers(from: classifications ?? [])
            
            print("✅ most beautiful photo classified")
            print(dump(filtered))
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
        }
    }
    
    // MARK: - Subviews
    private var checkmarkView: some View {
        Group {
            if showCheckmark, let mostBeautifulPhotoCutout {
                Image(uiImage: mostBeautifulPhotoCutout)
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
