import SwiftUI

struct ObjectScanningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    
    @State private var cameraShutterToggle: Bool = false
    @State private var isObjectFocused: Bool = false
    
    var body: some View {
        let isCameraButtonActive: Bool = appViewModel.savedObject.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity
        
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
                ProgressBarView()
                    .padding(.horizontal)
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
    }
}
