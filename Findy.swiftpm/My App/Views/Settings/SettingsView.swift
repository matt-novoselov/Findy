import SwiftUI

struct SettingsView: View {
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        @Bindable var speechSynthesizer = speechSynthesizer
        @Bindable var appViewModel = appViewModel

        List {
            Section(
                header: Label("Voice Assistance", systemImage: "waveform")
                    .accentColor(.purple),
                footer: Text("Enable to have spoken assistance during app usage.")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            ) {
                Toggle(
                    "Speech Synthesizer",
                    isOn: $speechSynthesizer.isSpeechSynthesizerEnabled
                )
                .accessibilityLabel("Toggle voice assistance for spoken directions")
                
                SpeechSpeedSliderView()
            }
            .fontDesign(.rounded)

            #warning("Don't forget to enable")
//            Section(
//                header: Label("Proximity Ping Sound", systemImage: "speaker.wave.2.fill")
//                    .accentColor(.green),
//                footer: Text("Play a ping sound when an object comes close.")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            ) {
//                Toggle(
//                    "Play Alert Sound",
//                    isOn: $appViewModel.isMetalDetectionSoundEnabled
//                )
//                .accessibilityLabel("Toggle sound alerts for nearby objects")
//            }

            Section(
                header: Label("Developer Options", systemImage: "ladybug")
                    .accentColor(.red),
                footer: Text("For development and troubleshooting purposes. Enabling might affect performance.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
            ) {
                Toggle(
                    "Enable Debug Mode",
                    isOn: $appViewModel.isDebugMode
                )
                .accessibilityLabel("Toggle debug mode for additional developer information")
            }
            .fontDesign(.rounded)
        }
        .navigationTitle("App Settings")
        .listStyle(.insetGrouped)
    }
}

#Preview {
    SettingsView()
        .environment(SpeechSynthesizer())
        .environment(AppViewModel())
}
