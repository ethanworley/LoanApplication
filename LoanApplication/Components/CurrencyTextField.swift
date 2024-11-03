//
//  CurrencyTextField.swift
//  LoanApplication
//
//  Created by Ethan Worley on 02/11/2024.
//

import UIKit

class CurrencyTextField: FormField, FormFieldProtocol {
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyboardType = .decimalPad
        textAlignment = .right
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var value: Decimal? {
        didSet {
            guard let value, let formattedText = Self.currencyFormatter.string(from: NSDecimalNumber(decimal: value)) else {
                return
            }
            text = formattedText
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let cleanedText = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let decimalValue = (Decimal(string: cleanedText) ?? 0) / 100
        if let formattedText = Self.currencyFormatter.string(from: NSDecimalNumber(decimal: decimalValue)) {
            value = decimalValue
            textField.text = formattedText
        }
        return false
    }
}

#Preview {
    let textField = CurrencyTextField()
    textField.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
    return textField
}
