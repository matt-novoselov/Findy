import SwiftUI

struct VariableFontAnimationView: View {
    
    @State private var fontWeight: Double = 0
    @State private var fontWidth: Double = 0
    let text = "Model Training Done"
    let delayPerSymbol: Double = 0.1
    let animationDuration: Double = 0.4
    
    var body: some View {
        
        HStack(spacing: 0){
            Image(systemName: "checkmark")
                .font(Font(UIFont.systemFont(ofSize: 30, weight: .init(fontWeight), width: .init(fontWidth))))
                .padding(.horizontal, fontWeight)
                .animation(.bouncy(duration: animationDuration), value: fontWeight)
                .padding(.horizontal)
            
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(Font(UIFont.systemFont(ofSize: 30, weight: .init(fontWeight), width: .init(fontWidth))))
                    .padding(.horizontal, fontWeight)
                    .animation(.bouncy(duration: animationDuration).delay(Double(index) * delayPerSymbol), value: fontWeight)
            }
        }
        .onAppear{
            playAnimation()
        }
    }
    
    func playAnimation(){
        withAnimation(.bouncy(duration: Double(text.count) * delayPerSymbol)) {
            fontWeight = 0.7
            fontWidth = 0.7
        } completion: {
            withAnimation(.linear(duration: Double(text.count) * delayPerSymbol)) {
                fontWeight = 0.5
            }
            
            withAnimation(.linear(duration: Double(text.count) * delayPerSymbol * 0.4)) {
                fontWidth = 0
            }
        }
    }
}

