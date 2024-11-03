//
//  AutolayoutHelpers.swift
//  LoanApplication
//
//  This class sets up UIKit classes for easy use with autolayout
//
//  Created by Ethan Worley on 31/10/2024.
//
import UIKit

class View: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class TableView: UITableView {
    override init(frame: CGRect = .zero, style: UITableView.Style = .grouped) {
        super.init(frame: frame, style: style)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UITableView {
    func register(_ cellClass: UITableViewCell.Type) {
        let identifier = cellClass.description()
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T>(withCellClass cellClass: T.Type) -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: cellClass.description()) as! T
    }
}

class TableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class Label: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        numberOfLines = 0
    }
    
    convenience init(font: UIFont) {
        self.init()
        self.font = font
    }
}

extension UIEdgeInsets {
    static let defaultInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
}

class StackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        isLayoutMarginsRelativeArrangement = true
    }
    
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, layoutMargins: UIEdgeInsets = .defaultInsets) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.layoutMargins = layoutMargins
    }
}

class Button: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class RoundedButton: Button {
    convenience init(title: String) {
        self.init()
        setTitle(title, for: .normal)
        configuration = .borderedTinted()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = bounds.height * 0.5
        layer.cornerRadius = cornerRadius
    }
}
