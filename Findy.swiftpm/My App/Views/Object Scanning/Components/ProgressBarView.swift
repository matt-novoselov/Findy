import SwiftUI

struct ProgressBarView: View {
    @Environment(AppViewModel.self) private var appViewModel
    private let maxCapacity = AppMetrics.maxPhotoArrayCapacity
    
    var body: some View {
        HStack {
            // Photo count display
            let amountOfPhotos = appViewModel.savedObject.takenPhotos.count
            Text("\(amountOfPhotos) / \(maxCapacity)")
                .fontDesign(.rounded)
                .contentTransition(.numericText(value: Double(amountOfPhotos)))
                .animation(.spring, value: amountOfPhotos)
                .accessibilityLabel("Photo count")
                .accessibilityValue("\(amountOfPhotos) out of \(maxCapacity) photos taken")
            
            // Progress capsules
            HStack(spacing: 4) {
                ForEach(0..<maxCapacity, id: \.self) { index in
                    ProgressCapsuleView(amountOfPhotos: amountOfPhotos, index: index)
                        .accessibilityHidden(true) // Ignore accessibility for capsules
                }
            }
        }
        .fontWeight(.medium)
    }
}

struct ProgressCapsuleView: View {
    var amountOfPhotos: Int
    var index: Int
    var body: some View {
        Capsule()
            .fill(
                .shadow(.inner(color: Color.white.opacity(0.3), radius: 1, x: 0, y: -0.5))
                .shadow(.inner(color: Color.white.opacity(0.35), radius: 1, x: 0, y: -0.5))
                .shadow(.inner(color: Color.black.opacity(0.1), radius: 4, x: 1, y: 1.5))
                .shadow(.inner(color: Color.black.opacity(0.1), radius: 4, x: 1, y: 1.5))
            )
            .clipShape(.capsule)
            .foregroundStyle(Material.ultraThinMaterial)
            .frame(height: 12)
            .overlay(alignment: .leading){
                Capsule()
                    .foregroundStyle(Color.primary.opacity(0.6))
                    .frame(maxWidth: index < amountOfPhotos ? .infinity : 0)
            }
            .padding(-1)
            .clipShape(.capsule)
            .animation(
                .easeInOut(duration: 0.2).delay(Double(index) * 0.05),
                value: amountOfPhotos
            )
    }
}
