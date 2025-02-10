import SwiftUI

struct ProgressBarView: View {
    @Environment(AppViewModel.self) private var appViewModel
    private let maxCapacity = AppMetrics.maxPhotoArrayCapacity
    
    var body: some View {
        HStack{
            // Photo count display
            Text("\(appViewModel.takenPhotos.count)/\(maxCapacity)")
                .contentTransition(.numericText(value: Double(appViewModel.takenPhotos.count)))
                .animation(.spring, value: appViewModel.takenPhotos.count)
            
            // Progress capsules
            HStack(spacing: 4) {
                ForEach(0..<maxCapacity, id: \.self) { index in
                    Capsule()
                        .frame(height: 6)
                        .foregroundStyle(Material.thin)
                        .overlay{
                            if index < appViewModel.takenPhotos.count {
                                Color.primary.opacity(0.6)
                                    .clipShape(.capsule)
                                    .transition(.scale(scale: 0, anchor: .leading))
                            }
                        }
                        .clipped()
                        .animation(
                            .easeInOut(duration: 0.2).delay(Double(index) * 0.05),
                            value: appViewModel.takenPhotos.count
                        )
                }
            }
        }
        .fontDesign(.monospaced)
        .fontWeight(.medium)
    }
}


//#Preview {
//    @Previewable @State var appViewModel: AppViewModel = .init()
//    ProgressBarView()
//        .environment(appViewModel)
//    
//    Button("Click"){
//        appViewModel.takenPhotos.append((CIImage(image: UIImage(named: "screenshot")!)?.toCGImage())!)
//    }
//}
