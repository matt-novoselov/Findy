import SwiftUI

struct ObjectScanningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var cameraShutterToggle: Bool = false
    @State private var isTrainingCoverPresented: Bool = false
    
    var body: some View {
        let isCameraButtonActive: Bool = appViewModel.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity
        
        Color.clear
            // MARK: Focus box
            .background{
                FocusBoxParentView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        
            // MARK: Visual effects
            .overlay{
                CameraShutterView(isShutterActive: $cameraShutterToggle)
                PhotoCollectionView()
            }
            .allowsHitTesting(false)
        
            // MARK: Camera shutter button
            .overlay{
                Group{
                    if isCameraButtonActive {
                        CameraShutterButton(cameraShutterToggle: $cameraShutterToggle)
                            .disabled(appViewModel.isAnyObjectDetected ? false : true)
                            .opacity(appViewModel.isAnyObjectDetected ? 1 : 0.2)
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
                ModelTrainingView()
            }
    }
}
