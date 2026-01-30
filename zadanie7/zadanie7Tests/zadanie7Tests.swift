//
//  zadanie7Tests.swift
//  zadanie7Tests
//
//  Created by Tymoteusz on 1/29/26.
//

import Testing
import Foundation
import CoreData
@testable import zadanie7

struct CartTests {
    
    @Test func testAddSingleItem() async throws {
        let cart = Cart()
        cart.add("iPhone 15 Pro")
        #expect(cart.items.count == 1)
        #expect(cart.items["iPhone 15 Pro"] == 1)
    }
    
    @Test func testAddSameItemTwice() async throws {
        let cart = Cart()
        cart.add("MacBook Air")
        cart.add("MacBook Air")
        #expect(cart.items["MacBook Air"] == 2)
    }
    
    @Test func testAddMultipleDifferentItems() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.add("MacBook")
        cart.add("AirPods")
        #expect(cart.items.count == 3)
    }
    
    @Test func testRemoveItem() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.remove("iPhone")
        #expect(cart.items.isEmpty)
    }
    
    @Test func testRemoveNonExistentItem() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.remove("MacBook")
        #expect(cart.items.count == 1)
    }
    
    @Test func testUpdateQuantityPositive() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.updateQuantity(for: "iPhone", to: 5)
        #expect(cart.items["iPhone"] == 5)
    }
    
    @Test func testUpdateQuantityToZeroRemovesItem() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.updateQuantity(for: "iPhone", to: 0)
        #expect(cart.items["iPhone"] == nil)
    }
    
    @Test func testUpdateQuantityNegativeRemovesItem() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.updateQuantity(for: "iPhone", to: -1)
        #expect(cart.items["iPhone"] == nil)
    }
    
    @Test func testClearCart() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.add("MacBook")
        cart.add("AirPods")
        cart.clear()
        #expect(cart.items.isEmpty)
    }
    
    @Test func testTotalItems() async throws {
        let cart = Cart()
        cart.add("iPhone")
        cart.add("iPhone")
        cart.add("MacBook")
        #expect(cart.totalItems == 3)
    }
    
    @Test func testTotalItemsEmpty() async throws {
        let cart = Cart()
        #expect(cart.totalItems == 0)
    }
    
    @Test func testSortedItemsAlphabetical() async throws {
        let cart = Cart()
        cart.add("Zebra")
        cart.add("Apple")
        cart.add("Mango")
        let sorted = cart.sortedItems
        #expect(sorted[0].key == "Apple")
        #expect(sorted[2].key == "Zebra")
    }
}

struct TransactionTests {
    
    @Test func testFormattedAmount() async throws {
        let transaction = Transaction(
            customerName: "Jan Kowalski",
            cardDigits: "1234",
            totalAmount: 159.99,
            productNames: ["iPhone"],
            quantities: ["iPhone": 1]
        )
        #expect(transaction.formattedAmount == "159.99 PLN")
    }
    
    @Test func testObscuredCardNumber() async throws {
        let transaction = Transaction(
            customerName: "Jan Kowalski",
            cardDigits: "5678",
            totalAmount: 100.0,
            productNames: ["iPad"],
            quantities: ["iPad": 1]
        )
        #expect(transaction.obscuredCardNumber == "•••• •••• •••• 5678")
    }
    
    @Test func testItemCount() async throws {
        let transaction = Transaction(
            customerName: "Anna Nowak",
            cardDigits: "1234",
            totalAmount: 500.0,
            productNames: ["iPhone", "MacBook"],
            quantities: ["iPhone": 2, "MacBook": 3]
        )
        #expect(transaction.itemCount == 5)
    }
    
    @Test func testTransactionCodable() async throws {
        let original = Transaction.preview
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Transaction.self, from: data)
        
        #expect(decoded.customerName == original.customerName)
        #expect(decoded.totalAmount == original.totalAmount)
        #expect(decoded.cardDigits == original.cardDigits)
    }
    
    @Test func testTransactionPreview() async throws {
        let preview = Transaction.preview
        #expect(preview.customerName == "Anna Nowak")
        #expect(preview.productNames.count == 2)
    }
    
    @Test func testTransactionEquality() async throws {
        let id = UUID()
        let date = Date()
        let ref = "REF-001"
        
        let t1 = Transaction(id: id, customerName: "Jan", cardDigits: "1234", totalAmount: 100, purchaseDate: date, referenceNumber: ref, productNames: ["A"], quantities: ["A": 1])
        let t2 = Transaction(id: id, customerName: "Jan", cardDigits: "1234", totalAmount: 100, purchaseDate: date, referenceNumber: ref, productNames: ["A"], quantities: ["A": 1])
        
        #expect(t1 == t2)
    }
}

struct UserTests {
    
    @Test func testFullName() async throws {
        let user = User(firstName: "Jan", lastName: "Kowalski", username: "jan123")
        #expect(user.fullName == "Jan Kowalski")
    }
    
    @Test func testFullNameEmptyLastName() async throws {
        let user = User(firstName: "Jan", lastName: "", username: "jan123")
        #expect(user.fullName == "Jan")
    }
    
    @Test func testInitials() async throws {
        let user = User(firstName: "Jan", lastName: "Kowalski", username: "jan123")
        let initials = user.initials
        #expect(!initials.isEmpty)
    }
    
    @Test func testMockUser() async throws {
        let mock = User.mockUser
        #expect(mock.firstName == "John")
        #expect(mock.lastName == "Doe")
        #expect(mock.username == "johndoe12")
        #expect(mock.authProvider == .server)
    }
    
    @Test func testAuthProviderRawValues() async throws {
        #expect(AuthProvider.server.rawValue == "server")
        #expect(AuthProvider.google.rawValue == "google")
        #expect(AuthProvider.github.rawValue == "github")
    }
    
    @Test func testUserCodable() async throws {
        let user = User(firstName: "Anna", lastName: "Nowak", username: "anna", authProvider: .google)
        let data = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: data)
        #expect(decoded.firstName == "Anna")
        #expect(decoded.authProvider == .google)
    }
}

struct AuthModelTests {
    
    @MainActor
    @Test func testInitialStateNotAuthenticated() async throws {
        let model = AuthModel()
        #expect(model.isAuthenticated == false)
        #expect(model.user == nil)
    }
    
    @MainActor
    @Test func testSignOutClearsUser() async throws {
        let model = AuthModel()
        model.user = User(firstName: "Jan", lastName: "K", username: "jan", authProvider: .server)
        #expect(model.isAuthenticated == true)
        model.signOut()
        #expect(model.user == nil)
        #expect(model.isAuthenticated == false)
    }
    
    @MainActor
    @Test func testShowAlert() async throws {
        let model = AuthModel()
        model.showAlert(message: "Test error")
        #expect(model.alertMessage == "Test error")
        #expect(model.isShowingAlert == true)
    }
    
    @MainActor
    @Test func testDismissAlert() async throws {
        let model = AuthModel()
        model.showAlert(message: "Some error")
        model.dismissAlert()
        #expect(model.isShowingAlert == false)
        #expect(model.alertMessage == "")
    }
    
    @MainActor
    @Test func testIsLoadingInitiallyFalse() async throws {
        let model = AuthModel()
        #expect(model.isLoading == false)
    }
    
    @MainActor
    @Test func testRegistrationSuccessInitiallyFalse() async throws {
        let model = AuthModel()
        #expect(model.registrationSuccess == false)
    }
}

struct MockProductTests {
    
    @Test func testMockProductFactoryPresets() async throws {
        let iphone = MockProductFactory.iPhone
        #expect(iphone.name == "iPhone 15 Pro")
        #expect(iphone.price == 5499.99)
    }
    
    @Test func testMockProductFormattedPrice() async throws {
        let product = MockProductFactory.create(price: 49.9)
        #expect(product.formattedPrice == "$49.90")
    }
    
    @Test func testMockProductCreateMany() async throws {
        let products = MockProductFactory.createMany(count: 5)
        #expect(products.count == 5)
    }
    
    @Test func testAllProductsCount() async throws {
        let all = MockProductFactory.allProducts
        #expect(all.count == 10)
    }
    
    @Test func testFreeProduct() async throws {
        let free = MockProductFactory.freeProduct
        #expect(free.price == 0.0)
    }
    
    @Test func testExpensiveProduct() async throws {
        let expensive = MockProductFactory.expensiveProduct
        #expect(expensive.price == 99999.99)
    }
}

struct MockCategoryTests {
    
    @Test func testMockCategoryElectronics() async throws {
        let category = MockCategoryFactory.electronics
        #expect(category.name == "Electronics")
        #expect(category.productCount == 5)
    }
    
    @Test func testEmptyCategory() async throws {
        let category = MockCategoryFactory.emptyCategory
        #expect(category.productCount == 0)
    }
    
    @Test func testAllCategoriesCount() async throws {
        let all = MockCategoryFactory.allCategories
        #expect(all.count == 3)
    }
    
    @Test func testCategoryTotalProductsValue() async throws {
        let category = MockCategoryFactory.electronics
        #expect(category.totalProductsValue > 0)
    }
    
    @Test func testCreateManyCategories() async throws {
        let categories = MockCategoryFactory.createMany(count: 4, productsPerCategory: 3)
        #expect(categories.count == 4)
        #expect(categories[0].productCount == 3)
    }
    
    @Test func testCreateCategoryWithProducts() async throws {
        let category = MockCategoryFactory.createWithProducts(count: 7)
        #expect(category.productCount == 7)
    }
}

struct CoreDataMockTests {
    
    @Test func testCreateProductInMemory() async throws {
        let context = CoreDataProductMockHelper.createInMemoryContext()
        let product = CoreDataProductMockHelper.createProduct(
            in: context,
            id: 1,
            name: "Test iPhone",
            price: 4999.99
        )
        #expect(product.name == "Test iPhone")
        #expect(product.price == 4999.99)
    }
    
    @Test func testCreateProductWithCategory() async throws {
        let context = CoreDataProductMockHelper.createInMemoryContext()
        let (product, category) = CoreDataProductMockHelper.createProductWithCategory(
            in: context,
            productName: "MacBook",
            categoryName: "Laptops"
        )
        #expect(product.category == category)
        #expect(category.name == "Laptops")
    }
    
    @Test func testCreateCategoryWithProductsCoreData() async throws {
        let context = CoreDataProductMockHelper.createInMemoryContext()
        let category = CoreDataCategoryMockHelper.createCategoryWithProducts(
            in: context,
            categoryName: "Electronics",
            productNames: ["iPhone", "iPad", "MacBook"]
        )
        let products = category.products as? Set<zadanie7.Product>
        #expect(products?.count == 3)
    }
}
