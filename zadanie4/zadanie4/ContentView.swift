//
//  ContentView.swift
//  zadanie4
//
//  Created by Tymoteusz on 12/14/25.
//

import SwiftUI
import CoreData
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
    
    var totalItems: Int {
        items.values.reduce(0, +)
    }
}

struct ContentView: View {
    @StateObject private var cart = Cart()
    
    var body: some View {
        TabView {
            CategoriesTab(cart: cart)
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }
            
            AllProductsTab(cart: cart)
                .tabItem {
                    Label("Products", systemImage: "list.bullet")
                }
            
            CartTab(cart: cart)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .badge(cart.totalItems)
            
            OrdersTab()
                .tabItem {
                    Label("Orders", systemImage: "shippingbox")
                }
        }
    }
}

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

struct AllProductsTab: View {
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
                
                Text(String(format: "$%.2f", product.price))
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

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var category: Category
    
    @State private var name = ""
    @State private var price = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Name", text: $name)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button("Add Product") {
                        addProduct()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .navigationTitle("New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addProduct() {
        guard !name.isEmpty else {
            errorMessage = "Name cannot be empty"
            showError = true
            return
        }
        
        guard let priceValue = Double(price), priceValue >= 0 else {
            errorMessage = "Invalid price"
            showError = true
            return
        }
        
        // Send to server
        guard let url = URL(string: "http://127.0.0.1:3000/product") else { return }
        
        let productData: [String: Any] = [
            "name": name,
            "price": priceValue,
            "category_id": category.id
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: productData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let productId = try? JSONDecoder().decode(Int32.self, from: data) {
                DispatchQueue.main.async {
                    let product = Product(context: viewContext)
                    product.id = productId
                    product.name = name
                    product.price = priceValue
                    product.category = category
                    product.category_id = category.id
                    
                    try? viewContext.save()
                    dismiss()
                }
            }
        }.resume()
    }
}

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

struct OrdersTab: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.created_date, order: .reverse)],
        animation: .default
    )
    private var orders: FetchedResults<Order>
    
    var body: some View {
        NavigationStack {
            Group {
                if orders.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No orders yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(orders, id: \.id) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .navigationTitle("Orders")
        }
    }
}

struct OrderRow: View {
    @ObservedObject var order: Order
    @State private var isExpanded = false
    
    private var orderProducts: [Product] {
        (order.products?.allObjects as? [Product]) ?? []
    }
    
    private var statusIcon: (name: String, color: Color) {
        switch order.status?.uppercased() {
        case "PROCESSING": return ("gear", .orange)
        case "SHIPPED": return ("shippingbox", .green)
        case "SEND": return ("paperplane", .purple)
        default: return ("questionmark.circle", .gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        if let date = order.created_date {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "$%.2f", order.final_price))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Image(systemName: statusIcon.name)
                                .foregroundStyle(statusIcon.color)
                            Text(order.status ?? "")
                                .font(.caption)
                                .foregroundStyle(statusIcon.color)
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                
                ForEach(orderProducts, id: \.id) { product in
                    HStack {
                        Text(product.name ?? "")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "$%.2f", product.price))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

