//
//  MockCategoryModel.swift
//  zadanie7Tests
//
//  Created by Tymoteusz on 1/30/26.
//

import Foundation
import CoreData
@testable import zadanie7

struct MockCategory: Identifiable, Equatable {
    let id: Int32
    let name: String
    let info: String
    var products: [MockProduct]
    
    var productCount: Int {
        products.count
    }
    
    var totalProductsValue: Double {
        products.reduce(0) { $0 + $1.price }
    }
}

enum MockCategoryFactory {
    
    static var electronics: MockCategory {
        MockCategory(
            id: 1,
            name: "Electronics",
            info: "Smartphones, laptops, electronic accessories",
            products: MockProductFactory.electronicsProducts
        )
    }
    
    static var clothing: MockCategory {
        MockCategory(
            id: 2,
            name: "Clothing",
            info: "Men's and women's apparel",
            products: MockProductFactory.clothingProducts
        )
    }
    
    static var furniture: MockCategory {
        MockCategory(
            id: 3,
            name: "Furniture",
            info: "Home and office furniture",
            products: MockProductFactory.furnitureProducts
        )
    }
    
    static var emptyCategory: MockCategory {
        MockCategory(
            id: 4,
            name: "Empty Category",
            info: "Category with no products",
            products: []
        )
    }
    
    static var allCategories: [MockCategory] {
        [electronics, clothing, furniture]
    }
    
    static var allCategoriesWithEmpty: [MockCategory] {
        [electronics, clothing, furniture, emptyCategory]
    }
    
    static func create(
        id: Int32 = Int32.random(in: 100...9999),
        name: String = "Test Category",
        info: String = "Test description",
        products: [MockProduct] = []
    ) -> MockCategory {
        MockCategory(id: id, name: name, info: info, products: products)
    }
    
    static func createMany(count: Int, productsPerCategory: Int = 0) -> [MockCategory] {
        (0..<count).map { index in
            let categoryId = Int32(100 + index)
            let products = productsPerCategory > 0
                ? MockProductFactory.createMany(count: productsPerCategory, categoryId: categoryId)
                : []
            return MockCategory(
                id: categoryId,
                name: "Category \(index + 1)",
                info: "Description for category \(index + 1)",
                products: products
            )
        }
    }
    
    static func createWithProducts(count: Int) -> MockCategory {
        let products = MockProductFactory.createMany(count: count, categoryId: 1)
        return MockCategory(
            id: 1,
            name: "Category with \(count) products",
            info: "Test category with many products",
            products: products
        )
    }
}

enum CoreDataCategoryMockHelper {
    
    static func createCategory(
        in context: NSManagedObjectContext,
        id: Int32 = 1,
        name: String = "Test Category",
        info: String = "Test category description"
    ) -> zadanie7.Category {
        let category = zadanie7.Category(context: context)
        category.id = id
        category.name = name
        category.info = info
        return category
    }
    
    static func createCategoryWithProducts(
        in context: NSManagedObjectContext,
        categoryName: String = "Test Category",
        productNames: [String] = ["Product A", "Product B"]
    ) -> zadanie7.Category {
        let category = createCategory(in: context, name: categoryName)
        
        for (index, name) in productNames.enumerated() {
            let product = zadanie7.Product(context: context)
            product.id = Int32(index + 1)
            product.name = name
            product.price = Double.random(in: 9.99...999.99)
            product.category_id = category.id
            product.category = category
        }
        
        return category
    }
    
    static func createCategories(
        in context: NSManagedObjectContext,
        from mocks: [MockCategory]
    ) -> [zadanie7.Category] {
        mocks.map { mock in
            let category = createCategory(in: context, id: mock.id, name: mock.name, info: mock.info)
            
            for mockProduct in mock.products {
                let product = zadanie7.Product(context: context)
                product.id = mockProduct.id
                product.name = mockProduct.name
                product.price = mockProduct.price
                product.category_id = mock.id
                product.category = category
            }
            
            return category
        }
    }
    
    static func createFullTestDataSet(in context: NSManagedObjectContext) -> [zadanie7.Category] {
        let categories = createCategories(in: context, from: MockCategoryFactory.allCategories)
        
        let order = zadanie7.Order(context: context)
        order.id = 1
        order.final_price = 199.99
        order.status = "PROCESSING"
        order.created_date = Date()
        
        if let firstCategory = categories.first,
           let products = firstCategory.products as? Set<zadanie7.Product>,
           let firstProduct = products.first {
            order.addToProducts(firstProduct)
        }
        
        try? context.save()
        
        return categories
    }
}
