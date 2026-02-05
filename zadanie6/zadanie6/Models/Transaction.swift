//
//  Transaction.swift
//  zadanie6
//
//  Created by Tymoteusz on 1/24/26.
//

import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    let customerName: String
    let cardDigits: String
    let totalAmount: Double
    let purchaseDate: Date
    let referenceNumber: String
    let productNames: [String]
    let quantities: [String: Int]
    
    var formattedAmount: String {
        String(format: "%.2f PLN", totalAmount)
    }
    
    var obscuredCardNumber: String {
        "•••• •••• •••• \(cardDigits)"
    }
    
    var itemCount: Int {
        quantities.values.reduce(0, +)
    }
    
    init(
        id: UUID = UUID(),
        customerName: String,
        cardDigits: String,
        totalAmount: Double,
        purchaseDate: Date = Date(),
        referenceNumber: String = UUID().uuidString,
        productNames: [String],
        quantities: [String: Int]
    ) {
        self.id = id
        self.customerName = customerName
        self.cardDigits = cardDigits
        self.totalAmount = totalAmount
        self.purchaseDate = purchaseDate
        self.referenceNumber = referenceNumber
        self.productNames = productNames
        self.quantities = quantities
    }
}

extension Transaction {
    static var preview: Transaction {
        Transaction(
            customerName: "Anna Nowak",
            cardDigits: "1234",
            totalAmount: 159.99,
            productNames: ["iPhone Case", "USB Cable"],
            quantities: ["iPhone Case": 2, "USB Cable": 1]
        )
    }
}
