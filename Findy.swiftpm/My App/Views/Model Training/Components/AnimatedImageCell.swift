import SwiftUI

struct AnimatedImageCell: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var currentImageIndex: Int?
    @State private var isScaled = false
    @State private var initialOffsetX: CGFloat = 1000
    @State private var initialOffsetY: CGFloat = 1000
    @State private var initialBlur: CGFloat = 100
    @State private var hasGradientOverlay = false
    @State private var animationTask: Task<Void, Never>?
    @State private var animationRotationDegrees: Double = 0
    
    private var capturedPhotos: [CapturedPhoto] { appViewModel.savedObject.takenPhotos }
    
    var body: some View {
        let cgImage = capturedPhotos[currentImageIndex ?? randomImageIndex].photo
        let uiImage = UIImage(cgImage: cgImage)
        
        Image(uiImage: uiImage)
            .resizable()
            .brightness(isScaled ? 0.5 : 0)
            .scaleEffect(isScaled ? 1.2 : 1.0)
            .scaledToFill()
            .overlay(gradientOverlay)
            .frame(width: 100, height: 100)
            .blur(radius: isScaled ? 5 : 0)
            .clipShape(.rect(cornerRadius: 10))
            .rotationEffect(.degrees(animationRotationDegrees))
            .offset(x: initialOffsetX, y: initialOffsetY)
            .blur(radius: initialBlur)
            .accessibilityHidden(true)
            .onAppear(perform: setupInitialAnimation)
            .onDisappear { animationTask?.cancel() }
            .onAppear{
                withAnimation(.linear(duration: 15)){
                    animationRotationDegrees = -90
                }
            }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [.pink, .red]),
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(hasGradientOverlay ? 0 : 1)
    }
    
    private var randomImageIndex: Int { Int.random(in: 0..<capturedPhotos.count) }
    
    private func setupInitialAnimation() {
        initialOffsetX *= Bool.random() ? -1 : 1
        initialOffsetY *= Bool.random() ? -1 : 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
            withAnimation(.spring(duration: 1)) {
                initialOffsetX = 0
                initialOffsetY = 0
            }
            
            withAnimation(.spring(duration: 1.5)) {
                initialBlur = 0
                hasGradientOverlay = true
            } completion: {
                startImageAnimationCycle()
            }
        }
    }
    
    private func startImageAnimationCycle() {
        animationTask = Task {
            while !Task.isCancelled {
                let delay = Double.random(in: 0...1.5)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                animateImageTransition()
            }
        }
    }
    
    private func animateImageTransition() {
        withAnimation(.spring) {
            isScaled = true
        } completion: {
            currentImageIndex = Int.random(in: 0..<capturedPhotos.count)
            withAnimation(.spring) {
                isScaled = false
            }
        }
    }
}
