import SwiftUI

struct OnboardingCardView: View {
    var card: OnboardingCardModel
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            AppIconView()
                .accessibilityHidden(true) // Ignore accessibility for AppIconView
            
            VStack(alignment: .leading, spacing: 2) {
                Text(card.mainTitle)
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                    .foregroundStyle(.primary)
                
                Text(card.mainDescription)
                    .font(.body)
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.tertiary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(card.infoCards.enumerated()), id: \.offset) { index, infoCard in
                    Group {
                        if currentIndex >= index {
                            HStack(spacing: 15) {
                                Group{
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.clear)
                                        .overlay {
                                            Image(systemName: infoCard.icon)
                                                .accessibilityHidden(true)
                                        }
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                                .accessibility(hidden: true)
                                
                                Text(.init(infoCard.description))
                                    .fontDesign(.rounded)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            .transition(.move(edge: .bottom).combined(with: .blurReplace))
                        }
                    }
                    .animation(.spring, value: currentIndex)
                }
            }
            
            let isLast = currentIndex == card.infoCards.count - 1
            Button(action: {
                if isLast {
                    card.buttonAction()
                } else {
                    if currentIndex < card.infoCards.count {
                        currentIndex += 1
                    }
                }
            }) {
                Text(isLast ? card.buttonTitle : "Continue")
                    .fontDesign(.rounded)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        Color(hex: 0xD6D6D6).opacity(0.45)
                            .blendMode(.colorBurn)
                        Color.black.opacity(0.08)
                            .blendMode(.luminosity)
                    }
                    .cornerRadius(16)
                    .animation(.none, value: isLast)
                    .accessibilityLabel(isLast ? "Finish" : "Continue") // Provide accessibility label for button
            }
        }
        .padding(.all, 25)
        .glassBackground(cornerRadius: 40)
        .animation(.spring(), value: currentIndex)
        .frame(width: 420)
    }
}

struct OnboardingAlertView: View {
    var card: OnboardingCardModel
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .accessibilityHidden(true)
            OnboardingCardView(card: card)
        }
    }
}

#Preview {
    Color.green
        .overlay {
            OnboardingAlertView(card: ObjectSearchViewModel(action: {}).card)
        }
}
