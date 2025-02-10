import SwiftUI

struct GlowingEdgesView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: getCornerRadius())
                .stroke(Color.green, lineWidth: appViewModel.hasObjectBeenDetected ? 5 : 0, antialiased: true)
                .animation(.spring, value: appViewModel.hasObjectBeenDetected)
                .blur(radius: 5)
            
            RoundedRectangle(cornerRadius: getCornerRadius())
                .stroke(Color.white, lineWidth: appViewModel.hasObjectBeenDetected ? 3 : 0, antialiased: true)
                .animation(.spring, value: appViewModel.hasObjectBeenDetected)
                .blur(radius: 3)
                .blendMode(.plusLighter)
        }
    }
}

import SwiftUI
import UIKit

func getCornerRadius() -> CGFloat {
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
    GlowingEdgesView()
        .environment(appViewModel)
        .onAppear{
            appViewModel.hasObjectBeenDetected = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.black)
}
