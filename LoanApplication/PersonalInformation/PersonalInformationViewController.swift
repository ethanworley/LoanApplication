//
//  PersonalInformationViewController.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//
import UIKit

enum ValidationError: LocalizedError {
    case fullNameInvalid
    case emailInvalid
    case phoneNumberInvalid
    case genderInvalid
    case loanExceedsLimit
    case incomeInvalid
    case loanAmountInvalid
    case irdNumberInvalid
    
    var errorDescription: String? {
        switch self {
        case .fullNameInvalid:
            return "Full Name cannot be empty"
            
        case .emailInvalid:
            return "Email address needs to be in a valid format"
            
        case .phoneNumberInvalid:
            return "Phone number needs to be a valid NZ number"
            
        case .genderInvalid:
            return "Please select a gender"
            
        case .loanExceedsLimit:
            return "Loan cannot exceed 50% of annual income"
            
        case .incomeInvalid:
            return "Annual income cannot be empty"
            
        case .loanAmountInvalid:
            return "Loan amount cannot be empty"
            
        case .irdNumberInvalid:
            return "IRD number needs to be in a valid format, for 8 digit IRD numbers, add a leading 0"
        }
    }
}

class PersonalInformationViewController: UIViewController {
    private let fullNameField = TextFieldComponent(title: "Full Name") { fullName in
        if fullName == nil || fullName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            throw ValidationError.fullNameInvalid
        }
    }
    
    private let emailAddressField = TextFieldComponent(title: "Email Address", placeholder: "name@example.com") { email in
        if !PersonalInformationViewController.isValidEmail(email) {
            throw ValidationError.emailInvalid
        }
    }
    
    private let phoneNumberField = TextFieldComponent(title: "Phone Number", placeholder: "+64 21 123 456") { phoneNumber in
        if !PersonalInformationViewController.isValidNZPhoneNumber(phoneNumber) {
            throw ValidationError.phoneNumberInvalid
        }
    }
    
    private let genderField = GenderFieldComponent(title: "Gender", placeholder: "Select") { gender in
        if gender == nil {
            throw ValidationError.genderInvalid
        }
    }
    
    private let addressField = TextFieldComponent(title: "Address", placeholder: "123 Example Street")
    
    private lazy var fieldOrder: [FormFieldComponent] = [fullNameField, emailAddressField, phoneNumberField, genderField, addressField]
    
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
        progressIndicator.currentStep = 1
        progressIndicator.stepCount = 3
        return progressIndicator
    }()
    
    private var loan: Loan
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let bottomContentStack = StackView(arrangedSubviews: [], axis: .vertical)
    
    private func setupSubviews() {
        title = "Personal Information"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(cancel))
        
        let verticalStack = StackView(arrangedSubviews: [fullNameField, emailAddressField, phoneNumberField, genderField, addressField], axis: .vertical)
        
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
        nextButton.addTarget(self, action: #selector(moveToFinancialInformation), for: .touchUpInside)
        
        fullNameField.textContentType = .name
        fullNameField.autocapitalizationType = .words
        fullNameField.value = loan.fullName
        emailAddressField.textContentType = .emailAddress
        emailAddressField.keyboardType = .emailAddress
        emailAddressField.autocapitalizationType = .none
        emailAddressField.value = loan.emailAddress
        phoneNumberField.textContentType = .telephoneNumber
        phoneNumberField.keyboardType = .phonePad
        phoneNumberField.showToolbar = true
        phoneNumberField.value = loan.phoneNumber
        genderField.showToolbar = true
        genderField.value = loan.gender
        addressField.textContentType = .fullStreetAddress
        addressField.value = loan.address
        
        for index in 0 ..< fieldOrder.count {
            let nextIndex = index + 1
            let currentField = fieldOrder[index]
            if nextIndex > fieldOrder.count - 1 {
                currentField.returnKeyType = .done
                currentField.onMoveToNextFormField = {
                    currentField.resignFirstResponder()
                }
                continue
            }
            let nextField = fieldOrder[nextIndex]
            currentField.returnKeyType = .next
            currentField.onMoveToNextFormField = { [unowned nextField] in
                nextField.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = bottomContentStack.bounds.height - bottomContentStack.safeAreaInsets.bottom
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @objc func cancel() {
        navigationController?.dismiss(animated: true)
    }
    
    private func updateLoan() {
        loan.fullName = fullNameField.value
        loan.emailAddress = emailAddressField.value
        loan.phoneNumber = phoneNumberField.value
        loan.address = addressField.value
        loan.gender = genderField.value
    }
    
    @objc func saveLoan() {
        updateLoan()
        Model.saveLoan(loan)
        navigationController?.dismiss(animated: true)
    }
    
    @objc func moveToFinancialInformation() {
        updateLoan()
        guard validateFields() else {
            return
        }
        navigationController?.pushViewController(FinancialInformationViewController(loan: loan), animated: true)
    }
    
    func validateFields() -> Bool {
        var isValid = true
        for field in fieldOrder {
            isValid = field.validate() && isValid
        }
        
        return isValid
    }
    
    private static func isValidEmail(_ email: String?) -> Bool {
        guard let email else {
            return false
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    private static func isValidNZPhoneNumber(_ phoneNumber: String?) -> Bool {
        guard let phoneNumber else {
            return false
        }
        let nzPhoneRegex = "^(\\+64|0)[2-9][0-9]{7,9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", nzPhoneRegex)
        return phoneTest.evaluate(with: phoneNumber)
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
    return UINavigationController(rootViewController: PersonalInformationViewController(loan: Loan()))
}
