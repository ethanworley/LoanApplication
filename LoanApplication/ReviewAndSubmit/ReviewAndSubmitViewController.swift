//
//  ReviewAndSubmitViewController.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class ReviewAndSubmitViewController: UIViewController {
    private let personalInformationTitle = Label(font: .preferredFont(forTextStyle: .title2))
    private let personalInformationEditButton = RoundedButton(title: "Edit Personal Information")
    private let fullNameField = TextFieldComponent(title: "Full Name", isEnabled: false)
    private let emailAddressField = TextFieldComponent(title: "Email Address", isEnabled: false)
    private let phoneNumberField = TextFieldComponent(title: "Phone Number", isEnabled: false)
    private let genderField = GenderFieldComponent(title: "Gender", placeholder: "", isEnabled: false)
    private let addressField = TextFieldComponent(title: "Address", placeholder: "", isEnabled: false)
    
    private let financialInformationTitle = Label(font: .preferredFont(forTextStyle: .title2))
    private let financialInformationEditButton = RoundedButton(title: "Edit Financial Information")
    private let annualIncomeField: CurrencyFieldComponent = CurrencyFieldComponent(title: "Annual Income", isEnabled: false)
    private let desiredLoanAmountField: CurrencyFieldComponent = CurrencyFieldComponent(title: "Desired Loan Amount", isEnabled: false)
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
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private lazy var bottomContentStack = StackView(arrangedSubviews: [finishButton, progressIndicator], axis: .vertical)
    
    private func setupSubviews() {
        title = "Review and Submit"
        personalInformationTitle.text = "Personal Information"
        financialInformationTitle.text = "Financial Information"
        
        view.backgroundColor = .systemBackground
        
        let verticalStack = StackView(arrangedSubviews: [personalInformationTitle, fullNameField, emailAddressField, phoneNumberField, genderField, addressField, personalInformationEditButton, financialInformationTitle, annualIncomeField, desiredLoanAmountField, irdNumberField, financialInformationEditButton], axis: .vertical)
        verticalStack.setCustomSpacing(16.0, after: personalInformationEditButton)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(verticalStack)
        
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
        
        finishButton.addTarget(self, action: #selector(finishLoan), for: .touchUpInside)
        
        fullNameField.value = loan.fullName
        emailAddressField.value = loan.emailAddress
        phoneNumberField.value = loan.phoneNumber
        genderField.value = loan.gender
        addressField.value = loan.address
        annualIncomeField.value = loan.annualIncome
        desiredLoanAmountField.value = loan.desiredLoanAmount
        irdNumberField.value = loan.irdNumber
        
        personalInformationEditButton.addTarget(self, action: #selector(editPersonalInformation), for: .touchUpInside)
        financialInformationEditButton.addTarget(self, action: #selector(editFinancialInformation), for: .touchUpInside)
    }
    
    @objc func editPersonalInformation() {
        guard let viewController = navigationController?.viewControllers.first(where: { type(of: $0) == PersonalInformationViewController.self }) else {
            return
        }
        navigationController?.popToViewController(viewController, animated: true)
    }
    
    @objc func editFinancialInformation() {
        guard let viewController = navigationController?.viewControllers.first(where: { type(of: $0) == FinancialInformationViewController.self }) else {
            return
        }
        navigationController?.popToViewController(viewController, animated: true)
    }
    
    @objc func finishLoan() {
        loan.dateSubmitted = Date()
        loan.isComplete = true
        Model.saveLoan(loan)
        navigationController?.dismiss(animated: true)
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
    return UINavigationController(rootViewController: ReviewAndSubmitViewController(loan: Loan(fullName: "Ethan")))
}
