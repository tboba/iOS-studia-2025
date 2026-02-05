//
//  OrdersTab.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import SwiftUI
import CoreData

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
                    EmptyOrdersView()
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

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No orders yet")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OrderRow: View {
    @ObservedObject var order: Order
    @State private var isExpanded = false
    
    private var orderProducts: [Product] {
        (order.products?.allObjects as? [Product]) ?? []
    }
    
    private var statusInfo: (icon: String, color: Color) {
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
                withAnimation(.easeInOut(duration: 0.2)) {
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
                            Image(systemName: statusInfo.icon)
                                .foregroundStyle(statusInfo.color)
                            Text(order.status ?? "")
                                .font(.caption)
                                .foregroundStyle(statusInfo.color)
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

