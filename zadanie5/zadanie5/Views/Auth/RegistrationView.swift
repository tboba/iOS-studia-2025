//
//  RegistrationView.swift
//  zadanie5
//
// Created by Tymoteusz on 12/28/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authModel: AuthModel
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !username.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 4
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword || confirmPassword.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Register to start shopping")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // Registration Form
                VStack(spacing: 16) {
                    InputView(
                        text: $firstName,
                        title: "First Name",
                        placeholder: "Enter first name"
                    )
                    
                    InputView(
                        text: $lastName,
                        title: "Last Name",
                        placeholder: "Enter last name"
                    )
                    
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
                        placeholder: "Enter password (min. 4 characters)",
                        isSecureField: true
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        InputView(
                            text: $confirmPassword,
                            title: "Confirm Password",
                            placeholder: "Re-enter password",
                            isSecureField: true
                        )
                        
                        if !passwordsMatch {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Sign Up Button
                Button {
                    authModel.register(
                        firstName: firstName,
                        lastName: lastName,
                        username: username,
                        password: password
                    )
                } label: {
                    HStack {
                        if authModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("SIGN UP")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .background(isFormValid ? Color.green : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(!isFormValid || authModel.isLoading)
                .padding(.horizontal)
                
                // Login Link
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundStyle(.secondary)
                        Text("LOG IN")
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
        .alert("Success", isPresented: $authModel.registrationSuccess) {
            Button("OK") {
                authModel.registrationSuccess = false
                dismiss()
            }
        } message: {
            Text("Account registered successfully! You can now log in.")
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthModel())
}

