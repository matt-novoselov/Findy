import SwiftUI

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
        // Cancel any existing dismissal work item.
        dismissWorkItem?.cancel()
        // Animate the hiding of the toast.
        withAnimation(.spring(duration: 1.8)) {
            self.currentNotification = nil
        }
    }
    
    /// Schedules dismissal unless the combined text is long or an action is present.
    private func scheduleDismissal(for notification: ToastNotification) {
        // Combine the title and message text.
        let combinedText = notification.title + " " + notification.message
        
        // Calculate a display duration based on word count (minimum 5 seconds).
        let wordCount = combinedText
            .split { $0.isWhitespace || $0.isNewline }
            .count
        let timeout = max(5.0, Double(wordCount) * 0.5)
        
        // Create a work item to dismiss the toast after the timeout.
        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 1.8)) {
                self?.currentNotification = nil
            }
        }
        dismissWorkItem = workItem
        // Schedule the work item to execute after the calculated timeout.
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout,
                                      execute: workItem)
    }
}
