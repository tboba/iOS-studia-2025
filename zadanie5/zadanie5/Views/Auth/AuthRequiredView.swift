//
//  AuthRequiredView.swift
//  zadanie5
//
// Created by Tymoteusz on 12/30/25.
//

import SwiftUI

struct AuthRequiredView<Content: View>: View {
    @EnvironmentObject var authModel: AuthModel
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        if authModel.isAuthenticated {
            content()
        } else {
            SignInRequiredView()
        }
    }
}

struct SignInRequiredView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Sign In Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please sign in to access this feature")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Go to the User tab to sign in")
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SignInRequiredView()
}

