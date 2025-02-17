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
    @State private var circleRadius: CGFloat = 130.0
    
    // Animation tracking requirements.
    @State private var hasBaseAnimationFinished = false
    @State private var hasModelTrainingFinished = false
    private var isWrappingUpAnimations: Bool {
        return hasBaseAnimationFinished && hasModelTrainingFinished
    }
    
    private let coordinator = ModelTrainingCoordinator()
    
    var body: some View {
        VStack {
            // MARK: Variable font animation
            if isAnimationFinishedFinal {
                VariableFontAnimationView()
                    .padding(.top)
            }
            
            Spacer()
            
            // MARK: Image cut out
            Group{
                if appViewModel.savedObject.appleIntelligencePreviewImage != nil {
                    if let url = appViewModel.savedObject.appleIntelligencePreviewImage {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .clipShape(.rect(cornerRadius: 20))
                        } placeholder: {
                            ProgressView()
                        }
                    }
                } else {
                    cutOutObjectView
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: isAnimationFinishedFinal ? .infinity : 150)
            .animation(.spring, value: isAnimationFinishedFinal)
            .scaledToFit()
            .padding(40)
            
            Spacer()
            
            // MARK: Scroll View
            if isAnimationFinishedFinal {
                Group{
                    NameInputFieldView()
                    
                    ObjectTagsPickerView()
                    
                    ImagePlaygroundView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .separatorBackground()
                
                // MARK: Candy button
                let givenObjectName = appViewModel.savedObject.userGivenObjectName
                let itemName = givenObjectName.isEmpty ? "item" : givenObjectName
                
                CandyStyledButton(title: "Search for the \(itemName)", symbol: "magnifyingglass", action: {
                    isViewActive = false
                    appViewModel.isTrainingCoverPresented = false
                    appViewModel.state = .searching
                })
                .padding(.top)
                .animation(.spring, value: isAnimationFinishedFinal)
            }
        }
        .padding(.all, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassBackground(cornerRadius: getDeviceBasedCornerRadius()-10)
        .overlay{
            if isViewActive{
                imageCircleView
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
        guard shouldAnimate == false else { return }
        
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
            shouldAnimate = true
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
        withAnimation(.easeIn(duration: 3)){
            circleRadius = 50
        }
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
                    .symbolEffect(.bounce, value: animateCheckmark)
                    .symbolEffect(.pulse, value: animateCheckmark)
                    .foregroundStyle(.white)
                    .brightness(animateCheckmark ? 0 : 1)
                    .contrast(animateCheckmark ? 1 : 10)
                    .shadow(color: .white.opacity(0.8), radius: animateCheckmark ? 0 : 30)
            }
        }
    }

    private var imageCircleView: some View {
        ZStack {
            ForEach(0..<9, id: \.self) { index in
                if shouldAnimate && !appViewModel.savedObject.takenPhotos.isEmpty {
                    let angle = 2 * Double.pi / 9.0 * Double(index)
                    AnimatedImageCell()
                        .blur(radius: isProcessingComplete ? 20 : 0)
                        .offset(
                            x: circleRadius * CGFloat(cos(angle)),
                            y: circleRadius * CGFloat(sin(angle))
                        )
                        .zIndex(Double(index)+10)
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
