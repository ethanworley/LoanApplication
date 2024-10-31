//
//  ViewController.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var modelData: [Loan] = Model.loadLoans()

    private let tableView: TableView = {
        let tableView: TableView = TableView()
        tableView.register(HomeTableViewCell.self)
        return tableView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addLoan))
        setupSubviews()
    }
    
    @objc func addLoan() {
        let loanNavigationController = UINavigationController(rootViewController: PersonalInformationViewController(loan: Loan()))
        loanNavigationController.modalPresentationStyle = .fullScreen
        
        navigationController?.present(loanNavigationController, animated: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modelData = Model.loadLoans()
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withCellClass: HomeTableViewCell.self)
        let loan = modelData[indexPath.row]
        cell.viewModel = HomeTableViewModel(name: loan.fullName, loanAmount: loan.desiredLoanAmount, dateSubmitted: loan.dateSubmitted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let loan = modelData[indexPath.row]
        Model.deleteLoan(loan)
        modelData = Model.loadLoans()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

#Preview {
    return UINavigationController(rootViewController: HomeViewController())
}
