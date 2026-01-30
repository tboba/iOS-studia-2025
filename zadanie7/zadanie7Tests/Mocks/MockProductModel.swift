//
//  MockProductModel.swift
//  zadanie7Tests
//
//  Created by Tymoteusz on 1/30/26.
//

import Foundation
import CoreData
@testable import zadanie7

struct MockProduct: Identifiable, Equatable {
    let id: Int32
    let name: String
    let price: Double
    let categoryId: Int32
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
}

enum MockProductFactory {
    
    static let iPhone = MockProduct(id: 1, name: "iPhone 15 Pro", price: 5499.99, categoryId: 1)
    static let macBook = MockProduct(id: 2, name: "MacBook Air M3", price: 6999.99, categoryId: 1)
    static let airPods = MockProduct(id: 3, name: "AirPods Pro", price: 1299.99, categoryId: 1)
    static let iPad = MockProduct(id: 4, name: "iPad Air", price: 3499.99, categoryId: 1)
    static let appleWatch = MockProduct(id: 5, name: "Apple Watch Ultra", price: 4299.99, categoryId: 1)
    
    static let tShirt = MockProduct(id: 6, name: "Cotton T-Shirt", price: 79.99, categoryId: 2)
    static let jeans = MockProduct(id: 7, name: "Slim Fit Jeans", price: 199.99, categoryId: 2)
    static let sneakers = MockProduct(id: 8, name: "Sport Sneakers", price: 349.99, categoryId: 2)
    
    static let coffeeTable = MockProduct(id: 9, name: "Coffee Table", price: 899.99, categoryId: 3)
    static let bookshelf = MockProduct(id: 10, name: "Bookshelf", price: 1499.99, categoryId: 3)
    
    static var allProducts: [MockProduct] {
        [iPhone, macBook, airPods, iPad, appleWatch, tShirt, jeans, sneakers, coffeeTable, bookshelf]
    }
    
    static var electronicsProducts: [MockProduct] {
        [iPhone, macBook, airPods, iPad, appleWatch]
    }
    
    static var clothingProducts: [MockProduct] {
        [tShirt, jeans, sneakers]
    }
    
    static var furnitureProducts: [MockProduct] {
        [coffeeTable, bookshelf]
    }
    
    static func create(
        id: Int32 = Int32.random(in: 100...9999),
        name: String = "Test Product",
        price: Double = 99.99,
        categoryId: Int32 = 1
    ) -> MockProduct {
        MockProduct(id: id, name: name, price: price, categoryId: categoryId)
    }

    static func createMany(count: Int, categoryId: Int32 = 1) -> [MockProduct] {
        (0..<count).map { index in
            MockProduct(
                id: Int32(100 + index),
                name: "Product \(index + 1)",
                price: Double.random(in: 9.99...999.99),
                categoryId: categoryId
            )
        }
    }
    
    static var freeProduct: MockProduct {
        MockProduct(id: 999, name: "Free Product", price: 0.0, categoryId: 1)
    }
    
    static var expensiveProduct: MockProduct {
        MockProduct(id: 998, name: "Luxury Watch", price: 99999.99, categoryId: 1)
    }
}

enum CoreDataProductMockHelper {
    
    static func createInMemoryContext() -> NSManagedObjectContext {
        let controller = PersistenceController(inMemory: true)
        return controller.container.viewContext
    }
    
    static func createProduct(
        in context: NSManagedObjectContext,
        id: Int32 = 1,
        name: String = "Test Product",
        price: Double = 29.99,
        categoryId: Int32 = 1
    ) -> zadanie7.Product {
        let product = zadanie7.Product(context: context)
        product.id = id
        product.name = name
        product.price = price
        product.category_id = categoryId
        return product
    }
    
    static func createProducts(
        in context: NSManagedObjectContext,
        from mocks: [MockProduct]
    ) -> [zadanie7.Product] {
        mocks.map { mock in
            createProduct(
                in: context,
                id: mock.id,
                name: mock.name,
                price: mock.price,
                categoryId: mock.categoryId
            )
        }
    }
    
    static func createProductWithCategory(
        in context: NSManagedObjectContext,
        productName: String = "Test Product",
        productPrice: Double = 29.99,
        categoryName: String = "Test Category"
    ) -> (product: zadanie7.Product, category: zadanie7.Category) {
        let category = zadanie7.Category(context: context)
        category.id = 1
        category.name = categoryName
        category.info = "Test category description"
        
        let product = zadanie7.Product(context: context)
        product.id = 1
        product.name = productName
        product.price = productPrice
        product.category_id = category.id
        product.category = category
        
        return (product, category)
    }
}
