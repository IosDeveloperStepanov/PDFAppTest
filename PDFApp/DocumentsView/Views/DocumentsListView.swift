//
//  DocumentsListView.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI

struct DocumentsListView: View {
    @StateObject private var viewModel = DocumentsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.documents.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        NoDocumentsView()
                        Spacer()
                        Button {
                            viewModel.showSourceDialog = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Загрузить PDF")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor))
                            .foregroundColor(.white)
                        }
                    }
                } else {
                    List {
                        ForEach(viewModel.documents) { doc in
                            NavigationLink(destination: PDFReaderView(document: doc)) {
                                       DocumentCell(item: doc)
                                   }
                                .contextMenu {
                                    Button {
                                        viewModel.share(doc)
                                    } label: {
                                        Label("Поделиться", systemImage: "square.and.arrow.up")
                                    }
                                    Button {
                                        viewModel.mergingFirstDocument = doc
                                        viewModel.showMergePicker = true
                                    } label: {
                                        Label("Объединить", systemImage: "plus.square.on.square")
                                    }
                                    Button(role: .destructive) {
                                        viewModel.delete(doc)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                    
                                    
                                }
                        }
                    }
                    .listStyle(.plain)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                viewModel.showSourceDialog = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                    
                }
            }
            .padding(16)
            .confirmationDialog("Добавить документ", isPresented: $viewModel.showSourceDialog, titleVisibility: .visible) {
                Button("Загрузить из Файлов") {
                    viewModel.showPicker = true
                }
                Button("Загрузить из Галереи") {
                    viewModel.showImagePicker = true
                }
                Button("Отмена", role: .cancel) { }
            }
            .sheet(isPresented: $viewModel.showPicker) {
                DocumentPicker { url in
                    viewModel.importPDF(from: url)
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker { image in
                    viewModel.importImageAsPDF(image)
                }
            }
            .sheet(isPresented: $viewModel.showMergePicker) {
                MergePickerView(
                    documents: viewModel.documents.filter { $0.id != viewModel.mergingFirstDocument?.id },
                    onSelect: { second in
                        viewModel.mergeDocuments(first: viewModel.mergingFirstDocument!, second: second)
                        viewModel.mergingFirstDocument = nil
                        viewModel.showMergePicker = false
                    },
                    onCancel: {
                        viewModel.mergingFirstDocument = nil
                        viewModel.showMergePicker = false
                    }
                )
            }
        }
    }
}

#Preview {
    DocumentsListView()
}
