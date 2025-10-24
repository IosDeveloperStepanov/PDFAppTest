//
//  PDFReaderView.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI
import PDFKit

struct PDFReaderView: View {
    let document: PDFItem
    
    @State private var pdfDocument: PDFDocument?
    @State private var pdfView = PDFView()
    @State private var selectedPageIndex: Int = 0
    @State private var thumbnails: [UIImage] = []
    
    @State private var showSpeechSheet = false
    @State private var isRecording = false
    @State private var recognizedText: String = ""
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack(spacing: 0) {
            if let pdfDocument = pdfDocument {
                Group {
                    PDFKitView(document: pdfDocument, pdfView: $pdfView)
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(thumbnails.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 110)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(index == selectedPageIndex ? Color.accentColor : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedPageIndex = index
                                        if let page = pdfDocument.page(at: index) {
                                            pdfView.go(to: page)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .background(Color(UIColor.systemGray6))
                }
                .sheet(isPresented: $showSpeechSheet) {
                    SpeechToTextView(
                        speechRecognizer: speechRecognizer,
                        isPresented: $showSpeechSheet
                    ) { text in
                        addTextPage(text: text)
                    }
                }
            } else {
                ProgressView("Загрузка PDF...")
                    .onAppear(perform: loadPDF)
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showSpeechSheet = true
                    } label: {
                        Label("Добавить новую страницу (диктовка)", systemImage: "mic")
                    }
                    Button() {
                        rotateCurrentPage()
                    } label: {
                        Label("Повернуть страницу", systemImage: "rectangle.portrait.rotate")
                    }
                    Button(role: .destructive) {
                        removeSelectedPage()
                    } label: {
                        Label("Удалить выбранную страницу", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private func loadPDF() {
        guard let pdf = PDFDocument(url: document.fileURL) else { return }
        pdfDocument = pdf
        generateThumbnails(from: pdf)
    }
    
    private func generateThumbnails(from pdf: PDFDocument) {
        thumbnails = []
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i) {
                let pageRect = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 110))
                let image = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(CGRect(origin: .zero, size: CGSize(width: 80, height: 110)))
                    ctx.cgContext.saveGState()
                    let scale = min(80 / pageRect.width, 110 / pageRect.height)
                    ctx.cgContext.scaleBy(x: scale, y: scale)
                    ctx.cgContext.translateBy(x: 0, y: pageRect.height)
                    ctx.cgContext.scaleBy(x: 1, y: -1)
                    ctx.cgContext.drawPDFPage(page.pageRef!)
                    ctx.cgContext.restoreGState()
                }
                thumbnails.append(image)
            }
        }
    }
    
    private func generateThumbnail(for page: PDFPage) -> UIImage {
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 110))
        let image = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: CGSize(width: 80, height: 110)))
            ctx.cgContext.saveGState()
            let scale = min(80 / pageRect.width, 110 / pageRect.height)
            ctx.cgContext.scaleBy(x: scale, y: scale)
            ctx.cgContext.translateBy(x: 0, y: pageRect.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            ctx.cgContext.drawPDFPage(page.pageRef!)
            ctx.cgContext.restoreGState()
        }
        return image
    }

    private func removeSelectedPage() {
        guard let pdf = pdfDocument,
              selectedPageIndex < pdf.pageCount,
              let _ = pdf.page(at: selectedPageIndex)
        else { return }
        
        pdf.removePage(at: selectedPageIndex)
        pdf.write(to: document.fileURL)
        generateThumbnails(from: pdf)
        selectedPageIndex = min(selectedPageIndex, max(pdf.pageCount - 1, 0))
        if let newPage = pdf.page(at: selectedPageIndex) {
            pdfView.go(to: newPage)
        }
    }
    
    private func addTextPage(text: String) {
        guard let pdf = pdfDocument else { return }

        guard let newPage = PDFPage(image: textToImage(text: text)) else { return }

        pdf.insert(newPage, at: pdf.pageCount)

        pdf.write(to: document.fileURL)

        pdfDocument = PDFDocument(url: document.fileURL)

        if let page = pdf.page(at: pdf.pageCount - 1) {
            let thumbnail = generateThumbnail(for: page)
            thumbnails.append(thumbnail)
            selectedPageIndex = pdf.pageCount - 1
            pdfView.go(to: page)
        }
    }


    private func textToImage(text: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 595, height: 842)) // A4
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 595, height: 842))

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .paragraphStyle: paragraph
            ]

            text.draw(in: CGRect(x: 40, y: 40, width: 515, height: 762), withAttributes: attrs)
        }
    }
    
    private func rotateCurrentPage() {
        guard let pdf = pdfDocument,
              let currentPage = pdfView.currentPage else { return }
        
        currentPage.rotation = (currentPage.rotation + 90) % 360
        pdf.write(to: document.fileURL)
    }

}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    @Binding var pdfView: PDFView
    
    func makeUIView(context: Context) -> PDFView {
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = document
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    PDFReaderView(document: .init(id: .init(), title: "123", fileName: "123", createdAt: .now, thumbnailData: nil))
}
