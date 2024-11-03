//
//  FinancialInformationViewController.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class FinancialInformationViewController: UIViewController {
    private let annualIncomeField: CurrencyFieldComponent = CurrencyFieldComponent(title: "Annual Income", placeholder: "$90,000.00") { annualIncome in
        guard let annualIncome, annualIncome > 0 else {
            throw ValidationError.incomeInvalid
        }
    }
    
    private let desiredLoanAmountField: CurrencyFieldComponent = CurrencyFieldComponent(title: "Desired Loan Amount", placeholder: "$20,000.00") { loanAmount in
        if loanAmount == nil {
            throw ValidationError.loanAmountInvalid
        }
    }
    
    private let irdNumberField: IRDNumberTextFieldComponent = IRDNumberTextFieldComponent(title: "IRD Number", placeholder: "010-000-000") { irdNumber in
        guard let irdNumber, irdNumber.count == 11 else { // 9 numbers + 2 dashes
            throw ValidationError.irdNumberInvalid
        }
    }
    
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
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let bottomContentStack = StackView(arrangedSubviews: [], axis: .vertical)
    
    private lazy var fieldOrder: [FormFieldComponent] = [annualIncomeField, desiredLoanAmountField, irdNumberField]
    
    private var loan: Loan
    
    private func setupSubviews() {
        title = "Financial Information"
        view.backgroundColor = .systemBackground
        
        let verticalStack = StackView(arrangedSubviews: [annualIncomeField, desiredLoanAmountField, irdNumberField], axis: .vertical)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(verticalStack)
        
        let horizontalStack = StackView(arrangedSubviews: [saveButton, nextButton], axis: .horizontal, layoutMargins: .zero)
        horizontalStack.spacing = 16.0
        bottomContentStack.addArrangedSubview(horizontalStack)
        bottomContentStack.addArrangedSubview(progressIndicator)
        view.addSubview(bottomContentStack)
        bottomContentStack.backgroundColor = .systemBackground
        bottomContentStack.layer.shadowColor = UIColor.label.cgColor
        bottomContentStack.layer.shadowOpacity = 0.1
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            verticalStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            verticalStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            bottomContentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomContentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomContentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        saveButton.addTarget(self, action: #selector(saveLoan), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(moveToReviewAndSubmit), for: .touchUpInside)
        
        annualIncomeField.returnKeyType = .next
        annualIncomeField.showToolbar = true
        desiredLoanAmountField.returnKeyType = .next
        desiredLoanAmountField.showToolbar = true
        irdNumberField.keyboardType = .numberPad
        irdNumberField.returnKeyType = .done
        irdNumberField.showToolbar = true
        
        annualIncomeField.value = loan.annualIncome
        desiredLoanAmountField.value = loan.desiredLoanAmount
        irdNumberField.value = loan.irdNumber
        
        annualIncomeField.onMoveToNextFormField = { [unowned self] in
            do {
                try validateLoanToIncome()
            } catch let error {
                desiredLoanAmountField.error = error
            }
            desiredLoanAmountField.becomeFirstResponder()
        }
        
        desiredLoanAmountField.onMoveToNextFormField = { [unowned self] in
            do {
                try validateLoanToIncome()
            } catch let error {
                desiredLoanAmountField.error = error
            }
            irdNumberField.becomeFirstResponder()
        }
        
        irdNumberField.onMoveToNextFormField = { [unowned self] in
            irdNumberField.resignFirstResponder()
        }
    }
    
    private func validateLoanToIncome() throws {
        guard let incomeAmount = annualIncomeField.value, let loanAmount = desiredLoanAmountField.value else {
            return // no error here as user may still be filling form
        }
        
        let threshold: Decimal = 0.5 // 50% of annual income
        if loanAmount / incomeAmount > threshold {
            throw ValidationError.loanExceedsLimit
        }
    }
    
    private func validateFields() -> Bool {
        var isValid = true
        for field in fieldOrder {
            isValid = field.validate() && isValid
        }
        do {
            try validateLoanToIncome()
        } catch let error {
            desiredLoanAmountField.error = error
            isValid = false
        }
        
        return isValid
    }
    
    func updateLoan() {
        loan.annualIncome = annualIncomeField.value
        loan.desiredLoanAmount = desiredLoanAmountField.value
        loan.irdNumber = irdNumberField.value
    }
    
    @objc func saveLoan() {
        updateLoan()
        Model.saveLoan(loan)
        navigationController?.dismiss(animated: true)
    }
    
    @objc func moveToReviewAndSubmit() {
        updateLoan()
        guard validateFields() else {
            return
        }
        navigationController?.pushViewController(ReviewAndSubmitViewController(loan: loan), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateLoan()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = bottomContentStack.bounds.height - bottomContentStack.safeAreaInsets.bottom
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
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
