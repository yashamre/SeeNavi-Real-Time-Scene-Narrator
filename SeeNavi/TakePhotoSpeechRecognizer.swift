//
//  TakePhotoSpeechRecognizer.swift
//  SeeNavi
//
//  Created by Yash Amre on 02/07/25.
//

import Foundation
import Speech

class TakePhotoSpeechRecognizer {
    private var audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let trigger = "take photo"
    private let onTrigger: () -> Void

    init(onTrigger: @escaping () -> Void) {
        self.onTrigger = onTrigger
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func startListening() {
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.removeTap(onBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            guard let result = result else { return }
            let spoken = result.bestTranscription.formattedString.lowercased()
            if spoken.contains(self.trigger) {
                self.stopListening()
                self.onTrigger()
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}
