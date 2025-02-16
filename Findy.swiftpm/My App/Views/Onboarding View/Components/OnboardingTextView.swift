import SwiftUI

// MARK: - Subviews
struct OnboardingTextView: View {
    @State private var isBlurred: Bool = false
    let text: String
    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
            .fontDesign(.rounded)
            .font(.title2)
            .fontWeight(.bold)
            .blur(radius: isBlurred ? 5 : 0)
            .padding(30)
            .glassBackground(cornerRadius: .infinity)
            .clipShape(.capsule)
        
            .onChange(of: text){
                withAnimation{
                    self.isBlurred = true
                } completion: {
                    withAnimation{
                        self.isBlurred = false
                    }
                }
            }
    }
}
