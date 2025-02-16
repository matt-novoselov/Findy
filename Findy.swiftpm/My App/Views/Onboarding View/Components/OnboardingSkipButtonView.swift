import SwiftUI


struct OnboardingSkipButtonView: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Skip Onboarding")
                .padding(6)
                .padding(.horizontal, 8)
                .font(.callout)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
                .glassBackground(cornerRadius: .infinity)
                .padding(20)
                .padding(.top)
        }
        .buttonStyle(.plain)
    }
}
