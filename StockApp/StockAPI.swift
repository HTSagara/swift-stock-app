//
//  StockAPI.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-11-25.
//
import Foundation

class StockAPI {
    private let baseURL = "https://yahoo-finance166.p.rapidapi.com"
    private let apiKey = "0be02db86fmshe4513d4359696efp17f2edjsnc6371b6043f8"
    private let apiHost = "yahoo-finance166.p.rapidapi.com"
    
    func fetchStockData(for tickers: [String], completion: @escaping (Result<[Stock], Error>) -> Void) {
        let symbols = tickers.joined(separator: ",")
        let endpoint = "/api/market/get-quote"
        guard let url = URL(string: "\(baseURL)\(endpoint)?symbols=\(symbols)&region=US") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                return
            }
            
            // Log the raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(YahooFinanceResponse.self, from: data)
                completion(.success(decodedResponse.quoteResponse.result))
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

}



// Root response structure
struct YahooFinanceResponse: Codable {
    let quoteResponse: QuoteResponse
}

struct QuoteResponse: Codable {
    let result: [Stock]
}

struct YahooFinanceData: Codable {
    let main: YahooFinanceMain
}

struct YahooFinanceMain: Codable {
    let stream: [YahooFinanceStream]
}

// Each article or content in the stream
struct YahooFinanceStream: Codable {
    let content: YahooFinanceContent
}

struct YahooFinanceContent: Codable {
    let title: String
    let contentType: String
    let clickThroughUrl: ClickThroughUrl?
    let pubDate: String
    let finance: YahooFinanceDetails?
}

struct ClickThroughUrl: Codable {
    let url: String?
}

struct YahooFinanceDetails: Codable {
    let stockTickers: [StockTicker]
}

struct StockTicker: Codable {
    let symbol: String
    let regularMarketPrice: Double?
}

struct StockResponse: Codable {
    let result: [Stock]
}


struct FinanceResult: Codable {
    let result: [Stock]
}

