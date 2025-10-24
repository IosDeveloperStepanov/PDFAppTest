//
//  SpeechRecognizer.swift
//  PDFApp
//
//  Created by Игорь Степанов on 24.10.2025.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording(onTextChange: @escaping (String) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
            guard micGranted else {
                print("❌ Нет доступа к микрофону")
                return
            }

            SFSpeechRecognizer.requestAuthorization { speechAuthStatus in
                guard speechAuthStatus == .authorized else {
                    print("❌ Нет доступа к распознаванию речи")
                    return
                }

                DispatchQueue.main.async {
                    self.record(onTextChange: onTextChange)
                }
            }
        }
    }

    
    private func record(onTextChange: @escaping (String) -> Void) {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                onTextChange(result.bestTranscription.formattedString)
            }
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

