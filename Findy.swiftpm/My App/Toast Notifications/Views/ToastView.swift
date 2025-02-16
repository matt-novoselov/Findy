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
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.body)
                    .fontDesign(.rounded)
                    .bold()
                
                Text(notification.message)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
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
        
        .onChange(of: notification.id){
            withAnimation{
                self.isBlurred = true
            } completion: {
                withAnimation{
                    self.isBlurred = false
                }
            }
        }
    }
}
