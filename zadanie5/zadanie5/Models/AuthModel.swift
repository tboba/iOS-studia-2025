//
//  AuthModel.swift
//  zadanie5
//
// Created by Tymoteusz on 12/28/25.
//

import Foundation
import SwiftUI
import AuthenticationServices
import Combine

@MainActor
final class AuthModel: ObservableObject {
    @Published var user: User?
    @Published var alertMessage: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var registrationSuccess: Bool = false
    
    private let baseURL = "http://127.0.0.1:3000"
    
    var isAuthenticated: Bool {
        user != nil
    }
    
    func signIn(username: String, password: String) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        isLoading = true
        
        let userData: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data, error == nil else {
                    self?.showAlert(message: "Network error: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showAlert(message: "Invalid response")
                    return
                }
                
                if httpResponse.statusCode >= 400 {
                    self?.showAlert(message: "Invalid credentials")
                    return
                }
                
                do {
                    var user = try JSONDecoder().decode(User.self, from: data)
                    user = User(
                        firstName: user.firstName,
                        lastName: user.lastName,
                        username: user.username,
                        authProvider: .server
                    )
                    self?.user = user
                } catch {
                    self?.showAlert(message: "Failed to parse response")
                }
            }
        }.resume()
    }
    
    func register(firstName: String, lastName: String, username: String, password: String) {
        guard let url = URL(string: "\(baseURL)/register") else { return }
        
        isLoading = true
        
        let userData: [String: Any] = [
            "username": username,
            "password": password,
            "first_name": firstName,
            "last_name": lastName
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data, error == nil else {
                    self?.showAlert(message: "Network error")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showAlert(message: "Invalid response")
                    return
                }
                
                if httpResponse.statusCode >= 400 {
                    self?.showAlert(message: "User with this username already exists")
                    return
                }
                
                // Registration successful - don't auto-login
                self?.registrationSuccess = true
            }
        }.resume()
    }
    
    func signOut() {
        user = nil
    }
    
    func showAlert(message: String) {
        alertMessage = message
        isShowingAlert = true
    }
    
    func dismissAlert() {
        isShowingAlert = false
        alertMessage = ""
    }
    
    func sendToken(id: String, token: String, provider: AuthProvider) {
        guard let url = URL(string: "\(baseURL)/token") else { return }
        
        let tokenData: [String: Any] = [
            "id": id,
            "token": token,
            "provider": provider.rawValue
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: tokenData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Token stored with status: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

