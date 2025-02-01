//
//  SpeechSynthesizer.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//

import AVFoundation

@MainActor
@Observable
class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var utteranceQueue: [AVSpeechUtterance] = []
    var speechSynthesizerPlaybackSpeed: Float = AVSpeechUtteranceDefaultSpeechRate
    
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
        let nextUtterance = utteranceQueue.removeFirst()
        synthesizer.speak(nextUtterance)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            speakNext()
        }
    }
}
