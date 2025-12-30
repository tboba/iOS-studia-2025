//
//  CartTab.swift
//  zadanie5
//
// Created by Tymoteusz on 12/22/25.
//

import SwiftUI

struct CartTab: View {
    @ObservedObject var cart: Cart
    
    var body: some View {
        NavigationStack {
            Group {
                if cart.items.isEmpty {
                    EmptyCartView()
                } else {
                    CartListView(cart: cart)
                }
            }
            .navigationTitle("Cart")
        }
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add products from the category list")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CartListView: View {
    @ObservedObject var cart: Cart
    
    var body: some View {
        List {
            ForEach(cart.sortedItems, id: \.key) { item in
                HStack {
                    Text(item.key)
                    
                    Spacer()
                    
                    Stepper(value: Binding(
                        get: { item.value },
                        set: { cart.updateQuantity(for: item.key, to: $0) }
                    ), in: 0...99) {
                        Text("\(item.value)")
                            .frame(width: 30)
                            .monospacedDigit()
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        cart.remove(item.key)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

