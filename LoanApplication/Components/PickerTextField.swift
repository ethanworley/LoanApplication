//
//  PickerTextField.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//
import UIKit

class PickerTextField<T: RawRepresentable<String>>: FormField, FormFieldProtocol, UIPickerViewDelegate, UIPickerViewDataSource {
    private let pickerView = UIPickerView()
    
    var options: [T] = []
    
    var value: T? {
        didSet {
            text = value?.rawValue
        }
    }
    
    init(options: [T]) {
        super.init(frame: .zero)
        self.options = options
        pickerView.delegate = self
        pickerView.dataSource = self
        inputView = pickerView
        showToolbar = true
        
        // prevent cursor from displaying
        tintColor = .clear
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: PickerViewDelegate
    // extensions on generic classes cannot contain @objc functions
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        value = options[row]
    }
    
    // MARK: PickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // disable text selection
        textField.selectedTextRange = nil
    }
}

#Preview {
    let textField = PickerTextField(options: Gender.allCases)
    textField.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
    return textField
}
