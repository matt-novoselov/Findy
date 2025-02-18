import AVFoundation

extension AVSpeechSynthesizer: @unchecked @retroactive Sendable {}

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
        if let voice = AVSpeechSynthesisVoice(
            identifier: AppMetrics.speechVoiceIdentifier
        ) {
            utterance.voice = voice
        }
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
        nextUtterance.rate = speechSynthesizerPlaybackSpeed
        synthesizer.speak(nextUtterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        speakNext()
    }
    
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        // In case of cancellation, try to speak the next utterance.
        speakNext()
    }
}
