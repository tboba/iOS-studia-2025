//
//  TransactionStore.swift
//  zadanie6
//
//  Created by Tymoteusz on 1/24/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TransactionStore: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    
    private static let storageKey = "saved_transactions"
    
    private var documentsURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("transactions_data.json")
    }
    
    init() {
        loadFromDisk()
    }
    
    func record(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
        persistToDisk()
    }
    
    func delete(at indices: IndexSet) {
        transactions.remove(atOffsets: indices)
        persistToDisk()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        persistToDisk()
    }
    
    func clearAll() {
        transactions.removeAll()
        persistToDisk()
    }
    
    var hasTransactions: Bool {
        !transactions.isEmpty
    }
    
    var totalSpent: Double {
        transactions.reduce(0) { $0 + $1.totalAmount }
    }
    
    private func persistToDisk() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(transactions)
            try encoded.write(to: documentsURL, options: .atomicWrite)
        } catch {
            print("[TransactionStore] Failed to save: \(error.localizedDescription)")
        }
    }
    
    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: documentsURL.path) else {
            transactions = []
            return
        }
        
        do {
            let data = try Data(contentsOf: documentsURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            transactions = try decoder.decode([Transaction].self, from: data)
        } catch {
            print("[TransactionStore] Failed to load: \(error.localizedDescription)")
            transactions = []
        }
    }
}
