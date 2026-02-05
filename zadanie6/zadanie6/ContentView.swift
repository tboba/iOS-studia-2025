//
//  ContentView.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var cart = Cart()
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        TabView {
            AuthRequiredView {
                CategoriesTab(cart: cart)
            }
            .tabItem {
                Label("Categories", systemImage: "square.grid.2x2")
            }
            
            AuthRequiredView {
                ProductsTab(cart: cart)
            }
            .tabItem {
                Label("Products", systemImage: "list.bullet")
            }
            
            AuthRequiredView {
                CartTab(cart: cart)
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
            }
            .badge(authModel.isAuthenticated ? cart.totalItems : 0)
            
            AuthRequiredView {
                OrdersTab()
            }
            .tabItem {
                Label("Orders", systemImage: "shippingbox")
            }
            
            UserTab()
                .tabItem {
                    Label("User", systemImage: authModel.isAuthenticated ? "person.fill" : "person")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environmentObject(AuthModel())
}
