import SwiftUI

// MARK: - Toast Container
/// A container overlay for your application’s content along with a toast.
struct ToastContainer<Content: View>: View {
    @Environment(ToastManager.self) var toastManager
    let content: () -> Content
    @State private var displayedNotification: ToastNotification?
    
    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                // Determine if the toast is visible.
                let isVisible: Bool = toastManager.currentNotification != nil
                
                // Conditionally display the toast view.
                Group {
                    if isVisible, let notification = displayedNotification {
                        ToastView(notification: notification, onDismiss: {
                            toastManager.hideToast()
                        })
                        .zIndex(1)
                        .transition(.move(edge: .top).combined(with: .blurReplace))
                        .accessibilityLabel("Toast Notification")
                        .accessibilityHint(notification.message)
                    }
                }
                .animation(.spring, value: isVisible)
                
                // Update the displayed notification when the current notification changes.
                .onChange(of: toastManager.currentNotification?.id) {
                    withAnimation {
                        displayedNotification = toastManager.currentNotification
                    }
                }
            }
    }
}

// MARK: - Preview for Testing
#Preview{
    @Previewable @State var toastManager = ToastManager()
    ToastContainer {
        VStack{
            Button("Show Toast") {
                toastManager.showToast(ToastTemplates.objectNotDetected)
            }
            
            Button("Show Toast 2") {
                toastManager.showToast(ToastTemplates.lowLightDetected)
            }
        }
    }
    .environment(toastManager)
}
