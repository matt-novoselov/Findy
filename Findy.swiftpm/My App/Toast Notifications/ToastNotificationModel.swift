import SwiftUI

// MARK: - Toast Notification Model
struct ToastNotification: Identifiable {
    /// A unique identifier (for duplicate prevention).
    let id: UUID = .init()
    let title: String
    let message: String
    let iconName: String
}
