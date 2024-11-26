//
//  StockSymbol+CoreDataProperties.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-11-26.
//
//

import Foundation
import CoreData


extension StockSymbol {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockSymbol> {
        return NSFetchRequest<StockSymbol>(entityName: "StockSymbol")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var category: String?

}

extension StockSymbol : Identifiable {

}
