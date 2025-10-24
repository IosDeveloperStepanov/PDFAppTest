//
//  PDFAppApp.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import SwiftUI

@main
struct PDFAppApp: App {
    
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some Scene {
        WindowGroup {
                    if hasSeenWelcome {
                        DocumentsListView()
                    } else {
                        WelcomeView()
                    }
                }
    }
}
