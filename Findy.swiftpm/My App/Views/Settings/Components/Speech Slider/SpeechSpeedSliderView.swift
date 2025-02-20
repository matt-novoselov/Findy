import SwiftUI

struct SpeechSpeedSliderView: View {
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    
    var body: some View {
        @Bindable var speechSynthesizer = speechSynthesizer
        let bindingValue: Binding<Double> = Binding(
            get: { Double(speechSynthesizer.speechSynthesizerPlaybackSpeed) },
            set: { newValue in
                // Snap to 0.1 increments
                speechSynthesizer.speechSynthesizerPlaybackSpeed = Float((newValue * 10).rounded() / 10)
            }
        )
        
        HStack {
            Text("Speech Rate")
                .fontDesign(.rounded)
            
            // Divider
            RoundedRectangle(cornerRadius: 100)
                .frame(width: 1)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
            
            Image(systemName: "tortoise.fill")
                .symbolEffect(
                    .bounce,
                    value: speechSynthesizer.speechSynthesizerPlaybackSpeed == 0.1
                )
                .accessibilityHidden(true) // Ignore accessibility for tortoise image
            
            CustomSliderView(value: bindingValue, sliderRange: 0.1...1)
                .frame(height: 24)
                .accessibilityLabel("Adjust speech rate") // Provide accessibility label for the slider
            
            Image(systemName: "hare.fill")
                .symbolEffect(
                    .bounce,
                    value: speechSynthesizer.speechSynthesizerPlaybackSpeed == 1.0
                )
                .accessibilityHidden(true) // Ignore accessibility for hare image
        }
    }
}

#Preview {
    SpeechSpeedSliderView()
        .environment(SpeechSynthesizer())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: UIColor.systemGray4))
}
