//
//  IRDNumberTextField.swift
//  LoanApplication
//
//  Created by Ethan Worley on 03/11/2024.
//

import UIKit
class IRDNumberTextField: FormField, FormFieldProtocol {
    var value: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let digitsOnly = updatedText.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        if digitsOnly.count > 9 {
            return false
        }
        let formattedText = formatIRDNumber(digitsOnly)
        textField.text = formattedText
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: formattedText.count) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        return false
    }

    private func formatIRDNumber(_ number: String) -> String {
        var formatted = ""
        let digits = Array(number)
        let dashIndices = [3,6] // assume 9 digit format for simplicity
        
        for (index, digit) in digits.enumerated() {
            if dashIndices.contains(index) {
                formatted += "-"
            }
            formatted += String(digit)
        }
        
        return formatted
    }
}
