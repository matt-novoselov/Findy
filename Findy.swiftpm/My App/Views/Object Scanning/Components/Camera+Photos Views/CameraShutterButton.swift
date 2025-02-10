import SwiftUI
import AVFoundation

struct CameraShutterButton: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Binding var cameraShutterToggle: Bool
    
    var body: some View {
        Button(action: {takePhoto()}) {
            Circle()
                .fill(.white)
                .frame(width: 55, height: 55)
        }
        .buttonStyle(ShutterButtonStyle())
        
        // Outer ring
        .overlay{
            Circle()
                .stroke(.white, lineWidth: 5)
                .frame(width: 70, height: 70)
        }
    }
    
    func takePhoto(){
        // Play shutter animation
        cameraShutterToggle.toggle()
        
        // Play shutter sound
        let shutterSoundID: SystemSoundID = 1108
        AudioServicesPlaySystemSound(shutterSoundID)
        
        if appViewModel.takenPhotos.count < AppMetrics.maxPhotoArrayCapacity {
            if let capturedImage = arCoordinator.processedFrameImage?.toCGImage() {
                appViewModel.takenPhotos.append(capturedImage)
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
