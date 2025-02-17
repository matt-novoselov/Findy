import SwiftUI

struct RecessedRectangleView: View {
    var cornerRadius: CGFloat = 20
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                .shadow(.inner(color: Color.white.opacity(0.6), radius: 2, x: 0, y: -1))
                .shadow(.inner(color: Color.white.opacity(0.7), radius: 2, x: 0, y: -1))
                .shadow(.inner(color: Color.black.opacity(0.9), radius: 8, x: 1, y: 3))
                .shadow(.inner(color: Color.black.opacity(0.9), radius: 8, x: 1, y: 3))
            )
            .foregroundStyle(Color.black.opacity(0.1).blendMode(.luminosity))
            .foregroundStyle(Color(hex: 0xD0D0D0).opacity(0.5).blendMode(.colorBurn))
    }
}
