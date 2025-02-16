import SwiftUI
import AVFoundation

// A simple model to track each ripple's position.
struct Ripple: Identifiable {
    let id = UUID()
    let position: CGPoint
}

struct RippleEffectView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @State private var ripples: [Ripple] = []
    var objectDetected: Bool

    /// Function to trigger a ripple effect at the given screen position.
    func triggerRipple(at position: CGPoint) {
        let newRipple = Ripple(position: position)
        ripples.append(newRipple)
        
        // Remove the ripple after the duration of the animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                ripples.removeAll { $0.id == newRipple.id }
            }
        }
    }

    var body: some View {
        ZStack {
            // Draw each ripple.
            ForEach(ripples) { ripple in
                RippleView(position: ripple.position)
            }
        }
        .onChange(of: arCoordinator.objectDetectedAtPosition) {
            if let pos = arCoordinator.objectDetectedAtPosition {
                triggerRipple(at: pos)
            }
        }
    }
}

struct RippleView: View {
    let position: CGPoint
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(Color.green.opacity(0.7))
            // Starting small.
            .frame(width: 20, height: 20)
            .overlay{
                Circle()
                    .strokeBorder(.white, style: .init(lineWidth: 2))
                    .padding(.all, 2)
                
                Circle()
                    .strokeBorder(.white, style: .init(lineWidth: 2))
                    .padding(.all, animate ? 0 : 6)
                
                Circle()
                    .fill(Color.white)
                    .padding(.all, animate ? 0 : 10)
            }
        
        
            .scaleEffect(animate ? 100 : 0.1)
            .position(position)
            .blur(radius: animate ? 60 : 100)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animate = true
                }
                
                playSound()
            }
    }
    
    private func playSound(){
        let successSound: SystemSoundID = 1112
        AudioServicesPlaySystemSound(successSound)
    }
}
