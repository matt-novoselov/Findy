import AVFoundation

@MainActor
@Observable
class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var utteranceQueue: [AVSpeechUtterance] = []
    var speechSynthesizerPlaybackSpeed: Float = AVSpeechUtteranceDefaultSpeechRate
    var isSpeechSynthesizerEnabled: Bool = true
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: AppMetrics.speechVoiceIdentifier)
        utterance.rate = speechSynthesizerPlaybackSpeed
        enqueue(utterance)
    }
    
    private func enqueue(_ utterance: AVSpeechUtterance) {
        utteranceQueue.append(utterance)
        if !synthesizer.isSpeaking {
            speakNext()
        }
    }
    
    private func speakNext() {
        guard !utteranceQueue.isEmpty else { return }
        guard isSpeechSynthesizerEnabled else { return }
        let nextUtterance = utteranceQueue.removeFirst()
        synthesizer.speak(nextUtterance)
    }
}
