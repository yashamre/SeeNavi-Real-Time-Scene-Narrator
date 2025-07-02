//
//  CameraView.swift
//  SeeNavi
//
//  Created by Yash Amre on 24/06/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    class CameraPreviewView: UIView {
        private var previewLayer: AVCaptureVideoPreviewLayer?

        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }

        var session: AVCaptureSession? {
            get {
                return (layer as? AVCaptureVideoPreviewLayer)?.session
            }
            set {
                (layer as? AVCaptureVideoPreviewLayer)?.session = newValue
            }
        }
    }

    private let session = AVCaptureSession()

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.session = session
        setupCamera()
        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {}

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to access camera")
            return
        }

        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.sessionPreset = .photo
        session.commitConfiguration()
        session.startRunning()
    }
}
