//
//  AddStockViewController.swift
//  StockApp
//
//  Created by Henrique Sagara on 2024-11-25.
//

import UIKit

class AddStockViewController: UIViewController {
    
    private let ticketTextField = UITextField()
    private let listSegmentedControl = UISegmentedControl(items: ["Active", "Watching"])
    private let addButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let rankSegmentedControl = UISegmentedControl(items: ["❄️ Cold", "🔥 Hot", "🔥🔥 Very Hot"])
    
    var onAddStock: ((Stock, String, String) -> Void)? // Include rank as a String

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    

    private func setupUI() {
        ticketTextField.placeholder = "Enter Stock Code (e.g., AAPL)"
        ticketTextField.borderStyle = .roundedRect
        listSegmentedControl.selectedSegmentIndex = 0
        rankSegmentedControl.selectedSegmentIndex = 0 // Default to "Cold"
        addButton.setTitle("Add Stock", for: .normal)
        addButton.addTarget(self, action: #selector(addStockTapped), for: .touchUpInside)
        activityIndicator.hidesWhenStopped = true
        
        let stackView = UIStackView(arrangedSubviews: [ticketTextField, listSegmentedControl, rankSegmentedControl, addButton, activityIndicator])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            ticketTextField.heightAnchor.constraint(equalToConstant: 40),
            listSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            rankSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    
    @objc private func addStockTapped() {
        guard let ticker = ticketTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !ticker.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid stock code.")
            return
        }
        
        activityIndicator.startAnimating()
        addButton.isEnabled = false
        
        let selectedRankIndex = rankSegmentedControl.selectedSegmentIndex
        let rank = selectedRankIndex == 0 ? "Cold" : selectedRankIndex == 1 ? "Hot" : "Very Hot"
        let selectedList = listSegmentedControl.selectedSegmentIndex == 0 ? "Active" : "Watching"

        let api = StockAPI()
        api.fetchStockData(for: [ticker]) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.addButton.isEnabled = true
                
                switch result {
                case .success(let stocks):
                    if let stock = stocks.first {
                        // Add stock with the selected rank and list
                        var updatedStock = stock
                        updatedStock.rank = rank
                        self?.onAddStock?(updatedStock, selectedList, rank)
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        self?.showAlert(title: "Error", message: "No data found for stock code: \(ticker).")
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to fetch stock data: \(error.localizedDescription)")
                }
            }
        }
    }


    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
