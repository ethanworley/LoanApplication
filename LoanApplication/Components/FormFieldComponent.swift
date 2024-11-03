//
//  TextFieldComponent.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//
import UIKit

class GenderFieldComponent: AbstractFormFieldComponent<PickerTextField<Gender>> {
    init(title: String, placeholder: String? = nil, isEnabled: Bool = true, performValidation: ((Gender?) throws -> ())? = nil) {
        super.init(title: title, placeholder: placeholder, isEnabled: isEnabled, formField: PickerTextField<Gender>(options: Gender.allCases), performValidation: performValidation)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CurrencyFieldComponent: AbstractFormFieldComponent<CurrencyTextField> {
    init(title: String, placeholder: String? = nil, isEnabled: Bool = true, performValidation: ((Decimal?) throws -> ())? = nil) {
        super.init(title: title, placeholder: placeholder, isEnabled: isEnabled, formField: CurrencyTextField(), performValidation: performValidation)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TextFieldComponent: AbstractFormFieldComponent<TextField> {
    init(title: String, placeholder: String? = nil, isEnabled: Bool = true, performValidation: ((String?) throws -> ())? = nil) {
        super.init(title: title, placeholder: placeholder, isEnabled: isEnabled, formField: TextField(), performValidation: performValidation)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class IRDNumberTextFieldComponent: AbstractFormFieldComponent<IRDNumberTextField> {
    init(title: String, placeholder: String? = nil, isEnabled: Bool = true, performValidation: ((String?) throws -> ())? = nil) {
        super.init(title: title, placeholder: placeholder, isEnabled: isEnabled, formField: IRDNumberTextField(), performValidation: performValidation)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AbstractFormFieldComponent<Field: FormField & FormFieldProtocol>: FormFieldComponent {
    private let field: Field
    var value: Field.ValueType? {
        get {
            return field.value
        }
        set {
            field.value = newValue
        }
    }
    
    private let performValidation: ((Field.ValueType?) throws -> ())?
    
    fileprivate init(title: String, placeholder: String? = nil, isEnabled: Bool = true, formField: Field, performValidation: ((Field.ValueType?) throws -> ())? = nil) {
        self.performValidation = performValidation
        self.field = formField
        super.init(title: title, placeholder: placeholder, isEnabled: isEnabled, formField: formField)
        
        field.onDidBeginEditing = { [unowned self] in
            self.error = nil
        }
        
        field.onDidEndEditing = { [unowned self] in
            self.validate()
        }
    }
    
    @discardableResult override func validate() -> Bool {
        do {
            try self.performValidation?(self.value)
        } catch let error {
            self.error = error
            return false
        }
        return true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FormFieldComponent: View {
    private let titleLabel = Label(font: .preferredFont(forTextStyle: .headline))
    private let formField: FormField
    
    private let errorLabel = {
        let label = Label()
        label.textColor = .systemRed
        return label
    }()
    
    private lazy var errorHeightConstraint: NSLayoutConstraint = {
        return errorLabel.heightAnchor.constraint(equalToConstant: 0.0)
    }()
    
    var onMoveToNextFormField: (() -> Void)? {
        get {
            return formField.onMoveToNextFormField
        }
        set {
            formField.onMoveToNextFormField = newValue
        }
    }
    
    var error: Error? {
        didSet {
            guard let error else {
                hideError()
                return
            }
            showError(error)
        }
    }
    
    var isEnabled: Bool {
        get {
            return formField.isEnabled
        }
        set {
            formField.isEnabled = newValue
        }
    }
    
    var textContentType: UITextContentType {
        get {
            return formField.textContentType
        }
        set {
            formField.textContentType = newValue
        }
    }
    
    var keyboardType: UIKeyboardType {
        get {
            return formField.keyboardType
        }
        set {
            formField.keyboardType = newValue
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        get {
            return formField.returnKeyType
        }
        set {
            formField.returnKeyType = newValue
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return formField.autocapitalizationType
        }
        set {
            formField.autocapitalizationType = newValue
        }
    }
    
    var showToolbar: Bool {
        get {
            return formField.showToolbar
        }
        set {
            formField.showToolbar = newValue
        }
    }
    
    fileprivate init(title: String, placeholder: String? = nil, isEnabled: Bool = true, formField: FormField) {
        self.formField = formField
        super.init(frame: .zero)
        setupSubviews()
        titleLabel.text = String(format: "%@: ", title)
        formField.placeholder = placeholder ?? title
        self.isEnabled = isEnabled
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideError() {
        errorHeightConstraint.isActive = true
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut]) { [unowned self] in
            self.layoutIfNeeded()
        } completion: { [unowned self] _ in
            self.errorLabel.text = nil
        }
    }
    
    func showError(_ error: Error) {
        errorHeightConstraint.isActive = false
        self.errorLabel.text = error.localizedDescription
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut]) { [unowned self] in
            self.layoutIfNeeded()
        }
    }
    
    func setupSubviews() {
        let horizontalStack = StackView(arrangedSubviews: [titleLabel, formField], axis: .horizontal, layoutMargins: .zero)
        let verticalStack = StackView(arrangedSubviews: [horizontalStack, errorLabel], axis: .vertical)
        verticalStack.alignment = .fill
        verticalStack.spacing = 0
        addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        formField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        errorHeightConstraint.isActive = true
    }
    
    @discardableResult func validate() -> Bool {
        fatalError("function should be implemented in subclass")
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        guard !super.becomeFirstResponder() else {
            return true
        }
        
        return formField.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        guard !super.resignFirstResponder() else {
            return true
        }
        
        return formField.resignFirstResponder()
    }
}

#Preview {
    let textField = CurrencyFieldComponent(title: "Preview")
    textField.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
    return textField
}
