//
//  CoreData.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-11-26.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    // Reference to Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StockApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

    // Save a stock symbol
    func saveStockSymbol(_ symbol: String) {
        let stockSymbol = StockSymbol(context: context)
        stockSymbol.symbol = symbol
        saveContext()
    }

    // Fetch all saved stock symbols
    func fetchStockSymbols() -> [String] {
        let fetchRequest: NSFetchRequest<StockSymbol> = StockSymbol.fetchRequest()
        do {
            let stockSymbols = try context.fetch(fetchRequest)
            return stockSymbols.compactMap { $0.symbol }
        } catch {
            print("Error fetching stock symbols: \(error.localizedDescription)")
            return []
        }
    }

    // Delete a stock symbol
    func deleteStockSymbol(_ symbol: String) {
        let fetchRequest: NSFetchRequest<StockSymbol> = StockSymbol.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        do {
            let results = try context.fetch(fetchRequest)
            for stockSymbol in results {
                context.delete(stockSymbol)
            }
            saveContext()
        } catch {
            print("Error deleting stock symbol: \(error.localizedDescription)")
        }
    }
}
