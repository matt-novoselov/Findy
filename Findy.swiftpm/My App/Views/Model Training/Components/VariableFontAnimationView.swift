import SwiftUI

struct VariableFontAnimationView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var fontWeight: Double = 0
    @State private var text = "AI Model Trained!"
    let delayPerSymbol: Double = 0.05
    let animationDuration: Double = 0.25
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(Font(UIFont.systemFont(ofSize: 30, weight: .init(fontWeight), width: .init(fontWeight))))
                    .padding(.horizontal, fontWeight)
                    .animation(.bouncy(duration: animationDuration).delay(Double(index) * delayPerSymbol), value: fontWeight)
                    .accessibilityHidden(true)
            }
        }
        .onAppear {
            playAnimation()
        }
        .onChange(of: appViewModel.savedObject.userGivenObjectName){
            let newName = appViewModel.savedObject.userGivenObjectName
            if !newName.isEmpty{
                self.text = "My \(newName)"
            } else {
                self.text = "Model Training Done"
            }
        }
        .accessibilityLabel(text)
    }
    
    func playAnimation() {
        withAnimation(.bouncy(duration: Double(text.count) * delayPerSymbol)) {
            fontWeight = 0.7
        }
    }
}
