import SwiftUI

// MARK: - Subviews
struct OnboardingTextView: View {
    let text: String
    var body: some View {
        Text(text)
            .foregroundStyle(.primary)
            .fontDesign(.rounded)
            .font(.title2)
            .fontWeight(.bold)
            .padding(30)
            .glassBackground(cornerRadius: .infinity)
            .clipShape(Capsule())
    }
}
