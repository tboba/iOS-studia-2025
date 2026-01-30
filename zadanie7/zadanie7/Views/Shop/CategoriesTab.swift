//
//  CategoriesTab.swift
//  zadanie7
//
// Created by Tymoteusz on 1/29/26.
//

import SwiftUI
import CoreData

struct CategoriesTab: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var cart: Cart
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
    var body: some View {
        NavigationStack {
            List(categories) { category in
                NavigationLink(value: category) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name ?? "")
                            .font(.headline)
                        Text(category.info ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Categories")
            .navigationDestination(for: Category.self) { category in
                CategoryProductsView(category: category, cart: cart)
            }
        }
    }
}

struct CategoryProductsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var category: Category
    @ObservedObject var cart: Cart
    
    @State private var showAddProduct = false
    
    private var products: [Product] {
        (category.products as? Set<Product>)?.sorted { ($0.name ?? "") < ($1.name ?? "") } ?? []
    }
    
    var body: some View {
        List(products) { product in
            NavigationLink(value: product) {
                HStack {
                    Text(product.name ?? "")
                    Spacer()
                    Text(String(format: "$%.2f", product.price))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(category.name ?? "Products")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddProduct = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddProduct) {
            AddProductView(category: category)
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product, cart: cart)
        }
    }
}

