//
//  LoginView.swift
//  zadanie7
//
// Created by Tymoteusz on 1/29/26.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @EnvironmentObject var authModel: AuthModel
    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Sign in to continue shopping")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Login Form
                    VStack(spacing: 16) {
                        InputView(
                            text: $username,
                            title: "Username",
                            placeholder: "Enter username"
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        
                        InputView(
                            text: $password,
                            title: "Password",
                            placeholder: "Enter password",
                            isSecureField: true
                        )
                    }
                    .padding(.horizontal)
                    
                    // Sign In Button
                    Button {
                        authModel.signIn(username: username, password: password)
                    } label: {
                        HStack {
                            if authModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("SIGN IN")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .background(isFormValid ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(!isFormValid || authModel.isLoading)
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.secondary.opacity(0.3))
                        Text("or")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.secondary.opacity(0.3))
                    }
                    .padding(.horizontal)
                    
                    // OAuth Buttons
                    OAuthView()
                    
                    // Register Link
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundStyle(.secondary)
                            Text("SIGN UP")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .font(.subheadline)
                    }
                    .padding(.bottom, 20)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .alert("Error", isPresented: $authModel.isShowingAlert) {
                Button("OK", role: .cancel) {
                    authModel.dismissAlert()
                }
            } message: {
                Text(authModel.alertMessage)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthModel())
}

