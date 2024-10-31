//
//  ProgressIndicator.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import UIKit
class ProgressIndicator: View {
    private let label = {
        let label = Label(font: .preferredFont(forTextStyle: .caption1))
        label.textAlignment = .center
        return label
    }()
    
    private let background = {
        let view = View()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private let foreground = {
        let view = View()
        view.backgroundColor = .tintColor
        return view
    }()
    
    private lazy var progressWidthConstraint: NSLayoutConstraint = {
        return foreground.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    var stepCount: Int = 3 {
        didSet {
            updateProgress()
        }
    }
    
    var currentStep: Int = 1 {
        didSet {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        let progress = CGFloat(currentStep) / CGFloat(stepCount)
        progressWidthConstraint.isActive = false
        progressWidthConstraint = foreground.widthAnchor.constraint(equalTo: background.widthAnchor, multiplier: progress)
        progressWidthConstraint.isActive = true
        
        label.text = String(format: "Step %i of %i", currentStep, stepCount)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        let verticalStack = StackView(arrangedSubviews: [label, background], axis: .vertical)
        verticalStack.spacing = 8.0
        
        addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            background.heightAnchor.constraint(equalToConstant: 32.0),
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(foreground)
        NSLayoutConstraint.activate([
            foreground.heightAnchor.constraint(equalTo: background.heightAnchor),
            foreground.topAnchor.constraint(equalTo: background.topAnchor),
            foreground.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            foreground.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            progressWidthConstraint
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = foreground.bounds.height * 0.5
        background.layer.cornerRadius = cornerRadius
        foreground.layer.cornerRadius = cornerRadius
    }
}

#Preview {
    let progressIndicator = ProgressIndicator()
    progressIndicator.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
    progressIndicator.currentStep = 69
    progressIndicator.stepCount = 99
    return progressIndicator
}
