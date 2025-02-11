import SwiftUI

// MARK: - Toast Templates
enum ToastTemplates {
    static let objectNotDetected = ToastNotification(
        title: "Couldn't take a photo",
        message: "Try adjusting the object's position.",
        iconName: "viewfinder.trianglebadge.exclamationmark"
    )
    
    static let lowLightDetected = ToastNotification(
        title: "Low Light Detected",
        message: "Try increasing the lighting for better results.",
        iconName: "lightbulb.min.badge.exclamationmark.fill"
    )
}
