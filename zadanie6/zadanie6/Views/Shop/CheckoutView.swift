//
//  CheckoutView.swift
//  zadanie6
//
//  Created by Tymoteusz on 1/24/26.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var cart: Cart
    @EnvironmentObject var transactionStore: TransactionStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var holderName = ""
    @State private var cardNum = ""
    @State private var expirationDate = ""
    @State private var securityCode = ""
    
    @State private var processingPayment = false
    @State private var showingResult = false
    @State private var resultSuccess = false
    @State private var resultMessage = ""
    @State private var transactionRef = ""
    
    private let paymentEndpoint = "http://127.0.0.1:3000/pay"
    
    var cartTotal: Double {
        // Calculate total from cart items
        // In a real app, this would fetch prices from products
        Double(cart.totalItems) * 29.99
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    orderSummarySection
                    
                    cardDetailsSection
                    
                    submitButton
                }
                .padding()
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(resultSuccess ? "Success" : "Error", isPresented: $showingResult) {
                Button("OK") {
                    if resultSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(resultMessage)
            }
            .disabled(processingPayment)
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Summary", systemImage: "bag")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(cart.sortedItems, id: \.key) { item in
                    HStack {
                        Text(item.key)
                            .lineLimit(1)
                        Spacer()
                        Text("x\(item.value)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                
                Divider()
                
                HStack {
                    Text("Resulted price")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f PLN", cartTotal))
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var cardDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Card details", systemImage: "creditcard")
                .font(.headline)
            
            VStack(spacing: 16) {
                PaymentTextField(
                    title: "Name, Surname",
                    placeholder: "Jan Kowalski",
                    text: $holderName,
                    keyboardType: .default
                )
                
                PaymentTextField(
                    title: "Card Number",
                    placeholder: "1234 5678 9012 3456",
                    text: $cardNum,
                    keyboardType: .numberPad
                )
                
                HStack(spacing: 16) {
                    PaymentTextField(
                        title: "Expiration date",
                        placeholder: "MM/RR",
                        text: $expirationDate,
                        keyboardType: .numbersAndPunctuation
                    )
                    
                    PaymentTextField(
                        title: "CVV",
                        placeholder: "123",
                        text: $securityCode,
                        keyboardType: .numberPad,
                        isSecure: true
                    )
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var submitButton: some View {
        Button {
            initiatePayment()
        } label: {
            Group {
                if processingPayment {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Pay \(String(format: "%.2f PLN", cartTotal))")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(formIsValid ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!formIsValid || processingPayment)
    }
    
    private var formIsValid: Bool {
        let nameValid = !holderName.trimmingCharacters(in: .whitespaces).isEmpty
        let cardValid = cardNum.filter { $0.isNumber }.count >= 13
        let expiryValid = !expirationDate.trimmingCharacters(in: .whitespaces).isEmpty
        let cvvValid = securityCode.filter { $0.isNumber }.count >= 3
        
        return nameValid && cardValid && expiryValid && cvvValid
    }
    
    private func initiatePayment() {
        guard formIsValid else {
            showError("Wypełnij wszystkie pola poprawnie")
            return
        }
        
        processingPayment = true
        
        Task {
            do {
                let response = try await executePaymentRequest()
                await handlePaymentResponse(response)
            } catch {
                await MainActor.run {
                    processingPayment = false
                    showError("Error while connecting: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func executePaymentRequest() async throws -> ServerPaymentResponse {
        guard let url = URL(string: paymentEndpoint) else {
            throw URLError(.badURL)
        }
        
        let payload = PaymentRequestPayload(
            full_name: holderName,
            card_number: cardNum.filter { $0.isNumber },
            expiry: expirationDate,
            cvc: securityCode,
            amount: String(format: "%.2f", cartTotal)
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ServerPaymentResponse.self, from: data)
    }
    
    @MainActor
    private func handlePaymentResponse(_ response: ServerPaymentResponse) {
        processingPayment = false
        
        if response.status == "success" {
            let digits = String(cardNum.filter { $0.isNumber }.suffix(4))
            
            let newTransaction = Transaction(
                customerName: holderName,
                cardDigits: digits,
                totalAmount: cartTotal,
                referenceNumber: response.transaction_id,
                productNames: cart.sortedItems.map { $0.key },
                quantities: cart.items
            )
            
            transactionStore.record(newTransaction)
            cart.clear()
            
            transactionRef = response.transaction_id
            resultSuccess = true
            resultMessage = "The payment has been finalized.\nTransaction number: \(response.transaction_id)"
        } else {
            resultSuccess = false
            resultMessage = "The payment has been rejected.\n\(response.message)"
        }
        
        showingResult = true
    }
    
    private func showError(_ message: String) {
        resultSuccess = false
        resultMessage = message
        showingResult = true
    }
}

struct PaymentTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

struct PaymentRequestPayload: Codable {
    let full_name: String
    let card_number: String
    let expiry: String
    let cvc: String
    let amount: String
}

struct ServerPaymentResponse: Codable {
    let status: String
    let transaction_id: String
    let message: String
}

#Preview {
    let cart = Cart()
    cart.add("Test Product")
    cart.add("Another Item")
    
    return CheckoutView(cart: cart)
        .environmentObject(TransactionStore())
}
