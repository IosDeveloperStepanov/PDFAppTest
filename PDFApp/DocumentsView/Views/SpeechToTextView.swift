//
//  SpeechToTextView.swift
//  PDFApp
//
//  Created by Игорь Степанов on 24.10.2025.
//

import SwiftUI

struct SpeechToTextView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Binding var isPresented: Bool
    var onFinish: (String) -> Void

    @State private var isRecording = false
    @State private var recognizedText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Новая страница с надиктованным текстом")
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    Text(recognizedText.isEmpty ? "Начните диктовку..." : recognizedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .frame(height: 200)

                HStack(spacing: 20) {
                    Button(isRecording ? "Остановить" : "Начать диктовку") {
                        if isRecording {
                            speechRecognizer.stopRecording()
                            isRecording = false
                        } else {
                            recognizedText = ""
                            speechRecognizer.startRecording { text in
                                recognizedText = text
                            }
                            isRecording = true
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Добавить в документ") {
                        onFinish(recognizedText)
                        isPresented = false
                    }
                    .disabled(recognizedText.isEmpty)
                }

                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Закрыть") {
                isPresented = false
            })
        }
    }
}
