import SwiftUI

// MARK: - Toast View
struct ToastView: View {
    @Environment(ToastManager.self) var toastManager
    let notification: ToastNotification
    var onDismiss: () -> Void
    @State private var isBlurred: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: notification.iconName)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.secondary)
                .accessibilityHidden(true) // Marking the icon to be ignored by accessibility
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.body)
                    .fontDesign(.rounded)
                    .bold()
                    .accessibilityLabel("Notification Title")
                    .accessibilityHint(notification.title) // Provide the title as a hint
                
                Text(notification.message)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Notification Message")
                    .accessibilityHint(notification.message) // Provide the message as a hint
            }
            .foregroundColor(.white)
        }
        .blur(radius: isBlurred ? 10 : 0)
        .padding(.all, 20)
        .glassBackground(cornerRadius: .infinity)
        .clipShape(.capsule)
        
        .gesture(
            // Combine tap and swipe gestures
            SimultaneousGesture(
                TapGesture()
                    .onEnded {
                        toastManager.hideToast()
                    },
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height < 0 {
                            toastManager.hideToast()
                        }
                    }
            )
        )
        
        .onAppear {
            withAnimation(.spring(duration: 0.4)) { }
        }
        
        .onChange(of: notification.id) {
            withAnimation {
                self.isBlurred = true
            } completion: {
                withAnimation {
                    self.isBlurred = false
                }
            }
        }
        .accessibilityLabel("Toast Notification")
        .accessibilityHint("A notification with title: \(notification.title) and message: \(notification.message). Tap or swipe up to dismiss.")
    }
}
