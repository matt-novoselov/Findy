//
//  SpeachSpeedSliderView.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//

import SwiftUI

struct SpeechSpeedSliderView: View {
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    
    var body: some View {
        @Bindable var speechSynthesizer = speechSynthesizer
        
        VStack(spacing: 20) {
            Text("Playback Speed")
                .font(.headline)
            
            HStack {
                Image(systemName: "tortoise.fill")
                    .symbolEffect(
                        .bounce,
                        value: speechSynthesizer.speechSynthesizerPlaybackSpeed == 0.1
                    )
                
                Slider(
                    value: Binding(
                        get: { speechSynthesizer.speechSynthesizerPlaybackSpeed },
                        set: { newValue in
                            // Snap to 0.1 increments
                            speechSynthesizer.speechSynthesizerPlaybackSpeed = (newValue * 10).rounded() / 10
                        }
                    ),
                    in: 0.1...1
                )
                .accentColor(.blue)
                
                Image(systemName: "hare.fill")
                    .symbolEffect(
                        .bounce,
                        value: speechSynthesizer.speechSynthesizerPlaybackSpeed == 1.0
                    )
            }
        }
    }
}
