import SwiftUI

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
