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
        
        if !savedSymbols.isEmpty {
            fetchStockData(for: savedSymbols)
        } else {
            // Provide fallback if no stocks are saved
            print("No saved stock symbols.")
        }
    }
    
    private func fetchStockData(for symbols: [String]) {
        let api = StockAPI()
        
        api.fetchStockData(for: symbols) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stocks):
                    // Assume first half is Active, second half is Watching
                    self?.activeStocks = Array(stocks.prefix(2))
                    self?.watchingStocks = Array(stocks.suffix(from: 2))
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
        addStockVC.onAddStock = { [weak self] newStock, list in
            guard let self = self else { return }
            
            // Save stock symbol to Core Data
            CoreDataManager.shared.saveStockSymbol(newStock.symbol)
            
            // Add stock to the appropriate list in memory
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
        cell.textLabel?.text = "\(stock.shortName) (\(stock.symbol)) - $\(stock.regularMarketPrice)"
        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchingStocks[indexPath.row]
        print("Selected stock: \(stock.shortName) (\(stock.symbol)) - $\(stock.regularMarketPrice)")
    }
}
