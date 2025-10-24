//
//  DocumentCell.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI


struct DocumentCell: View {
    let item: PDFItem
    
    var body: some View {
        HStack(spacing: 12) {
            if let thumb = item.thumbnailImage {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 80)
                    .overlay(
                        Image(systemName: "doc.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(".pdf • \(item.createdAt, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

#Preview {
    DocumentCell(item: .init(id: .init(), title: "123", fileName: "123", createdAt: .now, thumbnailData: nil))
}
