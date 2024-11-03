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
    
    private let emptyStateView: View = {
        let view = View()
        let label = Label(font: .preferredFont(forTextStyle: .title3))
        label.text = "Apply for your first loan by tapping the plus button"
        label.textAlignment = .center
        label.layoutMargins = .defaultInsets
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addLoan))
        setupSubviews()
    }
    
    @objc func addLoan() {
        presentLoan(Loan())
    }
    
    private func presentLoan(_ loan: Loan) {
        let loanNavigationController = UINavigationController(rootViewController: PersonalInformationViewController(loan: loan))
        loanNavigationController.modalPresentationStyle = .fullScreen
        
        navigationController?.present(loanNavigationController, animated: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modelData = Model.loadLoans()
        tableView.reloadData()
        
        updateEmptyState()
    }
    
    func updateEmptyState() {
        emptyStateView.isHidden = !modelData.isEmpty
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withCellClass: HomeTableViewCell.self)
        let loan = modelData[indexPath.row]
        cell.viewModel = HomeTableViewModel(name: loan.fullName, loanAmount: loan.desiredLoanAmount, dateSubmitted: loan.dateSubmitted, isComplete: loan.isComplete)
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
        
        updateEmptyState()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loan = modelData[indexPath.row]
        presentLoan(loan)
    }
}

#Preview {
    return UINavigationController(rootViewController: HomeViewController())
}
