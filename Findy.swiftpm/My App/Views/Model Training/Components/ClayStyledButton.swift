import SwiftUI

struct ClayStyledButton: View {
    var action: Void = {}()
    var body: some View {
        Button(action: {action}){
            HStack(spacing: 5){
                let foregroundColor = Color(hex: 0xA80ED0)
                Group{
                    Image(systemName: "sparkles")
                        .fontWeight(.black)
                        .font(.title3)
                    
                    Text("Train AI Model")
                        .fontWeight(.bold)
                }
                .fontDesign(.rounded)
                .foregroundStyle(foregroundColor)
                .shadow(color: .white.opacity(0.5), radius: 3, y: -1)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background{
                Capsule()
                    .fill(
                        .shadow(.inner(color: .white, radius: 4, y: -5))
                        .shadow(.inner(color: Color(hex: 0xA80ED0).opacity(0.4), radius: 3, y: -1))
                    )
                    .foregroundStyle(Color(hex: 0xF6BFF9))
                    .overlay{
                        Capsule()
                            .foregroundStyle(RadialGradient(colors: [Color(hex: 0xFCDDFF), .clear], center: .top, startRadius: 0, endRadius: 60))
                        
                        Capsule()
                            .strokeBorder(Color(hex: 0xDFA4EE).opacity(0.55), style: .init(lineWidth: 2))
                    }
            }
            
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ClayStyledButton()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
}
