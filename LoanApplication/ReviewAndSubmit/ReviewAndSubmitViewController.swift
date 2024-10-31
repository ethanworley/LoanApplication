//
//  ReviewAndSubmitViewController.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class ReviewAndSubmitViewController: UIViewController {
    private let personalInformationTitle: Label = Label(font: .preferredFont(forTextStyle: .title2))
    private let fullNameField = TextFieldComponent(title: "Full Name", isEnabled: false)
    private let emailAddressField = TextFieldComponent(title: "Email Address", isEnabled: false)
    private let phoneNumberField = TextFieldComponent(title: "Phone Number", isEnabled: false)
    private let genderField = TextFieldComponent(title: "Gender", placeholder: "", isEnabled: false)
    private let addressField = TextFieldComponent(title: "Address", placeholder: "", isEnabled: false)
    
    private let financialInformationTitle: Label = Label(font: .preferredFont(forTextStyle: .title2))
    private let annualIncomeField: TextFieldComponent = TextFieldComponent(title: "Annual Income", isEnabled: false)
    private let desiredLoanAmountField: TextFieldComponent = TextFieldComponent(title: "Desired Loan Amount", isEnabled: false)
    private let irdNumberField: TextFieldComponent = TextFieldComponent(title: "IRD Number", isEnabled: false)
    
    private let finishButton = {
        let button = RoundedButton(title: "Finish")
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let progressIndicator = {
        let progressIndicator = ProgressIndicator()
        progressIndicator.currentStep = 3
        progressIndicator.stepCount = 3
        return progressIndicator
    }()
    
    private var loan: Loan
    
    private func setupSubviews() {
        title = "Review and Submit"
        personalInformationTitle.text = "Personal Information"
        financialInformationTitle.text = "Financial Information"
        view.backgroundColor = .systemBackground
        
        let verticalStack = StackView(arrangedSubviews: [personalInformationTitle, fullNameField, emailAddressField, phoneNumberField, genderField, addressField, financialInformationTitle, annualIncomeField, desiredLoanAmountField, irdNumberField], axis: .vertical)
        
        view.addSubview(verticalStack)
        
        let bottomContentStack = StackView(arrangedSubviews: [finishButton, progressIndicator], axis: .vertical)
        view.addSubview(bottomContentStack)
        
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: verticalStack.topAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            
            bottomContentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomContentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomContentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        finishButton.addTarget(self, action: #selector(finishLoan), for: .touchUpInside)
        
        fullNameField.text = loan.fullName
        emailAddressField.text = loan.emailAddress
        phoneNumberField.text = loan.phoneNumber
        genderField.text = loan.gender?.rawValue
        addressField.text = loan.address
        annualIncomeField.text = loan.annualIncome?.description
        desiredLoanAmountField.text = loan.desiredLoanAmount?.description
        irdNumberField.text = loan.irdNumber
    }
    
    @objc func finishLoan() {
        loan.dateSubmitted = Date()
        loan.isComplete = true
        Model.saveLoan(loan)
        navigationController?.dismiss(animated: true)
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
    return UINavigationController(rootViewController: ReviewAndSubmitViewController(loan: Loan(fullName: "Ethan")))
}
