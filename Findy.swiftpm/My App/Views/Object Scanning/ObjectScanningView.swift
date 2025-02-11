import SwiftUI

struct ObjectScanningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var cameraShutterToggle: Bool = false
    @State private var isTrainingCoverPresented: Bool = false
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
                    } else {
                        Button("Start Training"){
                            self.isTrainingCoverPresented = true
                        }
                    }
                }
                .padding()
                .transition(.move(edge: .trailing))
                .animation(.spring, value: isCameraButtonActive)
            }
        
            // MARK: Model Training View
            .fullScreenCover(isPresented: $isTrainingCoverPresented){
                ModelTrainingView(isTrainingCoverPresented: $isTrainingCoverPresented)
            }
    }
}
