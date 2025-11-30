//
//  PersistenceController.swift
//  zadanie3
//
//  Created by Tymoteusz on 11/29/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Fixtures
    
    func loadFixturesIfNeeded() {
        guard !hasData() else { return }
        
        let fixtures: [(category: (name: String, info: String), products: [(name: String, price: Double)])] = [
            (("Kitchen", "Essentials for your kitchen"), [
                ("Cast Iron Skillet", 45.99),
                ("Cutting Board", 24.99),
                ("Coffee Maker", 32.50),
                ("Knife Set", 89.00)
            ]),
            (("Sports & Outdoors", "Useful gear for activities"), [
                ("Yoga Mat", 28.99),
                ("Hiking Backpack", 119.00),
                ("Resistance Bands", 18.50),
                ("Hammock", 54.99)
            ]),
            (("Home Office", "Essentials for your home office"), [
                ("PC Mouse", 49.99),
                ("LED Desk Lamp", 36.00),
                ("Headphones", 199.99),
                ("Desk Converter", 249.00)
            ]),
            (("Pet Supplies", "Supplies for your pets"), [
                ("Pet Feeder", 67.99),
                ("Dog Bed", 42.00),
                ("Interactive Cat Toy", 15.99),
                ("Grooming Kit", 29.50)
            ])
        ]
        
        for fixture in fixtures {
            let category = Category(context: viewContext)
            category.name = fixture.category.name
            category.info = fixture.category.info
            
            for productData in fixture.products {
                let product = Product(context: viewContext)
                product.name = productData.name
                product.price = productData.price
                product.category = category
            }
        }
        
        save()
    }
    
    private func hasData() -> Bool {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1
        return (try? viewContext.count(for: request)) ?? 0 > 0
    }
    
    func save() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}
