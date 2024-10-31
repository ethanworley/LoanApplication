//
//  MenuComponent.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//
import UIKit

class MenuComponent<T: RawRepresentable<String>>: View {
    private let titleLabel = Label(font: .preferredFont(forTextStyle: .headline))
    private let menuButton = {
        let button = Button(configuration: .plain())
        button.setTitle("Select", for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let errorLabel = {
        let label = Label()
        label.textColor = .systemRed
        return label
    }()
    
    private lazy var errorHeightConstraint: NSLayoutConstraint = {
        return errorLabel.heightAnchor.constraint(equalToConstant: 0.0)
    }()
    
    var title: String = ""
    
    var options: [T] = [] {
        didSet {
            updateMenuOptions()
        }
    }
    
    func updateMenuOptions() {
        let items = options.map { option in
            return UIAction(title: option.rawValue) { action in
                self.selectedOption = option
                self.error = nil
            }
        }
        menuButton.menu = UIMenu(title: title, children: items)
    }
    
    var selectedOption: T? {
        didSet {
            menuButton.setTitle(selectedOption?.rawValue ?? "Select", for: .normal)
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
            return menuButton.isEnabled
        }
        set {
            menuButton.isEnabled = newValue
        }
    }
    
    convenience init(title: String, placeholder: String? = nil, isEnabled: Bool = true, options: [T]) {
        self.init(frame: .zero)
        self.title = title
        self.options = options
        titleLabel.text = String(format: "%@: ", title)
        updateMenuOptions()
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
        let horizontalStack = StackView(arrangedSubviews: [titleLabel, menuButton, View()], axis: .horizontal, layoutMargins: .zero)
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
        menuButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        errorHeightConstraint.isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
}

#Preview {
    let textField = MenuComponent(title: "Preview", options: Gender.allCases)
    textField.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
    return textField
}
