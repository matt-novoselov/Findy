import SwiftUI

// MARK: - Toast Notification Model
struct ToastNotification: Identifiable {
    let id: UUID = .init()
    let title: String
    let message: String
    let iconName: String
}
