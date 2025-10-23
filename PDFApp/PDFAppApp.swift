//
//  PDFAppApp.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI

@main
struct PDFAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
