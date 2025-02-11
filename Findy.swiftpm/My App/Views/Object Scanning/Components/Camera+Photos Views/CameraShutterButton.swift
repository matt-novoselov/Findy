import SwiftUI
import AVFoundation

struct CameraShutterButton: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Binding var cameraShutterToggle: Bool
    var isObjectFocused: Bool
    
    var body: some View {
        Button(action: {
            if isObjectFocused{
                takePhoto()
            } else {
                print("Object is not detected")
            }
        }) {
            Circle()
                .fill(.white.opacity(isObjectFocused ? 1 : 0.2))
                .frame(width: 55, height: 55)
        }
        .buttonStyle(ShutterButtonStyle())
        
        // Outer ring
        .overlay{
            Circle()
                .stroke(.white.opacity(isObjectFocused ? 1 : 0.2), lineWidth: 5)
                .frame(width: 70, height: 70)
        }
    }
    
    func takePhoto(){
        // Play shutter animation
        cameraShutterToggle.toggle()
        
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
