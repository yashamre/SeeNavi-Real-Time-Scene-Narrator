import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?
    
    @Published var isListening = false
    private var commandActions: [String: () -> Void] = [:]

    init(locale: Locale = Locale(identifier: "en-US")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func startListening(commands: [String: () -> Void]) {
        self.commandActions = commands
        self.isListening = true

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
            for (command, action) in self.commandActions {
                if spoken.contains(command.lowercased()) {
                    self.stopListening()
                    action()
                    break
                }
            }
        }
    }

    func stopListening() {
        isListening = false
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}
