# 👁️ SeeNavi – Real-Time Scene Narration for the Visually Impaired

**SeeNavi** is a voice-controlled iOS app designed to assist visually impaired users by narrating their surroundings using advanced machine learning models. Powered by on-device camera access, speech recognition, OCR, and object detection, SeeNavi delivers hands-free, real-time scene understanding.

---

## 🎯 Features

- 🧠 **Image Captioning** – Describes scenes using BLIP (Bootstrapped Language Image Pretraining)
- 📖 **OCR (Text Recognition)** – Reads printed or handwritten text using Apple's Vision framework
- 🧭 **Object Detection** – Identifies objects with spatial context (e.g., "chair on the left")
- 🎙 **Voice Command Support** – Responds to:
  - “capture scene”
  - “read text”
  - “detect objects”
  - “replay caption”
  - “take photo” (hands-free capture)
- 🗣 **Speech Narration** – Speaks all outputs aloud using AVSpeechSynthesizer
- 📱 **Camera Integration** – Seamless live preview with voice-triggered photo capture
- 🔁 **Continuous Voice Control** – Automatically restarts listening after every action
- 🟢 **Real-Time Feedback** – “Listening...” and “Processing...” indicators

---

## 🧭 User Flow – Designed for the Visually Impaired

SeeNavi provides a fully voice-driven loop designed to minimize screen interaction:

1. **Launch the app**
2. **Speak a command** such as:
   - “capture scene”
   - “read text”
   - “detect objects”
   - “replay caption”
3. App provides **audio feedback**:
   - “🎙 Listening...”
   - “⏳ Processing...”
4. SeeNavi **analyzes the camera image** and **narrates** results
5. App automatically **restarts listening** for the next command

> No taps required — designed for continuous, natural hands-free use.

---

## 📲 Screenshots

> Upload your screenshots to a `screenshots/` folder and replace the filenames below.

| Home View | Camera | Processing | Output |
|-----------|--------|--------------------|-----------------|
| ![Main](https://github.com/yashamre/SeeNavi-Real-Time-Scene-Narrator/blob/7997b051cddbfec7b37b2fa8a1ea09489dd77899/Screenshots/Interface.jpeg)| ![Camera](https://github.com/yashamre/SeeNavi-Real-Time-Scene-Narrator/blob/04f7707dcfdf907d108d8c9f1c13e881b6cfd20e/Screenshots/Camera.jpeg) | ![Voice](https://github.com/yashamre/SeeNavi-Real-Time-Scene-Narrator/blob/04f7707dcfdf907d108d8c9f1c13e881b6cfd20e/Screenshots/Processing.jpeg) | ![Output](https://github.com/yashamre/SeeNavi-Real-Time-Scene-Narrator/blob/7997b051cddbfec7b37b2fa8a1ea09489dd77899/Screenshots/Output.jpeg) |

---

## 🛠 Technologies

- **SwiftUI** – Declarative native UI
- **AVFoundation** – Text-to-speech narration
- **Speech Framework** – Live voice command recognition
- **Vision Framework** – OCR & object detection
- **CoreML** – For local ML integration (optional)
- **Python Flask** – Captioning backend with BLIP model from HuggingFace

---

## 🚀 Getting Started

### Requirements

- macOS + Xcode 15+
- iOS 15+ physical device (camera/mic access required)
- Python 3.8+ for backend
- Apple Developer Account for deployment (optional)

### Setup

1. Clone this repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/SeeNavi.git
   cd SeeNavi


2. Run the Python BLIP backend:

   ```bash
   pip install flask transformers torch pillow
   python decoder.py
   ```

3. Update IP in `ImageCaptioner.swift`:

   ```swift
   let url = URL(string: "http://<your-local-ip>:5005/decode")!
   ```

4. Open the project in Xcode and run on a real iPhone.

---

## 🧪 Voice Commands Summary

| Command          | Function                             |
| ---------------- | ------------------------------------ |
| "capture scene"  | Takes photo & generates caption      |
| "read text"      | Extracts printed or handwritten text |
| "detect objects" | Lists objects in view with position  |
| "replay caption" | Repeats last spoken result           |
| "take photo"     | Triggers camera hands-free           |


---
