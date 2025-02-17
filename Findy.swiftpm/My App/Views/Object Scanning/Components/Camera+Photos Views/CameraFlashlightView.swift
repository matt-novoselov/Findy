import SwiftUI

struct CameraFlashlightView: View {
    @State private var opacity: Double = 0
    @Binding var isShutterActive: Bool
    
    var body: some View {
        Color.white
            .ignoresSafeArea()
            .opacity(opacity)
            .onChange(of: isShutterActive){
                opacity = 1
                withAnimation(.spring(duration: 2)){
                    opacity = 0
                }
            }
    }
}

#Preview {
    @Previewable @State var activeShutter: Bool = false
    CameraFlashlightView(isShutterActive: $activeShutter)
        .background(.green)
        .overlay{
            Button("Toggle"){
                activeShutter.toggle()
            }
        }
}
