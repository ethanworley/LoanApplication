//
//  HomeTableViewCell.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class HomeTableViewCell: TableViewCell {
    
    //like name, loan amount, and date submitted.
    private let nameLabel = Label(font: .preferredFont(forTextStyle: .title1))
    
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
        let stackView = StackView(arrangedSubviews: [nameLabel, loanAmountLabel, dateSubmittedLabel], axis: .vertical)
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: stackView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
        viewModel = HomeTableViewModel(name: "Ethan Worley", loanAmount: 1_000_000, dateSubmitted: .now)
    }
}

#Preview {
    return HomeTableViewCell()
}
