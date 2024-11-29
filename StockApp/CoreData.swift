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
    
    

    // Save a stock symbol with category and rank
    func saveStockSymbol(_ symbol: String, category: String, rank: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: "StockSymbol", in: context) else {
            fatalError("Failed to find entity description for StockSymbol")
        }

        let stockSymbol = StockSymbol(entity: entity, insertInto: context)
        stockSymbol.symbol = symbol
        stockSymbol.category = category
        stockSymbol.rank = rank // Save the rank as well

        saveContext()
    }


    // Fetch all saved stock symbols with their ranks
    func fetchStockSymbols() -> [(category: String, symbols: [Stock])] {
        let fetchRequest: NSFetchRequest<StockSymbol> = StockSymbol.fetchRequest()
        var result: [(category: String, symbols: [Stock])] = []

        do {
            let stockSymbols = try context.fetch(fetchRequest)
            let grouped = Dictionary(grouping: stockSymbols, by: { $0.category ?? "Active" })

            for (category, symbols) in grouped {
                let stocks = symbols.compactMap { stockSymbol -> Stock? in
                    guard let symbol = stockSymbol.symbol,
                          let rank = stockSymbol.rank else { return nil }
                    return Stock(symbol: symbol, shortName: symbol, regularMarketPrice: 0.0, rank: rank)
                }
                result.append((category: category, symbols: stocks))
            }
        } catch {
            print("Error fetching stock symbols: \(error.localizedDescription)")
        }

        return result
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
