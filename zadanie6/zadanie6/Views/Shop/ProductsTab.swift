//
//  ProductsTab.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import SwiftUI
import CoreData

struct ProductsTab: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var cart: Cart
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)],
        animation: .default
    )
    private var products: FetchedResults<Product>
    
    var body: some View {
        NavigationStack {
            List(products) { product in
                NavigationLink(value: product) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name ?? "")
                            .font(.headline)
                        HStack {
                            Text(product.category?.name ?? "")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Spacer()
                            Text(String(format: "$%.2f", product.price))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .navigationTitle("All Products")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product, cart: cart)
            }
        }
    }
}

