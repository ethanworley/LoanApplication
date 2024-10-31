//
//  Model.swift
//  LoanApplication
//
//  Created by Ethan Worley on 31/10/2024.
//

import Foundation

private extension String {
    static let defaultsKey = "loans"
}

enum Model {
    static let userDefaults = UserDefaults.standard
    
    static let jsonDecoder = JSONDecoder()
    
    static func loadLoans() -> [Loan] {
        guard let data = userDefaults.data(forKey: .defaultsKey),
              let loans = try? jsonDecoder.decode([Loan].self, from: data)else {
            return []
        }
        
        return loans
    }
    
    static let jsonEncoder = JSONEncoder()
    
    static func saveLoans(_ loans: [Loan]) {
        let data = try! jsonEncoder.encode(loans)
        userDefaults.set(data, forKey: .defaultsKey)
    }
    
    static func saveLoan(_ loan: Loan) {
        var loans = loadLoans()
        if let index = loans.firstIndex(of: loan) {
            loans[index] = loan
        } else {
            loans.append(loan)
        }
        saveLoans(loans)
    }
    
    static func deleteLoan(_ loan: Loan) {
        var loans = loadLoans()
        loans.removeAll(where: {$0 == loan})
        saveLoans(loans)
    }
}

class Loan: Codable, Equatable {
    static func == (lhs: Loan, rhs: Loan) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Personal Information
    var fullName: String?
    var emailAddress: String?
    var phoneNumber: String?
    var gender: Gender?
    var address: String?
    
    // Financial Information
    var annualIncome: Decimal?
    var desiredLoanAmount: Decimal?
    var irdNumber: String?
    
    // State
    let id: UUID
    var dateSubmitted: Date?
    var isComplete: Bool
    
    init(fullName: String? = nil, emailAddress: String? = nil, phoneNumber: String? = nil, gender: Gender? = nil, address: String? = nil, annualIncome: Decimal? = nil, desiredLoanAmount: Decimal? = nil, irdNumber: String? = nil, id: UUID = UUID(), dateSubmitted: Date? = nil, isComplete: Bool = false) {
        self.fullName = fullName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.gender = gender
        self.address = address
        self.annualIncome = annualIncome
        self.desiredLoanAmount = desiredLoanAmount
        self.irdNumber = irdNumber
        self.id = id
        self.dateSubmitted = dateSubmitted
        self.isComplete = isComplete
    }
}

enum Gender: String, Codable, CaseIterable {
    case male, female, other
}
