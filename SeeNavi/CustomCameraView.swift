//
//  CustomCameraView.swift
//  SeeNavi
//
//  Created by Yash Amre on 02/07/25.
//

import SwiftUI

struct CustomCameraView: UIViewControllerRepresentable {
    var onPhotoTaken: (UIImage?) -> Void
    var speechRecognizer: TakePhotoSpeechRecognizer

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onPhotoTaken = onPhotoTaken
        vc.speechRecognizer = speechRecognizer
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
