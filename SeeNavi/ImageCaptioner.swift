import Foundation
import UIKit
import Combine
import AVFoundation
import Vision
import CoreML

class ImageCaptioner: ObservableObject {
    @Published var caption: String = "Tap capture to describe the scene."
    @Published var isTextRecognition: Bool = false
    @Published var isObjectDetection: Bool = false

    private let synthesizer = AVSpeechSynthesizer()

    func generateCaption(from uiImage: UIImage) {
        sendImageToServer(uiImage: uiImage) { [weak self] captionText in
            DispatchQueue.main.async {
                let text = captionText ?? "Error: No caption received."
                self?.caption = text
                self?.speak(text)
            }
        }
    }

    func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("Invalid image for text recognition.")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion("Text recognition failed.")
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let recognizedText = observations.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")

            completion(recognizedText.isEmpty ? nil : recognizedText)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion("Failed to perform text recognition.")
            }
        }
    }

    func detectObjects(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("Invalid image.")
            return
        }

        guard let model = try? VNCoreMLModel(for: YOLOv3().model) else {
            completion("Failed to load object detection model.")
            return
        }

        let request = VNCoreMLRequest(model: model) { req, error in
            guard let results = req.results as? [VNRecognizedObjectObservation], error == nil else {
                completion("Object detection failed.")
                return
            }

            let descriptions = results.compactMap { obs -> String? in
                guard let label = obs.labels.first?.identifier else { return nil }
                let midX = obs.boundingBox.midX

                if midX < 0.33 {
                    return "\(label) on the left"
                } else if midX > 0.66 {
                    return "\(label) on the right"
                } else {
                    return "\(label) in the center"
                }
            }

            let summary = descriptions.isEmpty ? nil : descriptions.joined(separator: ", ")
            completion(summary)
        }

        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    func replayLastCaption() {
        speak(caption)
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .duckOthers])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error:", error)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}

func sendImageToServer(uiImage: UIImage, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: "http://10.0.0.177:5005/decode") else {
        completion("Invalid server URL.")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
        completion("Failed to encode image.")
        return
    }

    let base64String = imageData.base64EncodedString()
    let json: [String: Any] = ["image": base64String]

    guard let httpBody = try? JSONSerialization.data(withJSONObject: json) else {
        completion("Failed to serialize input.")
        return
    }

    request.httpBody = httpBody

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion("Server error: \(error.localizedDescription)")
            return
        }

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let caption = json["caption"] as? String else {
            completion("Error decoding server response.")
            return
        }

        completion(caption)
    }.resume()
}
