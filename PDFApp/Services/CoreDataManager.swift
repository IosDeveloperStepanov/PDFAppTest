//
//  CoreDataManager.swift
//  PDFApp
//
//  Created by Игорь Степанов on 23.10.2025.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "PDFApp")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Ошибка загрузки CoreData: \(error.localizedDescription)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Ошибка сохранения CoreData: \(error.localizedDescription)")
            }
        }
    }
}

