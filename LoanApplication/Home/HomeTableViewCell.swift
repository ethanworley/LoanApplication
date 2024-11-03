//
//  HomeTableViewCell.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class HomeTableViewCell: TableViewCell {
    
    //like name, loan amount, and date submitted.
    private let nameLabel = {
        let label = Label(font: .preferredFont(forTextStyle: .title1))
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let draftLabel = {
        let label = Label(font: .preferredFont(forTextStyle: .title1))
        label.text = "Draft"
        label.textColor = .systemGray3
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let loanAmountLabel = Label(font: .preferredFont(forTextStyle: .title2))
    
    private let dateSubmittedLabel = Label(font: .preferredFont(forTextStyle: .title3))
    
    var viewModel: HomeTableViewModel? {
        didSet {
            guard let viewModel else {
                nameLabel.text = nil
                loanAmountLabel.text = nil
                dateSubmittedLabel.text = nil
                return
            }
            
            draftLabel.isHidden = viewModel.isComplete
            nameLabel.text = viewModel.name
            loanAmountLabel.text = viewModel.loanAmount
            dateSubmittedLabel.text = viewModel.dateSubmitted
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        let horizontalStack = StackView(arrangedSubviews: [nameLabel, draftLabel], axis: .horizontal, layoutMargins: .zero)
        horizontalStack.spacing = 10.0
        let stackView = StackView(arrangedSubviews: [horizontalStack, loanAmountLabel, dateSubmittedLabel], axis: .vertical)
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: stackView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
}

#Preview {
    let homeTableViewCell = HomeTableViewCell()
    homeTableViewCell.viewModel = HomeTableViewModel(name: "Preview Loan Cell", loanAmount: 1_000, dateSubmitted: .now, isComplete: false)
    return homeTableViewCell
}
