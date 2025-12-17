//
//  zadanie4App.swift
//  zadanie4
//
//  Created by Tymoteusz on 12/14/25.
//

import SwiftUI
import CoreData

@main
struct zadanie4App: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        clearOrders()
        loadCategoriesFromAPI()
        loadProductsFromAPI()
        loadOrdersFromAPI()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

private let API_URL = "http://127.0.0.1:3000"

extension zadanie4App {
    
    private func clearOrders() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Order.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error clearing orders: \(error)")
        }
    }
    
    func loadCategoriesFromAPI() {
        let context = persistenceController.container.viewContext
        guard let url = URL(string: "\(API_URL)/categories") else { return }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { dispatchGroup.leave() }
            guard let data = data, error == nil else { return }
            
            do {
                let categories = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                
                for item in categories {
                    guard let idInt = item["id"] as? Int,
                          let name = item["name"] as? String,
                          let info = item["info"] as? String else { continue }
                    
                    let id = Int32(idInt)
                    
                    if !self.entityExists("Category", id: id) {
                        let category = Category(context: context)
                        category.id = id
                        category.name = name
                        category.info = info
                        print("Added category: \(name)")
                    }
                }
                
                try context.save()
            } catch {
                print("Error loading categories: \(error)")
            }
        }.resume()
        
        dispatchGroup.wait()
    }
    
    func loadProductsFromAPI() {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Category.id, ascending: true)]
        
        guard let categories = try? context.fetch(fetchRequest) else { return }
        
        for category in categories {
            guard let url = URL(string: "\(API_URL)/category/\(category.id)/products") else { continue }
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                guard let data = data, error == nil else { return }
                
                do {
                    let products = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                    
                    for item in products {
                        guard let idInt = item["id"] as? Int,
                              let name = item["name"] as? String,
                              let price = item["price"] as? Double else { continue }
                        
                        let id = Int32(idInt)
                        
                        if !self.entityExists("Product", id: id) {
                            let product = Product(context: context)
                            product.id = id
                            product.name = name
                            product.price = price
                            product.category_id = category.id
                            product.category = category
                            print("Added product: \(name)")
                        }
                    }
                    
                    try context.save()
                } catch {
                    print("Error loading products: \(error)")
                }
            }.resume()
            
            dispatchGroup.wait()
        }
    }
    
    func loadOrdersFromAPI() {
        let context = persistenceController.container.viewContext
        guard let url = URL(string: "\(API_URL)/orders") else { return }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { dispatchGroup.leave() }
            guard let data = data, error == nil else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            do {
                let orders = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                
                for item in orders {
                    // JSON numbers come as Int, need to convert to Int32
                    guard let idInt = item["id"] as? Int,
                          let finalPrice = item["final_price"] as? Double,
                          let status = item["status"] as? String,
                          let dateString = item["created_date"] as? String,
                          let createdDate = dateFormatter.date(from: dateString),
                          let productIdsInt = item["products"] as? [Int] else { 
                        print("Failed to parse order: \(item)")
                        continue 
                    }
                    
                    let id = Int32(idInt)
                    let productIds = productIdsInt.map { Int32($0) }
                    
                    if !self.entityExists("Order", id: id) {
                        let order = Order(context: context)
                        order.id = id
                        order.final_price = finalPrice
                        order.status = status
                        order.created_date = createdDate
                        order.items = productIds as NSObject
                        
                        // Fetch related products (relation)
                        let productRequest: NSFetchRequest<Product> = Product.fetchRequest()
                        productRequest.predicate = NSPredicate(format: "id IN %@", productIds)
                        
                        if let products = try? context.fetch(productRequest) {
                            for product in products {
                                order.addToProducts(product)
                            }
                        }
                        
                        print("Added order: \(id)")
                    }
                }
                
                try context.save()
            } catch {
                print("Error loading orders: \(error)")
            }
        }.resume()
        
        dispatchGroup.wait()
    }
    
    func entityExists(_ entityName: String, id: Int32) -> Bool {
        let context = persistenceController.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
}
