//
//  DetailsViewController.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-12-06.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var roaLabel: UILabel!
    @IBOutlet weak var roeLabel: UILabel!
    @IBOutlet weak var dyLabel: UILabel!
    @IBOutlet weak var peLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    
    @IBOutlet weak var fiftyHigh: UILabel!
    @IBOutlet weak var fiftyLow: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var stockDetailSearchBar: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "StocK`s Details"
        
        // Configure initial UI state
        clearLabels()
        
        // Add target for search button
        searchButton.addTarget(self, action: #selector(searchStockDetails), for: .touchUpInside)
    }
    
    // Clears all labels
    private func clearLabels() {
        roaLabel.text = ""
        roeLabel.text = ""
        peLabel.text = ""
        dyLabel.text = ""
        priceLabel.text = ""
        companySymbolLabel.text = ""
        companyNameLabel.text = ""
    }
    
    // Fetch stock details on search button tap
    @objc private func searchStockDetails() {
        guard let symbol = stockDetailSearchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !symbol.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid stock symbol.")
            return
        }
        
        // Call API to fetch stock details
        fetchStockDetails(for: symbol)
    }
    
    private func fetchStockDetails(for symbol: String) {
        let api = StockAPI()
        
        // Fetch data for the given stock symbol
        api.fetchStockData(for: [symbol]) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let stocks):
                    if let stock = stocks.first {
                        self.updateUI(with: stock)
                    } else {
                        self.showAlert(title: "Error", message: "No details found for stock symbol: \(symbol).")
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to fetch stock data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI(with stock: Stock) {
        // Update labels with fetched data
        companySymbolLabel.text = stock.symbol
        companyNameLabel.text = stock.shortName ?? "N/A"
        priceLabel.text = stock.regularMarketPrice != nil ? "$\(stock.regularMarketPrice!)" : "N/A"
        roaLabel.text = "Trailing P/E: \(stock.trailingPE ?? 0)"
        roeLabel.text = "Forward P/E: \(stock.forwardPE ?? 0)"
        peLabel.text = "Price/Equity: \(stock.trailingPE ?? 0)"
        dyLabel.text = "Dividend Yield: \(stock.dividendYield ?? 0)"
        fiftyHigh.text = "Fifty Two Week High: \(stock.fiftyTwoWeekHigh ?? 0)"
        fiftyLow.text = "Fifty Two Week Low: \(stock.fiftyTwoWeekLow ?? 0)"
        marketCap.text = "Market Cap: \(stock.marketCap ?? 0)"
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
