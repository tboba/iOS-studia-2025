//
//  CartTab.swift
//  zadanie6
//
//  Created by Tymoteusz on 1/24/26.
//

import SwiftUI

struct CartTab: View {
    @ObservedObject var cart: Cart
    @EnvironmentObject var transactionStore: TransactionStore
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationStack {
            Group {
                if cart.items.isEmpty {
                    EmptyCartView()
                } else {
                    CartContentView(cart: cart, showingCheckout: $showingCheckout)
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        TransactionHistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(isPresented: $showingCheckout) {
                CheckoutView(cart: cart)
                    .environmentObject(transactionStore)
            }
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

struct CartContentView: View {
    @ObservedObject var cart: Cart
    @Binding var showingCheckout: Bool
    
    private var estimatedTotal: Double {
        Double(cart.totalItems) * 29.99
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("Products") {
                    ForEach(cart.sortedItems, id: \.key) { item in
                        CartItemRow(cart: cart, itemName: item.key, quantity: item.value)
                    }
                }
                
                Section {
                    HStack {
                        Text("Estimated price")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.2f PLN", estimatedTotal))
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Checkout button at bottom
            VStack(spacing: 12) {
                Button {
                    showingCheckout = true
                } label: {
                    HStack {
                        Image(systemName: "creditcard")
                        Text("Checkout payment")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(role: .destructive) {
                    withAnimation {
                        cart.clear()
                    }
                } label: {
                    Text("Clear cart")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

struct CartItemRow: View {
    @ObservedObject var cart: Cart
    let itemName: String
    let quantity: Int
    
    var body: some View {
        HStack {
            Text(itemName)
                .lineLimit(2)
            
            Spacer()
            
            Stepper(value: Binding(
                get: { quantity },
                set: { cart.updateQuantity(for: itemName, to: $0) }
            ), in: 0...99) {
                Text("\(quantity)")
                    .frame(width: 30)
                    .monospacedDigit()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    cart.remove(itemName)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    CartTab(cart: {
        let cart = Cart()
        cart.add("iPhone 15 Pro")
        cart.add("MacBook Air")
        cart.add("MacBook Air")
        return cart
    }())
    .environmentObject(TransactionStore())
}

