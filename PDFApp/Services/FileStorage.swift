//
//  FileStorage.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import Foundation

enum FileStorage {
    static private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func save(data: Data, as fileName: String) throws {
        let url = documentsDirectory.appendingPathComponent(fileName)
        try data.write(to: url)
    }

    static func loadURL(forFileName fileName: String) -> URL {
        documentsDirectory.appendingPathComponent(fileName)
    }

    static func loadData(forFileName fileName: String) -> Data? {
        let url = loadURL(forFileName: fileName)
        return try? Data(contentsOf: url)
    }

    static func removeFile(named fileName: String) throws {
        let url = loadURL(forFileName: fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
