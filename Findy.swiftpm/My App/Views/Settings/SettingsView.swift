import SwiftUI

struct SettingsView: View {
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        @Bindable var speechSynthesizer = speechSynthesizer
        @Bindable var appViewModel = appViewModel
        
        Group{
            SpeechSpeedSliderView()
            
            Toggle(isOn: $speechSynthesizer.isSpeechSynthesizerEnabled, label: {
                Text("Enable Speech Synthesizer")
                    .fontDesign(.rounded)
            })
            
            Toggle(isOn: $appViewModel.isMetalDetectionSoundEnabled, label: {
                Text("Enable Metal Detection sound")
                    .fontDesign(.rounded)
            })
            
            Toggle("Debug", isOn: $appViewModel.isDebugMode)
                .toggleStyle(.switch)
                .fontDesign(.rounded)
            
            Picker("App State", selection: $appViewModel.state) {
                ForEach(AppState.allCases, id: \.self) { state in
                    Text(state.rawValue)
                        .tag(state)
                        .fontDesign(.rounded)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        
    }
}
