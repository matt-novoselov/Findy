import SwiftUI

struct OnboardingTapToContinueView: View {
    @State private var animate = false

    var body: some View {
        HStack {
            Image(systemName: "hand.tap.fill")
                .accessibilityHidden(true)
            Text("Tap to Continue")
        }
        .foregroundStyle(.secondary)
        .fontDesign(.rounded)
        .font(.largeTitle)
        .fontWeight(.bold)
        .opacity(animate ? 0.4 : 0.8)
        .padding(.bottom, 20)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
