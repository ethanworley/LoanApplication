//
//  HomeTableViewModel.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import Foundation

struct HomeTableViewModel {
    let name: String?
    let loanAmount: String?
    let dateSubmitted: String?
    
    init(name: String?, loanAmount: Decimal?, dateSubmitted: Date?) {
        self.name = name
        if let loanAmount {
            self.loanAmount = Self.amountFormatter.string(from: NSDecimalNumber(decimal: loanAmount))
        } else {
            self.loanAmount = nil
        }
        if let dateSubmitted {
            self.dateSubmitted = Self.dateFormatter.string(from: dateSubmitted)
        } else {
            self.dateSubmitted = nil
        }
    }
    
    private static let amountFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    private static let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
}
