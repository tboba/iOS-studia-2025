//
//  TransactionHistoryView.swift
//  zadanie7
//
//  Created by Tymoteusz on 1/29/26.
//

import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var store: TransactionStore
    @State private var showingClearConfirmation = false
    
    var body: some View {
        Group {
            if store.hasTransactions {
                transactionsList
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Historia zakupów")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if store.hasTransactions {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .confirmationDialog(
            "Czy na pewno chcesz usunąć całą historię?",
            isPresented: $showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Usuń wszystko", role: .destructive) {
                withAnimation {
                    store.clearAll()
                }
            }
            Button("Anuluj", role: .cancel) {}
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            
            Text("Brak transakcji")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Twoje opłacone zamówienia pojawią się tutaj")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var transactionsList: some View {
        List {
            Section {
                summaryRow
            }
            
            Section("Transakcje") {
                ForEach(store.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
                .onDelete { indices in
                    store.delete(at: indices)
                }
            }
        }
    }
    
    private var summaryRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Łączne wydatki")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.2f PLN", store.totalSpent))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Transakcji")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(store.transactions.count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Transaction Row

struct TransactionRowView: View {
    let transaction: Transaction
    @State private var isExpanded = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.customerName)
                        .font(.headline)
                    
                    Text(transaction.obscuredCardNumber)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
            
            // Date and items count
            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text(dateFormatter.string(from: transaction.purchaseDate))
                    .font(.caption)
                
                Spacer()
                
                Text("\(transaction.itemCount) produktów")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.secondary)
            
            // Expandable products section
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Produkty:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(transaction.productNames, id: \.self) { name in
                        HStack {
                            Text("• \(name)")
                                .font(.caption)
                            if let qty = transaction.quantities[name], qty > 1 {
                                Text("x\(qty)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 4)
                
                Text("Ref: \(transaction.referenceNumber)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TransactionHistoryView()
            .environmentObject({
                let store = TransactionStore()
                return store
            }())
    }
}
