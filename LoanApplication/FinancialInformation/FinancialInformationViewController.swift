//
//  FinancialInformationViewController.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class FinancialInformationViewController: UIViewController {
    let annualIncomeField: TextFieldComponent = TextFieldComponent(title: "Annual Income", placeholder: "$90,000.00")
    let desiredLoanAmountField: TextFieldComponent = TextFieldComponent(title: "Desired Loan Amount", placeholder: "$20,000.00")
    let irdNumberField: TextFieldComponent = TextFieldComponent(title: "IRD Number", placeholder: "10-000-000")
    
    private let saveButton = {
        let button = RoundedButton(title: "Save")
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    private let nextButton = {
        let button = RoundedButton(title: "Next")
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let progressIndicator = {
        let progressIndicator = ProgressIndicator()
        progressIndicator.currentStep = 2
        progressIndicator.stepCount = 3
        return progressIndicator
    }()
    
    private var loan: Loan
    
    private func setupSubviews() {
        title = "Financial Information"
        view.backgroundColor = .systemBackground
        
        let verticalStack = StackView(arrangedSubviews: [annualIncomeField, desiredLoanAmountField, irdNumberField], axis: .vertical)
        
        view.addSubview(verticalStack)
        
        let horizontalStack = StackView(arrangedSubviews: [saveButton, nextButton], axis: .horizontal, layoutMargins: .zero)
        horizontalStack.spacing = 16.0
        let bottomContentStack = StackView(arrangedSubviews: [horizontalStack, progressIndicator], axis: .vertical)
        view.addSubview(bottomContentStack)
        
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: verticalStack.topAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            
            bottomContentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomContentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomContentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        saveButton.addTarget(self, action: #selector(saveLoan), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(moveToReviewAndSubmit), for: .touchUpInside)
    }
    
    func updateLoan() {
        loan.annualIncome = Self.amountFormatter.number(from: annualIncomeField.text ?? "")?.decimalValue
        loan.desiredLoanAmount = Self.amountFormatter.number(from: desiredLoanAmountField.text ?? "")?.decimalValue
        loan.irdNumber = irdNumberField.text
    }
    
    private static let amountFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    @objc func saveLoan() {
        updateLoan()
        Model.saveLoan(loan)
        navigationController?.dismiss(animated: true)
    }
    
    @objc func moveToReviewAndSubmit() {
        updateLoan()
        navigationController?.pushViewController(ReviewAndSubmitViewController(loan: loan), animated: true)
    }
    
    init(loan: Loan) {
        self.loan = loan
        super.init(nibName: nil, bundle: nil)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    return UINavigationController(rootViewController: FinancialInformationViewController(loan: Loan()))
}
