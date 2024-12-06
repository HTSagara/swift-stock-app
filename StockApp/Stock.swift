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
    let dividendYield: Double?
    let trailingPE: Double?
    let forwardPE: Double?
    let marketCap: Double?
    let fiftyTwoWeekHigh: Double?
    let fiftyTwoWeekLow: Double?


    enum CodingKeys: String, CodingKey {
        case symbol
        case shortName
        case regularMarketPrice
        case rank
        case dividendYield
        case trailingPE
        case forwardPE
        case marketCap
        case fiftyTwoWeekHigh
        case fiftyTwoWeekLow
    }
}




