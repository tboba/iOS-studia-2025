//
//  InputView.swift
//  zadanie5
//
// Created by Tymoteusz on 12/27/25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.plain)
            .padding(.vertical, 8)
            
            Divider()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InputView(text: .constant(""), title: "Username", placeholder: "Enter username")
        InputView(text: .constant(""), title: "Password", placeholder: "Enter password", isSecureField: true)
    }
    .padding()
}

