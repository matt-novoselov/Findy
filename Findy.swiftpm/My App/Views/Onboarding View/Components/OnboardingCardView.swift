import SwiftUI

struct OnboardingCardView: View {
    var card: OnboardingCardModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            if let appIcon = Bundle.main.icon{
                let imageView =                 Image(uiImage: appIcon)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: 65)
                    .perfectCornerRadius()
                
                imageView
                    .background{
                        imageView
                            .blur(radius: 20)
                    }
            }
            
            VStack(alignment: .leading, spacing: 2){
                Text(card.mainTitle)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
                
                Text(card.mainDescription)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(card.infoCards) { card in
                    HStack(spacing: 15) {
                        Group{
                            Image(systemName: "xmark")
                                .foregroundStyle(.clear)
                                .overlay{
                                    Image(systemName: card.icon)
                                }
                        }
                        .font(.body)
                        .foregroundStyle(.primary)
                        
                        Text(.init(card.description))
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Button(action: {
                card.buttonAction()
            }) {
                Text(card.buttonTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background{
                        Color(hex: 0xD6D6D6).opacity(0.45)
                            .blendMode(.colorBurn)
                        Color.black.opacity(0.08)
                            .blendMode(.luminosity)
                    }
                    .cornerRadius(16)
            }
        }
        .padding(.all, 25)
        .glassBackground(cornerRadius: 40)
        .frame(width: 420)
    }
}

struct OnboardingAlertView: View {
    var card: OnboardingCardModel
    var body: some View {
        ZStack{
            Color.black.opacity(0.5)
            OnboardingCardView(card: card)
        }
    }
}

//#Preview {
//    Color.green
//        .overlay{
//            OnboardingAlertView(card: ObjectSearchViewModel().card)
//        }
//}
