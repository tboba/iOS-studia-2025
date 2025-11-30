//
//  zadanie3App.swift
//  zadanie3
//
//  Created by Tymoteusz on 11/29/25.
//

import SwiftUI
import CoreData

@main
struct zadanie3App: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        loadData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

extension zadanie3App {
    func loadData() {
        let context = persistenceController.container.viewContext

        if !categoriesExist() {
            let sampleData: [[String: Any]] = [
                ["category": ["name": "Kitchen", "info": "Essentials for your kitchen"],
                 "products": [["name": "Cast Iron Skillet", "price": 45.99], ["name": "Cutting Board", "price": 24.99], ["name": "Coffee Maker", "price": 32.50], ["name": "Knife Set", "price": 89.00]]],
                
                ["category": ["name": "Sports & Outdoors", "info": "Useful gear for activities"],
                 "products": [["name": "Yoga Mat", "price": 28.99], ["name": "Hiking Backpack", "price": 119.00], ["name": "Resistance Bands", "price": 18.50], ["name": "Hammock", "price": 54.99]]],
                
                ["category": ["name": "Home Office", "info": "Essentials for your home office"],
                 "products": [["name": "PC Mouse", "price": 49.99], ["name": "LED Desk Lamp", "price": 36.00], ["name": "Headphones", "price": 199.99], ["name": "Desk Converter", "price": 249.00]]],
                
                ["category": ["name": "Pet Supplies", "info": "Supplies for your pets"],
                 "products": [["name": "Pet Feeder", "price": 67.99], ["name": "Dog Bed", "price": 42.00], ["name": "Interactive Cat Toy", "price": 15.99], ["name": "Grooming Kit", "price": 29.50]]],
            ]
            
            for data in sampleData {
                if let categoryData = data["category"] as? [String: String],
                   let categoryName = categoryData["name"],
                   let categoryInfo = categoryData["info"] {
                    
                    let newCategory = Category(context: context)
                    newCategory.name = categoryName
                    newCategory.info = categoryInfo
                    
                    if let productsData = data["products"] as? [[String: Any]] {
                        for productData in productsData {
                            if let productName = productData["name"] as? String,
                               let productPrice = productData["price"] as? Double {
                                
                                let newProduct = Product(context: context)
                                newProduct.name = productName
                                newProduct.price = productPrice
                                newProduct.category = newCategory
                            }
                        }
                    }
                }
            }
            
            do {
                try context.save()
            } catch {
                print("Error adding sample categories: \(error.localizedDescription)")
            }
        }
    }
    
    func categoriesExist() -> Bool {
        let context = persistenceController.container.viewContext
        
        do {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            let categories = try context.fetch(request)
            return !categories.isEmpty
        } catch {
            return false
        }
    }
}
