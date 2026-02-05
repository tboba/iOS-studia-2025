//
//  Cart.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import Foundation
import Combine

final class Cart: ObservableObject {
    @Published var items: [String: Int] = [:]
    
    func add(_ productName: String) {
        items[productName, default: 0] += 1
    }
    
    func updateQuantity(for productName: String, to quantity: Int) {
        if quantity <= 0 {
            items.removeValue(forKey: productName)
        } else {
            items[productName] = quantity
        }
    }
    
    func remove(_ productName: String) {
        items.removeValue(forKey: productName)
    }
    
    func clear() {
        items.removeAll()
    }
    
    var totalItems: Int {
        items.values.reduce(0, +)
    }
    
    var sortedItems: [(key: String, value: Int)] {
        items.sorted { $0.key < $1.key }
    }
}

