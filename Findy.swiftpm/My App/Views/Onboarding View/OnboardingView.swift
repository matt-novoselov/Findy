import SwiftUI


struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    let content = OnboardingContent()
    
    @State private var currentIndex: Int = -1
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
                Group{
                    if currentIndex >= 0 && currentIndex != 4 {
                        OnboardingTextView(text: content.texts[currentIndex])
                            .padding(.all, 40)
                            .transition(.opacity)
                    }
                }
                .animation(.spring(duration: 2), value: currentIndex >= 0)
            }
        
        // Welcome to Findy overlay
            .overlay {
                Group{
                    if currentIndex == 4 {
                        WelcomeToFindyView()
                    }
                }
                .animation(.spring(duration: 2), value: currentIndex >= 0)
            }
        
        // Tap to continue overlay (only when not last)
            .overlay(alignment: currentIndex == -1 ? .center : .bottom) {
                if !isLastIndex {
                    OnboardingTapToContinueView()
                        .animation(.spring(duration: 1.5), value: currentIndex == -1)
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
                        finishOnboarding()
                    }
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 20)
                }
            }
        
        // Skip button overlay (only when not last)
            .overlay(alignment: .topTrailing) {
                if !isLastIndex {
                    OnboardingSkipButtonView {
                        finishOnboarding()
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
    
    private func finishOnboarding(){
        appViewModel.state = .scanning
        appViewModel.shouldBlurScreenOnboarding = false
    }
    
    private func advance() {
        if !isLastIndex {
            withAnimation { currentIndex += 1 }
        } else {
            finishOnboarding()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppViewModel())
}
