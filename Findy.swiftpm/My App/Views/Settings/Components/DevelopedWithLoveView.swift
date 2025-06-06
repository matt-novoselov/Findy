import SwiftUI

struct DevelopedWithLoveView: View {
    var body: some View {
        HStack(spacing: 5) {
            Group {
                Text("Developed with")
                
                Image("HeartDrawing")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .accessibilityHidden(true)
                
                Text("by Matvei Novoselov")
            }
            .fontDesign(.rounded)
            .fontWeight(.medium)
            .opacity(0.6)
            .accessibilityLabel("Developed with love by Matvei Novoselov")
        }
    }
}
