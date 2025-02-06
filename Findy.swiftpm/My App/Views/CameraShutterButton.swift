//
//  CameraShutterButton.swift
//  Findy
//
//  Created by Matt Novoselov on 06/02/25.
//

import SwiftUI

struct CameraShutterButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(.white)
                .frame(width: 55, height: 55)
        }
        .buttonStyle(ShutterButtonStyle())
        
        // Outer ring
        .overlay{
            Circle()
                .stroke(.white, lineWidth: 5)
                .frame(width: 70, height: 70)
        }
    }
}

struct ShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                Circle()
                    .fill(Color.white.opacity(configuration.isPressed ? 0.2 : 0))
                    .frame(width: 65, height: 65)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    CameraShutterButton(action: {})
}
