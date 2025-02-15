import SwiftUI

struct ModelTrainingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var shouldAnimate = false
    @State private var scaleOverTime = false
    @State private var isProcessingComplete = false
    @State private var showCheckmark = false
    @State private var animateCheckmark = false
    @State private var isAnimationFinishedFinal: Bool = false
    @State private var isViewActive: Bool = true
    
    // Animation tracking requirements.
    @State private var hasBaseAnimationFinished = false
    @State private var hasModelTrainingFinished = false
    private var isWrappingUpAnimations: Bool {
        return hasBaseAnimationFinished && hasModelTrainingFinished
    }
    
    private let gridColumns = Array(repeating: GridItem(.fixed(100)), count: 3)
    
    private let coordinator = ModelTrainingCoordinator()
    
    var body: some View {
        ZStack {
            VStack {
                cutOutObjectView
                
                if isAnimationFinishedFinal {
                    ObjectTagsPickerView()
                    ImagePlaygroundView()
                }
            }
            .padding()
            
            if isViewActive{
                imageGridView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AnimatedBackgroundView())
        .overlay(alignment: .bottom){
            if isAnimationFinishedFinal{
                CandyStyledButton(title: "Search for the item", symbol: "magnifyingglass", action: {
                    isViewActive = false
                    appViewModel.isTrainingCoverPresented = false
                    appViewModel.state = .searching
                })
                .padding()
                .animation(.spring, value: isAnimationFinishedFinal)
            }
        }
        .overlay {
            if !shouldAnimate {
                CandyStyledButton(title: "Train AI Model", symbol: "sparkles", action: startModelTraining)
                    .animation(.spring, value: shouldAnimate)
            }
        }
        .onChange(of: isWrappingUpAnimations) {
            wrapUpAnimations()
        }
    }
    
    private func startModelTraining() {
        // Start UI animations.
        startAnimations()
        
        // Start the training sequence.
        Task {
            do {
                let result = try await coordinator.runTraining(
                    with: appViewModel.savedObject.takenPhotos)
                
                await MainActor.run {
                    appViewModel.savedObject.objectCutOutImage = result.objectCutOutImage
                    appViewModel.savedObject.targetDetectionObject = result.averageLabel
                    appViewModel.savedObject.visionClassifications = result.visionClassifications
                    #if canImport(CreateML)
                    appViewModel.savedObject.imageClassifier = result.trainedModel
                    #endif
                }
            } catch {
                print("Training failed: \(error)")
            }
        }
        hasModelTrainingFinished = true
    }
    
    /// Start animations and schedule their “completion” via DispatchQueue.
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
    
    private func wrapUpAnimations() {
        withAnimation(.easeOut(duration: 3)) {
            isProcessingComplete = true
        } completion: {
            isAnimationFinishedFinal = true
        }
        scheduleCheckmarkAnimation()
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
    
    // MARK: - Subviews
    private var cutOutObjectView: some View {
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
}
