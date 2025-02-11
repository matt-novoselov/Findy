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
                    .bold()
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.white)
        }
        .blur(radius: isBlurred ? 10 : 0)
        .padding(.all, 20)
        .background(Material.thin, in: .capsule)
        .clipShape(.capsule)
        .onAppear {
            withAnimation(.spring(duration: 0.4)) { }
        }
        .onChange(of: notification.id){
            withAnimation{
                self.isBlurred = true
            } completion: {
                self.isBlurred = false
            }
        }
    }
}
