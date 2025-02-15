import SwiftUI


struct OnboardingStartButtonView: View {
    let action: () -> Void
    var body: some View {
        CandyStyledButton(title: "Start Exploring", symbol: "arrow.right", action: action)
    }
}
