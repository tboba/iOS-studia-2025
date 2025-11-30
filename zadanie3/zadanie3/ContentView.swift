//
//  ContentView.swift
//  zadanie3
//
//  Created by Tymoteusz on 11/29/25.
//

import SwiftUI
import CoreData
import Combine

// MARK: - Cart Manager

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
    
    var totalItems: Int {
        items.values.reduce(0, +)
    }
}

// MARK: - Main View

struct ContentView: View {
    @StateObject private var cart = Cart()
    
    var body: some View {
        TabView {
            CategoriesTab(cart: cart)
                .tabItem {
                    Label("Products", systemImage: "list.bullet")
                }
            
            CartTab(cart: cart)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .badge(cart.totalItems)
        }
    }
}

// MARK: - Categories Tab

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
                ProductsListView(category: category, cart: cart)
            }
        }
    }
}

// MARK: - Products List View

struct ProductsListView: View {
    @ObservedObject var category: Category
    @ObservedObject var cart: Cart
    
    private var products: [Product] {
        (category.products as? Set<Product>)?.sorted { ($0.name ?? "") < ($1.name ?? "") } ?? []
    }
    
    var body: some View {
        List(products) { product in
            NavigationLink(value: product) {
                HStack {
                    Text(product.name ?? "")
                    Spacer()
                    Text(String(format: "%.2f zł", product.price))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(category.name ?? "Products")
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product, cart: cart)
        }
    }
}

// MARK: - Product Detail View

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
                
                Text(String(format: "%.2f zł", product.price))
                    .font(.title)
                    .foregroundStyle(.green)
                
                if let categoryName = product.category?.name {
                    Text("Category: \(categoryName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
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

// MARK: - Cart Tab

struct CartTab: View {
    @ObservedObject var cart: Cart
    
    private var sortedItems: [(key: String, value: Int)] {
        cart.items.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if cart.items.isEmpty {
                    VStack(spacing: 12) {
                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add products from the category list")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(sortedItems, id: \.key) { item in
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
            .navigationTitle("Cart")
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
}

