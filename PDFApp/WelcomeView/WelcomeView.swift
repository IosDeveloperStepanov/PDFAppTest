//
//  WelcomeView.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI

struct WelcomeView: View {
    
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "doc.richtext.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding()
                .background(RoundedRectangle(cornerRadius: 24).opacity(0.05))
            Text("PDFApp")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Создавайте, редактируйте и объединяйте PDF-документы из фотографий и файлов. Сохраняйте и делитесь результатами.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                
            Button(action: { hasSeenWelcome = true }) {
                HStack {
                    Spacer()
                    Text("Начать работу")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor))
                .foregroundColor(.white)
                
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
#Preview {
    WelcomeView()
}
