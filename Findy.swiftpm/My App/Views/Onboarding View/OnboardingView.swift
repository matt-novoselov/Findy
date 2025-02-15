import SwiftUI


struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    let content = OnboardingContent()
    
    @State private var currentIndex: Int = 0
    private var isLastIndex: Bool { currentIndex == content.texts.count - 1 }
    
    var body: some View {
        Color.clear
            // Old Photo overlay (only on last screen)
            .overlay(alignment: .bottomLeading) {
                if isLastIndex {
                    OldPhotoView()
                        .transition(.move(edge: .leading).combined(with: .blurReplace))
                        .animation(.bouncy, value: isLastIndex)
                }
            }
        
            // Main text overlay
            .overlay {
                OnboardingTextView(text: content.texts[currentIndex])
            }
        
            // Tap to continue overlay (only when not last)
            .overlay(alignment: .bottom) {
                if !isLastIndex {
                    OnboardingTapToContinueView()
                }
            }
        
            // Tap area overlay to advance
            .overlay {
                Color.clear
                    .contentShape(.rect)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        advance()
                    }
            }
        
            // Start exploring button overlay (only on last screen)
            .overlay(alignment: .bottom) {
                if isLastIndex {
                    OnboardingStartButtonView {
                        appViewModel.state = .scanning
                    }
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 20)
                }
            }
        
            // Skip button overlay (only when not last)
            .overlay(alignment: .topTrailing) {
                if !isLastIndex {
                    OnboardingSkipButtonView {
                        appViewModel.state = .scanning
                    }
                    .transition(.move(edge: .trailing))
                }
            }
            .ignoresSafeArea()
        
            .toolbar(.hidden, for: .tabBar)
        
            .onChange(of: self.currentIndex){
                if currentIndex == 1 {
                    appViewModel.shouldBlurScreenOnboarding = true
                }
                
                if currentIndex == 3 {
                    appViewModel.shouldBlurScreenOnboarding = false
                }
            }
    }
    
    private func advance() {
        if !isLastIndex {
            withAnimation { currentIndex += 1 }
        } else {
            appViewModel.state = .scanning
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppViewModel())
}
