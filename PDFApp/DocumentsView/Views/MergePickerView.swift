//
//  Untitled.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//
import SwiftUI

struct MergePickerView: View {
    let documents: [PDFItem]
    let onSelect: (PDFItem) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            List(documents) { doc in
                Button {
                    onSelect(doc)
                } label: {
                    Text(doc.title)
                }
            }
            .navigationTitle("Выберите документ для объединения")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена", action: onCancel)
                }
            }
        }
    }
}
