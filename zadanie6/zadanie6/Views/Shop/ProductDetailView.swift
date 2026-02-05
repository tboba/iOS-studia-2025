//
//  ProductDetailView.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @ObservedObject var cart: Cart
    @State private var showAddedAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text(product.name ?? "")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(String(format: "$%.2f", product.price))
                    .font(.title)
                    .foregroundStyle(.green)
                
                if let categoryName = product.category?.name {
                    Text("Category: \(categoryName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                cart.add(product.name ?? "")
                showAddedAlert = true
            } label: {
                Label("Add to cart", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added!", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(product.name ?? "") has been added to the cart")
        }
    }
}

