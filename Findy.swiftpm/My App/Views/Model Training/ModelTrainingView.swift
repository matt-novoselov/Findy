import SwiftUI
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
    
    var body: some View {
        VStack {
            ZStack {
                checkmarkView
                imageGridView
            }
            
            Button("Try to find an item"){
                isTrainingCoverPresented = false
                appViewModel.state = .searching
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            AnimatedBackgroundView()
        }
        .task {
            loadImageClassifier()
        }
        .onAppear(perform: startAnimations)
        .onChange(of: isWrappingUpAnimations){
            wrapUpAnimations()
        }
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
            if showCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 120))
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
    
//    private var predictionButton: some View {
//        Button("Predict") {
//            #if canImport(CreateML)
//            guard let image = appViewModel.lastCroppedImage else { return }
//            let prediction = try? appViewModel.imageClassifier?.prediction(from: image)
//            print(prediction?.debugDescription ?? "N/A predicton")
//            #endif
//        }
//    }
    
    // MARK: - Actions
    private func startAnimations() {
        withAnimation {
            shouldAnimate.toggle()
        } completion: {
            withAnimation(.easeOut(duration: 10)) {
                scaleOverTime = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
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
    
    private func loadImageClassifier() {
        Task {
            do {
                #if canImport(CreateML)
                appViewModel.savedObject.imageClassifier = try await imageClassifierTrainer.train()
                self.hasModelTrainingFinished = true
                #endif
            } catch {
                print("Classifier training failed: \(error)")
            }
        }
    }
}
