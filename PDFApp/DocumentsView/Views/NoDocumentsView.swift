//
//  NoDocumentsView.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI

struct NoDocumentsView: View {
    var body: some View {
        Image(systemName: "doc.text.magnifyingglass")
            .font(.system(size: 60))
            .foregroundColor(.secondary)

        Text("Нет сохранённых документов")
            .font(.headline)
            .foregroundColor(.secondary)

        Text("Создайте новый PDF из фотографий или файлов.")
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }
}

#Preview {
    NoDocumentsView()
}
