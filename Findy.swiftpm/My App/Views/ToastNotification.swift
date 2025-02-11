import SwiftUI

// MARK: - Toast Notification Model

struct ToastNotification: Identifiable {
    /// A unique identifier (for duplicate prevention).
    let id: UUID = .init()
    let title: String
    let message: String
    let iconName: String
}

// MARK: - Toast Templates
enum ToastTemplates {
    static let objectNotDetected = ToastNotification(
        title: "Couldn't detect the object",
        message: "Try adjusting it or picking another one!",
        iconName: "viewfinder.trianglebadge.exclamationmark"
    )
    
    static let lowLightDetected = ToastNotification(
        title: "Low Light Detected",
        message: "Try increasing the lighting for better results.",
        iconName: "lightbulb.min.badge.exclamationmark.fill"
    )
}

// MARK: - Toast Manager
@Observable
final class ToastManager {
    /// The currently displayed notification, if any.
    var currentNotification: ToastNotification? = nil
    private var dismissWorkItem: DispatchWorkItem?
    
    /// Shows a new toast if one of the same type isn’t already visible.
    func showToast(_ notification: ToastNotification) {
        // If the same notification is already displayed, do nothing.
        if currentNotification?.id == notification.id {
            return
        }
        
        // Cancel any existing dismissal work item.
        dismissWorkItem?.cancel()
        currentNotification = notification
        
        // Schedule auto-dismiss if the criteria are met.
        scheduleDismissal(for: notification)
    }
    
    /// Hides the toast using an outward animation.
    func hideToast() {
        dismissWorkItem?.cancel()
        withAnimation(.spring(duration: 1.8)) {
            self.currentNotification = nil
        }
    }
    
    /// Schedules dismissal unless the combined text is long or an action is present.
    private func scheduleDismissal(for notification: ToastNotification) {
        let combinedText = notification.title + " " + notification.message
        
        // Calculate a display duration based on word count (minimum 5 seconds).
        let wordCount = combinedText
            .split { $0.isWhitespace || $0.isNewline }
            .count
        let timeout = max(5.0, Double(wordCount) * 0.5)
        
        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 1.8)) {
                self?.currentNotification = nil
            }
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout,
                                      execute: workItem)
    }
}

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

// MARK: - Toast Container
/// A container overlay for your application’s content along with a toast.
struct ToastContainer<Content: View>: View {
    @Environment(ToastManager.self) var toastManager
    let content: () -> Content
    @State private var displayedNotification: ToastNotification?
    
    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top){
                let isVisible: Bool = toastManager.currentNotification != nil
                
                Group{
                    if isVisible, (displayedNotification != nil){
                        ToastView(notification: displayedNotification!, onDismiss: {
                            toastManager.hideToast()
                        })
                        .zIndex(1)
                        .transition(.move(edge: .top).combined(with: .blurReplace))
                    }
                }
                .animation(.spring, value: isVisible)
                .onChange(of: toastManager.currentNotification?.id){
                    withAnimation{
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
