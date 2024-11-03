//
//  FormField.swift
//  LoanApplication
//
//  Created by Ethan Worley on 02/11/2024.
//
import UIKit

protocol FormFieldProtocol: FormField {
    associatedtype ValueType
    var value: ValueType? { get set }
}

class TextField: FormField, FormFieldProtocol {
    var value: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }
}

class FormField: UITextField {
    
    var onMoveToNextFormField: (() -> Void)?
    var onDidBeginEditing: (() -> Void)?
    var onDidEndEditing: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        borderStyle = .roundedRect
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var returnKeyType: UIReturnKeyType {
        didSet {
            createUIBarButton(returnKeyType)
        }
    }
    
    private let toolBar: UIToolbar = UIToolbar()
    var showToolbar: Bool = false {
        didSet {
            if showToolbar {
                inputAccessoryView = toolBar
            } else {
                inputAccessoryView = nil
            }
        }
    }
    
    private func createUIBarButton(_ returnKeyType: UIReturnKeyType) {
        let title: String
        let selector: Selector
        switch returnKeyType {
        case .next:
            title = "Next"
            selector = #selector(nextAction)
        case .done:
            title = "Done"
            selector = #selector(dismissAction)
        default:
            fatalError("unsupported returnKeyType: \(returnKeyType)")
        }
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
        toolBar.sizeToFit()
        toolBar.setItems([spacer, button], animated: true)
        toolBar.updateConstraintsIfNeeded()
    }
    
    @objc private func dismissAction() {
        resignFirstResponder()
    }
    
    @objc private func nextAction() {
        onMoveToNextFormField?()
    }
}

extension FormField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onMoveToNextFormField?()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onDidBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        onDidEndEditing?()
    }
}
