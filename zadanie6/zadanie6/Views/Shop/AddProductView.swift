//
//  AddProductView.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import SwiftUI
import CoreData

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var category: Category
    
    @State private var name = ""
    @State private var price = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private var isFormValid: Bool {
        !name.isEmpty && !price.isEmpty && Double(price) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Name", text: $name)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button {
                        addProduct()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Add Product")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!isFormValid || isLoading)
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
        
        isLoading = true
        
        guard let url = URL(string: "http://127.0.0.1:3000/product") else {
            isLoading = false
            return
        }
        
        let productData: [String: Any] = [
            "name": name,
            "price": priceValue,
            "category_id": category.id
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: productData) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                guard let data = data, error == nil else {
                    errorMessage = "Network error"
                    showError = true
                    return
                }
                
                if let productId = try? JSONDecoder().decode(Int32.self, from: data) {
                    let product = Product(context: viewContext)
                    product.id = productId
                    product.name = name
                    product.price = priceValue
                    product.category = category
                    product.category_id = category.id
                    
                    try? viewContext.save()
                    dismiss()
                } else {
                    errorMessage = "Failed to add product"
                    showError = true
                }
            }
        }.resume()
    }
}

