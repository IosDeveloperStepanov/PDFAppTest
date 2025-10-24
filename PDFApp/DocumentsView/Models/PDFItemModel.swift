//
//  Untitled.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import Foundation
import UIKit

struct PDFItem: Identifiable {
    let id: UUID
    let title: String
    let fileName: String
    let createdAt: Date
    let thumbnailData: Data?

    var thumbnailImage: UIImage? {
        thumbnailData.flatMap { UIImage(data: $0) }
    }

    var fileURL: URL {
        FileStorage.loadURL(forFileName: fileName)
    }
}
