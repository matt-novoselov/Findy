//
//  DebugDrawer.swift
//  Findy
//
//  Created by Matt Novoselov on 26/01/25.
//

import SwiftUI

struct DebugView: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        if appViewModel.isDebugMode {
            Group{
                DebugDistanceView()
                DebugCaptureView()
            }
            .allowsHitTesting(false)
        }
    }
}
