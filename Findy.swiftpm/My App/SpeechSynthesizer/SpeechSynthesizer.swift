import AVFoundation

extension AVSpeechSynthesizer: @unchecked @retroactive Sendable {}

// A helper struct that stores an utterance along with its cancellable flag.
struct QueuedUtterance {
    let utterance: AVSpeechUtterance
    let cancellable: Bool
}

@Observable
class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var utteranceQueue: [QueuedUtterance] = []
    var speechSynthesizerPlaybackSpeed: Float =
        AVSpeechUtteranceDefaultSpeechRate
    var isSpeechSynthesizerEnabled: Bool = true {
        didSet {
            if !isSpeechSynthesizerEnabled {
                muteCurrentUtterance()
            }
        }
    }
    
    private var isMuted: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speaks the provided text.
    /// - Parameters:
    ///   - text: The text to speak.
    ///   - cancellable: Whether this utterance can be cancelled by an urgent utterance.
    ///                  Defaults to false.
    ///   - urgent: If true, all cancellable utterances in the queue are dropped and
    ///             this utterance is prioritized. Defaults to false.
    func speak(text: String,
               cancellable: Bool = false,
               urgent: Bool = false) {
        // Create an AVSpeechUtterance with the given text.
        let utterance = AVSpeechUtterance(string: text)
        // Set the voice for the utterance.
        if let voice = AVSpeechSynthesisVoice(
            identifier: AppMetrics.speechVoiceIdentifier
        ) {
            utterance.voice = voice
        }
        // Defer setting the rate until the utterance is about to be spoken.
        enqueue(utterance, cancellable: cancellable, urgent: urgent)
    }

    /// Enqueues an utterance.
    private func enqueue(_ utterance: AVSpeechUtterance,
                         cancellable: Bool,
                         urgent: Bool) {
        if urgent {
            // Drop all queued utterances that are cancellable.
            utteranceQueue.removeAll { $0.cancellable }
        }
        
        utteranceQueue.append(
            QueuedUtterance(utterance: utterance, cancellable: cancellable)
        )
        
        // If the synthesizer is idle, start processing the queue.
        if !synthesizer.isSpeaking {
            speakNext()
        }
    }

    /// Speaks the next utterance in the queue, applying the current speech rate first.
    private func speakNext() {
        guard !utteranceQueue.isEmpty else { return }
        guard isSpeechSynthesizerEnabled else { return }
        
        let nextInQueue = utteranceQueue.removeFirst()
        // Apply the latest speed setting just before speaking.
        nextInQueue.utterance.rate = speechSynthesizerPlaybackSpeed
        
        if !isMuted {
            synthesizer.speak(nextInQueue.utterance)
        }
    }

    /// Mutes the current utterance if it is being spoken.
    private func muteCurrentUtterance() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isMuted = true
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        isMuted = false // Reset mute state after finishing an utterance
        speakNext()
    }
    
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        isMuted = false // Reset mute state after cancellation
        speakNext()
    }
}
