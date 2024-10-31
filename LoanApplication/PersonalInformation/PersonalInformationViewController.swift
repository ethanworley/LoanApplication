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
        }
    }
}

class PersonalInformationViewController: UIViewController {
    private let fullNameField = TextFieldComponent(title: "Full Name")
    private let emailAddressField = TextFieldComponent(title: "Email Address", placeholder: "name@example.com")
    private let phoneNumberField = TextFieldComponent(title: "Phone Number", placeholder: "+64 21 123 456")
    private let genderField = MenuComponent(title: "Gender", placeholder: "Select", options: Gender.allCases)
    private let addressField = TextFieldComponent(title: "Address", placeholder: "123 Example Street")
    
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
    
    private func setupSubviews() {
        title = "Personal Information"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(cancel))
        
        let verticalStack = StackView(arrangedSubviews: [fullNameField, emailAddressField, phoneNumberField, genderField, addressField], axis: .vertical)
        
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
        nextButton.addTarget(self, action: #selector(moveToFinancialInformation), for: .touchUpInside)
        
        fullNameField.textContentType = .name
        fullNameField.returnKeyType = .next
        fullNameField.delegate = self
        emailAddressField.textContentType = .emailAddress
        emailAddressField.keyboardType = .emailAddress
        emailAddressField.autocapitalizationType = .none
        emailAddressField.returnKeyType = .next
        emailAddressField.delegate = self
        phoneNumberField.textContentType = .telephoneNumber
        phoneNumberField.keyboardType = .phonePad
        phoneNumberField.returnKeyType = .next
        phoneNumberField.delegate = self
        addressField.textContentType = .fullStreetAddress
        addressField.returnKeyType = .done
        addressField.delegate = self
    }
    
    @objc func cancel() {
        navigationController?.dismiss(animated: true)
    }
    
    private func updateLoan() {
        loan.fullName = fullNameField.text
        loan.emailAddress = emailAddressField.text
        loan.phoneNumber = phoneNumberField.text
        loan.address = addressField.text
        loan.gender = genderField.selectedOption
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
        var isValid: Bool = true
        if fullNameField.text == nil || fullNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            fullNameField.error = ValidationError.fullNameInvalid
            isValid = false
        }
        
        if !isValidEmail(emailAddressField.text) {
            emailAddressField.error = ValidationError.emailInvalid
            isValid = false
        }
        
        if !isValidNZPhoneNumber(phoneNumberField.text) {
            phoneNumberField.error = ValidationError.emailInvalid
            isValid = false
        }
        
        if genderField.selectedOption == nil {
            genderField.error = ValidationError.genderInvalid
            isValid = false
        }
        
        return isValid
    }
    
    func isValidEmail(_ email: String?) -> Bool {
        guard let email else {
            return false
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func isValidNZPhoneNumber(_ phoneNumber: String?) -> Bool {
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

extension PersonalInformationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullNameField.textField:
            emailAddressField.textField.becomeFirstResponder()
            
        case emailAddressField.textField:
            phoneNumberField.textField.becomeFirstResponder()
            
        case phoneNumberField.textField:
            phoneNumberField.textField.resignFirstResponder()
            
        case addressField.textField:
            addressField.textField.resignFirstResponder()
            
        default: break
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case fullNameField.textField:
            fullNameField.error = nil
            
        case emailAddressField.textField:
            emailAddressField.error = nil
            
        case phoneNumberField.textField:
            phoneNumberField.error = nil
            
        case addressField.textField:
            addressField.error = nil
            
        default: break
        }
    }
}

#Preview {
    return UINavigationController(rootViewController: PersonalInformationViewController(loan: Loan()))
}
