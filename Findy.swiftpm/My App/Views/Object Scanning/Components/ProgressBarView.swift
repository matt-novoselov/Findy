import SwiftUI

struct ProgressBarView: View {
    @Environment(AppViewModel.self) private var appViewModel
    private let maxCapacity = AppMetrics.maxPhotoArrayCapacity
    
    var body: some View {
        HStack{
            // Photo count display
            let amountOfPhotos = appViewModel.savedObject.takenPhotos.count
            Text("\(amountOfPhotos)/\(maxCapacity)")
                .contentTransition(.numericText(value: Double(amountOfPhotos)))
                .animation(.spring, value: amountOfPhotos)
            
            // Progress capsules
            HStack(spacing: 4) {
                ForEach(0..<maxCapacity, id: \.self) { index in
                    Capsule()
                        .frame(height: 6)
                        .foregroundStyle(Material.thin)
                        .overlay{
                            if index < amountOfPhotos {
                                Color.primary.opacity(0.6)
                                    .clipShape(.capsule)
                                    .transition(.scale(scale: 0, anchor: .leading))
                            }
                        }
                        .clipped()
                        .animation(
                            .easeInOut(duration: 0.2).delay(Double(index) * 0.05),
                            value: amountOfPhotos
                        )
                }
            }
        }
        .fontDesign(.monospaced)
        .fontWeight(.medium)
    }
}
