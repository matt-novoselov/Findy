import SwiftUI
import AVFoundation

struct CameraShutterButton: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(ToastManager.self) var toastManager
    @Binding var cameraShutterToggle: Bool
    var isObjectFocused: Bool
    private let tip = CameraButtonTip()
    
    var body: some View {
        Button(action: {
            tip.invalidate(reason: .actionPerformed)
            if isObjectFocused{
                takePhoto()
            } else {
                toastManager.showToast(ToastTemplates.objectNotDetected)
            }
        }) {
            Circle()
                .fill(.white.opacity(isObjectFocused ? 1 : 0.2))
                .frame(width: 55, height: 55)
        }
        .buttonStyle(ShutterButtonStyle())
        
        // MARK: Tip
        .popoverTip(
            self.tip
        )
        .tipImageStyle(Color.secondary)
        
        // Outer ring
        .overlay{
            Circle()
                .stroke(.white.opacity(isObjectFocused ? 1 : 0.2), lineWidth: 5)
                .frame(width: 70, height: 70)
        }
    }
    
    func takePhoto(){
        // Play shutter sound
        let shutterSoundID: SystemSoundID = 1108
        AudioServicesPlaySystemSound(shutterSoundID)
        
        let amountOfPhotos = appViewModel.savedObject.takenPhotos.count
        if amountOfPhotos < AppMetrics.maxPhotoArrayCapacity {
            if let capturedImage = arCoordinator.processedFrameImage?.toCGImage() {
                let detectedObjects = arCoordinator.detectedObjects
                
                guard let mostProminentResult = selectDominantObservation(from: detectedObjects) else {return}
                
                let capturedPhoto = CapturedPhoto(
                    photo: capturedImage,
                    processedObservation: mostProminentResult
                )
                appViewModel.savedObject.takenPhotos.append(capturedPhoto)
                
                if appViewModel.savedObject.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity {
                    // Play flashlight animation
                    cameraShutterToggle.toggle()
                }
            }
        }
    }
}

struct ShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                Circle()
                    .fill(.white.opacity(configuration.isPressed ? 0.2 : 0))
                    .frame(width: 65, height: 65)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
