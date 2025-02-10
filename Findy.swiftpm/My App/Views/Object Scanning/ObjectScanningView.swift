import SwiftUI

struct ObjectScanningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var cameraShutterToggle: Bool = false
    @State private var isTrainingCoverPresented: Bool = false
    @State private var isAnyObjectDetected: Bool = false
    
    var body: some View {
        let isCameraButtonActive: Bool = appViewModel.savedObject.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity
        
        Color.clear
            // MARK: Focus box
            .background{
                FocusBoxParentView(isAnyObjectDetected: $isAnyObjectDetected)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        
            // MARK: Visual effects
            .overlay{
                CameraShutterView(isShutterActive: $cameraShutterToggle)
                ProgressBarView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal)
                PhotoCollectionView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                    .padding(.bottom)
            }
            .allowsHitTesting(false)
        
            // MARK: Camera shutter button
            .overlay{
                Group{
                    if isCameraButtonActive {
                        CameraShutterButton(cameraShutterToggle: $cameraShutterToggle)
                            .disabled(isAnyObjectDetected ? false : true)
                            .opacity(isAnyObjectDetected ? 1 : 0.2)
                    } else {
                        Button("Start Training"){
                            self.isTrainingCoverPresented = true
                        }
                    }
                }
                .padding()
                .transition(.move(edge: .trailing))
                .animation(.spring, value: isCameraButtonActive)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
        
            // MARK: Model Training View
            .fullScreenCover(isPresented: $isTrainingCoverPresented){
                ModelTrainingView(isTrainingCoverPresented: $isTrainingCoverPresented)
            }
    }
}
