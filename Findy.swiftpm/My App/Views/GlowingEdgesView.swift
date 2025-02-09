//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 10/02/25.
//

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
