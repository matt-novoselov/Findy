import SwiftUI

struct ObjectScanningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    
    @State private var cameraShutterToggle: Bool = false
    @State private var isObjectFocused: Bool = false
    @State private var isOnboardingActive: Bool = true

    var body: some View {
        var isCameraButtonActive: Bool {
            appViewModel.savedObject.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity && !isOnboardingActive
        }
        
        let amountOfPhotos = appViewModel.savedObject.takenPhotos.count
        
        Color.clear
            // MARK: Focus box
            .background{
                FocusBoxParentView(isObjectFocused: $isObjectFocused)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        
            // MARK: Visual effects
            .overlay{
                CameraFlashlightView(isShutterActive: $cameraShutterToggle)
            }
        
            // MARK: Progress bar
            .overlay(alignment: .bottom){
                Group{
                    if amountOfPhotos > 0 {
                        ProgressBarView()
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom))
                    }
                }
                
                .animation(.spring, value: amountOfPhotos)
            }
        
            // MARK: Photo Collection
            .overlay(alignment: .bottomLeading){
                PhotoCollectionView()
                    .padding()
                    .padding(.bottom)
            }
            .allowsHitTesting(false)
        
            // MARK: Camera shutter button
            .overlay{
                CameraShutterButtonContainerView(isCameraButtonActive: isCameraButtonActive, cameraShutterToggle: $cameraShutterToggle, isObjectFocused: $isObjectFocused)
            }
        
            .overlay(alignment: .trailing){
                CameraTipView(isOnboardingActive: isOnboardingActive)
            }
        
            .toolbar((!isOnboardingActive && amountOfPhotos > 0) ? .visible : .hidden, for: .tabBar)
        
            .overlay{
                Group{
                    if isOnboardingActive{
                        OnboardingAlertView(card: ObjectScanViewModel(action: {
                            isOnboardingActive = false
                            speechSynthesizer.speak(text: SSPrompts.captureFirstItem)
                        }).card)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    }
                }
                .animation(.spring, value: isOnboardingActive)
            }
        
            .onChange(of: appViewModel.savedObject.takenPhotos.count){
                let newValue = appViewModel.savedObject.takenPhotos.count
                if newValue == 1 {
                    speechSynthesizer.speak(text: SSPrompts.trainAI)
                } else if newValue == AppMetrics.maxPhotoArrayCapacity / 2 {
                    speechSynthesizer.speak(text: SSPrompts.halfway)
                }
            }
    }
}
