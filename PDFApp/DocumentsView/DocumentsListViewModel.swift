//
//  DocumentsListViewModel.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import Foundation
import CoreData
import UIKit
import PDFKit

@MainActor
final class DocumentsViewModel: ObservableObject {
    
    @Published var documents: [PDFItem] = []
    
    @Published var mergingFirstDocument: PDFItem? = nil
    
    @Published var showPicker: Bool = false
    @Published var showMergePicker = false
    @Published var showSourceDialog = false
    @Published var showImagePicker = false
    
    @Published var selectedImage: UIImage?

    
    private let context = CoreDataManager.shared.viewContext
    init() {
        fetchDocuments()
    }
}
//MARK: uploading documents and interacting with them
extension DocumentsViewModel {
    func fetchDocuments() {
        let request = NSFetchRequest<PDFInformation>(entityName: "PDFInformation")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PDFInformation.createdAt, ascending: false)]
        do {
            let result = try context.fetch(request)
            self.documents = result.compactMap { obj in
                guard
                    let id = obj.value(forKey: "id") as? UUID,
                    let title = obj.value(forKey: "title") as? String,
                    let fileName = obj.value(forKey: "fileName") as? String,
                    let createdAt = obj.value(forKey: "createdAt") as? Date
                else { return nil }
                
                let thumbnailData = obj.value(forKey: "thumbnail") as? Data
                return PDFItem(id: id, title: title, fileName: fileName, createdAt: createdAt, thumbnailData: thumbnailData)
            }
        } catch {
            print("❌ Fetch error: \(error.localizedDescription)")
        }
    }
    
    func delete(_ item: PDFItem) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PDFInformation")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        if let obj = try? context.fetch(request).first {
            if let fileName = obj.value(forKey: "fileName") as? String {
                try? FileStorage.removeFile(named: fileName)
            }
            context.delete(obj)
            CoreDataManager.shared.save()
            fetchDocuments()
        }
    }
    
    func share(_ item: PDFItem) {
        let url = FileStorage.loadURL(forFileName: item.fileName)
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first?
            .present(av, animated: true)
    }
    
    func mergeDocuments(first: PDFItem, second: PDFItem) {
        guard
            let pdf1 = PDFDocument(url: first.fileURL),
            let pdf2 = PDFDocument(url: second.fileURL)
        else { return }
        
        let merged = PDFDocument()
        
        for i in 0..<pdf1.pageCount {
            if let page = pdf1.page(at: i) {
                merged.insert(page, at: merged.pageCount)
            }
        }
        
        for i in 0..<pdf2.pageCount {
            if let page = pdf2.page(at: i) {
                merged.insert(page, at: merged.pageCount)
            }
        }
        
        let id = UUID()
        let fileName = "\(id).pdf"
        let url = FileStorage.loadURL(forFileName: fileName)
        merged.write(to: url)
        let thumbnail: Data?
        
        if let firstPage = merged.page(at: 0) {
            let pageRect = firstPage.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let image = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                ctx.cgContext.translateBy(x: 0, y: pageRect.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
                ctx.cgContext.drawPDFPage(firstPage.pageRef!)
            }
            thumbnail = image.pngData()
        } else {
            thumbnail = nil
        }
        
        // Сохраняем в CoreData
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PDFInformation", into: CoreDataManager.shared.viewContext)
        entity.setValue(id, forKey: "id")
        entity.setValue("Объединенный: \(first.title) + \(second.title)", forKey: "title")
        entity.setValue(fileName, forKey: "fileName")
        entity.setValue(Date(), forKey: "createdAt")
        if let thumb = thumbnail {
            entity.setValue(thumb, forKey: "thumbnail")
        }
        
        CoreDataManager.shared.save()
        fetchDocuments()
    }
    
}

//MARK: add PDF from files
extension DocumentsViewModel {
    func importPDF(from url: URL) {
        let context = CoreDataManager.shared.viewContext
        let id = UUID()
        let fileName = "\(id).pdf"
        
        
        let accessGranted = url.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            try FileStorage.save(data: data, as: fileName)
            
            let entity = NSEntityDescription.insertNewObject(forEntityName: "PDFInformation", into: context)
            entity.setValue(id, forKey: "id")
            entity.setValue(url.deletingPathExtension().lastPathComponent, forKey: "title")
            entity.setValue(fileName, forKey: "fileName")
            entity.setValue(Date(), forKey: "createdAt")
            
            
            if let thumbnail = generateThumbnail(from: FileStorage.loadURL(forFileName: fileName)) {
                entity.setValue(thumbnail.pngData(), forKey: "thumbnail")
            }
            
            CoreDataManager.shared.save()
            fetchDocuments()
        } catch {
            print("❌ Ошибка при импорте PDF: \(error.localizedDescription)")
        }
    }
    
    
    private func generateThumbnail(from url: URL) -> UIImage? {
        guard let doc = CGPDFDocument(url as CFURL),
              let page = doc.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(page)
        }
    }
    
}
//MARK: add PDF from Photos
extension DocumentsViewModel {
    func importImageAsPDF(_ image: UIImage) {
        let pdf = PDFDocument()
        let pdfPage = PDFPage(image: image)
        pdf.insert(pdfPage!, at: 0)

        let id = UUID()
        let fileName = "\(id).pdf"
        let url = FileStorage.loadURL(forFileName: fileName)
        pdf.write(to: url)

        let thumbnail = image.pngData()

        let entity = NSEntityDescription.insertNewObject(forEntityName: "PDFInformation", into: CoreDataManager.shared.viewContext)
        entity.setValue(id, forKey: "id")
        entity.setValue("Фото \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))", forKey: "title")
        entity.setValue(fileName, forKey: "fileName")
        entity.setValue(Date(), forKey: "createdAt")
        entity.setValue(thumbnail, forKey: "thumbnail")

        CoreDataManager.shared.save()
        fetchDocuments()
    }

}
