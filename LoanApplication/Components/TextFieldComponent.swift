//
//  TextFieldComponent.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//
import UIKit

class TextFieldComponent: View {
    private let titleLabel = Label(font: .preferredFont(forTextStyle: .headline))
    let textField = TextField()
    
    private let errorLabel = {
        let label = Label()
        label.textColor = .systemRed
        return label
    }()
    
    private lazy var errorHeightConstraint: NSLayoutConstraint = {
        return errorLabel.heightAnchor.constraint(equalToConstant: 0.0)
    }()
    
    var error: Error? {
        didSet {
            guard let error else {
                hideError()
                return
            }
            showError(error)
        }
    }
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var isEnabled: Bool {
        get {
            return textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
        }
    }
    
    var textContentType: UITextContentType {
        get {
            return textField.textContentType
        }
        set {
            textField.textContentType = newValue
        }
    }
    
    var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        get {
            return textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }
    
    var delegate: UITextFieldDelegate? {
        get {
            return textField.delegate
        }
        set {
            textField.delegate = newValue
        }
    }
    
    convenience init(title: String, placeholder: String? = nil, isEnabled: Bool = true) {
        self.init(frame: .zero)
        
        titleLabel.text = String(format: "%@: ", title)
        textField.placeholder = placeholder ?? title
        self.isEnabled = isEnabled
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    func setupSubviews() {
        let horizontalStack = StackView(arrangedSubviews: [titleLabel, textField], axis: .horizontal, layoutMargins: .zero)
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
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        errorHeightConstraint.isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubviews()
    }
}

#Preview {
    let textField = TextFieldComponent(title: "Preview")
    textField.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
    return textField
}
