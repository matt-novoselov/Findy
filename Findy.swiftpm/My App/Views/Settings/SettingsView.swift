//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    @Environment(AppViewModel.self) private var appViewModel
    var body: some View {
        @Bindable var speechSynthesizer = speechSynthesizer
        @Bindable var appViewModel = appViewModel
        
        VStack{
            SpeechSpeedSliderView()
                .padding()
            
            Toggle(isOn: $speechSynthesizer.isSpeechSynthesizerEnabled, label: { Text("Enable Speech Synthesizer") })
            
            Toggle(isOn: $appViewModel.isMetalDetectionSoundEnabled, label: { Text("Enable Metal Detection sound") })
        }
        .padding()
        
    }
}
