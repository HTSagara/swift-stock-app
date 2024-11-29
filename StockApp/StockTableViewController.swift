//
//  StockTableViewController.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-11-23.
//

import UIKit

class StockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    // Data source
    var activeStocks: [Stock] = []
    var watchingStocks: [Stock] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "stockCell")

        // Add navigation bar buttons
        configureNavigationBar()

        // Fetch saved symbols from Core Data
        let savedSymbols = CoreDataManager.shared.fetchStockSymbols()
        var symbols: [String] = []

        for (category, stocks) in savedSymbols {
            if category == "Active" {
                activeStocks.append(contentsOf: stocks)
            } else if category == "Watching" {
                watchingStocks.append(contentsOf: stocks)
            }
            symbols.append(contentsOf: stocks.map { $0.symbol })
        }

        // Fetch stock data from API
        fetchStockData(for: symbols)
    }

    
    private func fetchStockData(for symbols: [String]) {
        let api = StockAPI()

        api.fetchStockData(for: symbols) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stocks):
                    // Match stocks to the appropriate categories
                    for stock in stocks {
                        if let index = self?.activeStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                            self?.activeStocks[index] = stock
                        } else if let index = self?.watchingStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                            self?.watchingStocks[index] = stock
                        }
                    }
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching stock data: \(error.localizedDescription)")
                }
            }
        }
    }


    
    // MARK: - Configure Navigation Bar
    private func configureNavigationBar() {
        self.title = "Stocks"
        
        // Add Edit button on the left
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))
        
        // Add "+" button on the right
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStock))
    }
    
    // MARK: - Edit Button Action
    @objc private func toggleEditMode() {
        // Toggle editing mode for the table view
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        // Update the button title based on the editing state
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }

    // MARK: - Add Stock Button Action
    @objc private func addStock() {
        let addStockVC = AddStockViewController()
        addStockVC.onAddStock = { [weak self] newStock, list, rank in // Include rank
            guard let self = self else { return }
            
            // Save stock with category and rank
            CoreDataManager.shared.saveStockSymbol(newStock.symbol, category: list, rank: rank)
            
            // Add stock to the appropriate list
            if list == "Active" {
                self.activeStocks.append(newStock)
            } else {
                self.watchingStocks.append(newStock)
            }
            
            self.tableView.reloadData()
        }
        present(addStockVC, animated: true, completion: nil)
    }







    // MARK: - UITableViewDataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Active and Watching
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Active" : "Watching"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? activeStocks.count : watchingStocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath)
        let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchingStocks[indexPath.row]

        // Format the stock details
        let rankEmoji: String
        switch stock.rank {
        case "Cold":
            rankEmoji = "❄️"
        case "Hot":
            rankEmoji = "🔥"
        case "Very Hot":
            rankEmoji = "🔥🔥"
        default:
            rankEmoji = "⚪️"
        }

        let stockDetails = "\(rankEmoji) \(stock.symbol) - \(stock.shortName ?? "Loading...")"
        let price = stock.regularMarketPrice != nil ? String(format: "$ %.2f", stock.regularMarketPrice!) : "Fetching price..."

        // Use multiline text
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(stockDetails)\n\(price)"
        cell.textLabel?.font = .systemFont(ofSize: 16)

        // Set background color based on rank
        switch stock.rank {
        case "Cold":
            cell.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        case "Hot":
            cell.backgroundColor = .systemOrange.withAlphaComponent(0.2)
        case "Very Hot":
            cell.backgroundColor = .systemRed.withAlphaComponent(0.2)
        default:
            cell.backgroundColor = .white
        }

        return cell
    }



    
    private func createRankLabel(for rank: String?) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        
        // Safely unwrap the optional rank
        switch rank {
        case "Cold":
            label.text = "❄️"
        case "Hot":
            label.text = "🔥"
        case "Very Hot":
            label.text = "🔥🔥"
        default:
            label.text = "⚪️"
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Determine the stock to delete
            let stockToDelete = indexPath.section == 0 ? activeStocks[indexPath.row] : watchingStocks[indexPath.row]
            
            // Remove the stock from Core Data
            CoreDataManager.shared.deleteStockSymbol(stockToDelete.symbol)
            
            // Remove the stock from the appropriate list
            if indexPath.section == 0 {
                activeStocks.remove(at: indexPath.row)
            } else {
                watchingStocks.remove(at: indexPath.row)
            }
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}


