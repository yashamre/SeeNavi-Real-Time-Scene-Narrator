//
//  CameraViewController.swift
//  SeeNavi
//
//  Created by Yash Amre on 02/07/25.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var onPhotoTaken: ((UIImage?) -> Void)?
    var speechRecognizer: TakePhotoSpeechRecognizer?

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(takePhoto), name: NSNotification.Name("TakePhotoNow"), object: nil)
        speechRecognizer?.startListening()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        session.startRunning()
    }

    @objc func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            onPhotoTaken?(nil)
            return
        }
        session.stopRunning()
        speechRecognizer?.stopListening()
        onPhotoTaken?(image)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
