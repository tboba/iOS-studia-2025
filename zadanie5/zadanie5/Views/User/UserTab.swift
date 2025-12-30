//
//  UserTab.swift
//  zadanie5
//
// Created by Tymoteusz on 12/26/25.
//

import SwiftUI

struct UserTab: View {
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        NavigationStack {
            Group {
                if let user = authModel.user {
                    UserProfileView(user: user)
                } else {
                    LoginView()
                }
            }
            .navigationTitle(authModel.isAuthenticated ? "Profile" : "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UserProfileView: View {
    let user: User
    @EnvironmentObject var authModel: AuthModel
    @State private var showSignOutConfirmation = false
    
    var body: some View {
        List {
            // Profile Section
            Section {
                HStack(spacing: 16) {
                    // Avatar
                    Text(user.initials)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.gray)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullName)
                            .font(.headline)
                        
                        Text(user.username)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let provider = user.authProvider {
                            HStack(spacing: 4) {
                                providerIcon(for: provider)
                                Text(providerText(for: provider))
                                    .font(.caption)
                            }
                            .foregroundStyle(providerColor(for: provider))
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Account Info Section
            Section("Account Information") {
                LabeledContent("First Name", value: user.firstName)
                LabeledContent("Last Name", value: user.lastName.isEmpty ? "-" : user.lastName)
                LabeledContent("Username", value: user.username)
                
                if let provider = user.authProvider {
                    LabeledContent("Login Method", value: providerText(for: provider))
                }
            }
            
            // Actions Section
            Section {
                Button(role: .destructive) {
                    showSignOutConfirmation = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title3)
                        
                        Text("Sign Out")
                    }
                }
            }
        }
        .confirmationDialog(
            "Sign Out",
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                authModel.signOut()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private func providerIcon(for provider: AuthProvider) -> some View {
        switch provider {
        case .google:
            return Image(systemName: "g.circle.fill")
        case .github:
            return Image(systemName: "chevron.left.forwardslash.chevron.right")
        case .server:
            return Image(systemName: "server.rack")
        }
    }
    
    private func providerText(for provider: AuthProvider) -> String {
        switch provider {
        case .google: return "Google"
        case .github: return "GitHub"
        case .server: return "Server"
        }
    }
    
    private func providerColor(for provider: AuthProvider) -> Color {
        switch provider {
        case .google: return .red
        case .github: return .primary
        case .server: return .blue
        }
    }
}

#Preview("Logged In") {
    UserTab()
        .environmentObject({
            let model = AuthModel()
            return model
        }())
}

#Preview("Logged Out") {
    UserTab()
        .environmentObject(AuthModel())
}

