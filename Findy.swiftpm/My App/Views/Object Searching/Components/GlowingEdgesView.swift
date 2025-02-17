import SwiftUI
import UIKit

struct GlowingEdgesView: View {
    var objectDetected: Bool
    
    var body: some View {
        ZStack{
            let greenRectangleValue: CGFloat = 5
            RoundedRectangle(cornerRadius: getDeviceBasedCornerRadius())
                .stroke(.green, lineWidth: objectDetected ? greenRectangleValue : 0, antialiased: true)
                .animation(.spring, value: objectDetected)
                .blur(radius: greenRectangleValue)
            
            let whiteRectangleValue: CGFloat = 3
            RoundedRectangle(cornerRadius: getDeviceBasedCornerRadius())
                .stroke(.white, lineWidth: objectDetected ? whiteRectangleValue : 0, antialiased: true)
                .animation(.spring, value: objectDetected)
                .blur(radius: whiteRectangleValue)
                .blendMode(.plusLighter)
        }
    }
}

func getDeviceBasedCornerRadius() -> CGFloat {
    let screenSize = UIScreen.main.bounds.size
    let sortedScreen = [screenSize.width, screenSize.height].sorted()
    
    let dimensionsToRadius: [([CGFloat], CGFloat)] = [
        ([744, 1133].sorted(), 21.5),
        ([820, 1180].sorted(), 18),
        ([1024, 1366].sorted(), 18),
        ([834, 1194].sorted(), 18),
        ([834, 1210].sorted(), 30),
        ([1032, 1376].sorted(), 30),
        ([768, 1024].sorted(), 0),
        ([810, 1080].sorted(), 0),
        ([834, 1112].sorted(), 0)
    ]
    
    return dimensionsToRadius.first(where: { $0.0 == sortedScreen })?.1 ?? 0
}


#Preview {
    @Previewable @State var appViewModel = AppViewModel()
    GlowingEdgesView(objectDetected: true)
        .environment(appViewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.black)
}
