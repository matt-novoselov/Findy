import SwiftUI

struct ObjectScanningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    
    @State private var cameraShutterToggle: Bool = false
    @State private var isObjectFocused: Bool = false
    @State private var isOnboardingActive: Bool = true

    var body: some View {
        var isCameraButtonActive: Bool {
            appViewModel.savedObject.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity && !isOnboardingActive
        }
        
        Color.clear
            // MARK: Focus box
            .background{
                FocusBoxParentView(isObjectFocused: $isObjectFocused)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        
            // MARK: Visual effects
            .overlay{
                CameraShutterView(isShutterActive: $cameraShutterToggle)
            }
            .overlay(alignment: .bottom){
                let amountOfPhotos = appViewModel.savedObject.takenPhotos.count
                Group{
                    if amountOfPhotos > 0 {
                        ProgressBarView()
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom))
                    }
                }
                
                .animation(.spring, value: amountOfPhotos)
            }
            .overlay(alignment: .bottomLeading){
                PhotoCollectionView()
                    .padding()
                    .padding(.bottom)
            }
            .allowsHitTesting(false)
        
            // MARK: Camera shutter button
            .overlay(alignment: .trailing){
                Group{
                    if isCameraButtonActive {
                        CameraShutterButton(cameraShutterToggle: $cameraShutterToggle, isObjectFocused: isObjectFocused)
                    }
                }
                .padding()
                .transition(.move(edge: .trailing))
                .animation(.spring, value: isCameraButtonActive)
                
                .onChange(of: isCameraButtonActive){
                    if isCameraButtonActive == false{
                        appViewModel.isTrainingCoverPresented = true
                    }
                }
            }
        
            .toolbar(isOnboardingActive ? .hidden : .visible, for: .tabBar)
        
            .overlay{
                Group{
                    if isOnboardingActive{
                        OnboardingAlertView(card: ObjectScanViewModel(action: {
                            isOnboardingActive = false
                        }).card)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    }
                }
                .animation(.spring, value: isOnboardingActive)
            }
    }
}
