//
//  Stock.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-11-23.
//


struct Stock: Codable {
    let symbol: String
    let shortName: String?
    let regularMarketPrice: Double?
    var rank: String? // User-defined field

    enum CodingKeys: String, CodingKey {
        case symbol
        case shortName
        case regularMarketPrice
        case rank
    }
}




