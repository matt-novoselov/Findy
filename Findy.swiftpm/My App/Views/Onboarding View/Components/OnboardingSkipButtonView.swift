import SwiftUI

struct OnboardingSkipButtonView: View {
    let action: () -> Void
    @State private var showingConfirmation: Bool = false

    var body: some View {
        Button(action: {
            showingConfirmation = true
        }) {
            Text("Skip Onboarding")
                .fontDesign(.rounded)
                .padding(6)
                .padding(.horizontal, 8)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .glassBackground(cornerRadius: .infinity)
                .padding(20)
                .padding(.top)
        }
        .buttonStyle(.plain)
        .alert("Skip Onboarding", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Skip Onboarding", role: .destructive) {
                action()
            }
        } message: {
            Text("Are you sure you want to skip onboarding?")
        }
    }
}
