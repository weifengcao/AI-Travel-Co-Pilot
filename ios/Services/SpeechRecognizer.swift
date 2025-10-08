
// Zenese
// File: ios/Services/SpeechRecognizer.swift
// Description: A helper to handle speech-to-text transcription using the Speech framework.

import Foundation
import Speech
import Combine

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    @Published var error: String?

    // A subject to publish the final transcription
    private var finalTranscriptionSubject = PassthroughSubject<String, Never>()
    var finalTranscriptionPublisher: AnyPublisher<String, Never> {
        finalTranscriptionSubject.eraseToAnyPublisher()
    }

    deinit {
        stopRecording()
    }

    func startRecording() {
        guard !isRecording else { return }

        // Request authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                guard authStatus == .authorized else {
                    self.error = "Speech recognition authorization denied."
                    return
                }

                self.isRecording = true
                self.transcribedText = ""
                self.startAudioEngine()
            }
        }
    }

    private func startAudioEngine() {
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = "Failed to set up audio session: \(error.localizedDescription)"
            self.isRecording = false
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object.")
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                if result.isFinal {
                    self.finalTranscriptionSubject.send(result.bestTranscription.formattedString)
                    self.stopRecording()
                }
            } else if let error = error {
                self.error = "Recognition task error: \(error.localizedDescription)"
                self.stopRecording()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.error = "Audio engine failed to start: \(error.localizedDescription)"
            self.stopRecording()
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        DispatchQueue.main.async {
            self.isRecording = false
        }
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            // No need to surface this error to the user
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
