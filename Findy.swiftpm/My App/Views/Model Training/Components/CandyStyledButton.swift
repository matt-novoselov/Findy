import SwiftUI

struct CandyStyledButton: View {
    var title: String
    var symbol: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: { action() }) {
            HStack(spacing: 5) {
                let foregroundColor = Color(hex: 0xA80ED0)
                Group {
                    Image(systemName: symbol)
                        .fontWeight(.black)
                        .font(.title3)
                        .accessibilityHidden(true)
                    
                    Text(title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .accessibilityLabel(title)
                }
                .fontDesign(.rounded)
                .foregroundStyle(foregroundColor)
                .shadow(color: .white.opacity(0.5), radius: 3, y: -1)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    capsuleBackground
                        .blur(radius: 6)
                        .opacity(0.8)
                    
                    capsuleBackground
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    var capsuleBackground: some View {
        Capsule()
            .fill(
                .shadow(.inner(color: .white, radius: 4, y: -5))
                .shadow(.inner(color: Color(hex: 0xA80ED0).opacity(0.4), radius: 3, y: -1))
            )
            .foregroundStyle(Color(hex: 0xF6BFF9))
            .overlay {
                Capsule()
                    .foregroundStyle(RadialGradient(colors: [Color(hex: 0xFCDDFF), .clear], center: .top, startRadius: 0, endRadius: 60))
                
                Capsule()
                    .strokeBorder(Color(hex: 0xDFA4EE).opacity(0.55), style: .init(lineWidth: 2))
            }
    }
}
