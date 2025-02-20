import SwiftUI

struct DimmedView: View {
    var body: some View {
        Color.black.opacity(0.5)
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityHidden(true)
    }
}
