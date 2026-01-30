//
//  GitHubAuthModel.swift
//  zadanie7
//
// Created by Tymoteusz on 1/29/26.
//

import Foundation
import AuthenticationServices
import SwiftUI

enum GitHubOAuthConfig {
    // Credentials loaded from Info.plist
    static var clientId: String { Secrets.githubClientId }
    static var clientSecret: String { Secrets.githubClientSecret }
    // Use simple callback - must match EXACTLY what's in GitHub OAuth App settings
    static let redirectUri = "zadanie5://callback"
    static let scope = "read:user user:email"
    
    static var authorizationURL: URL? {
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]
        return components?.url
    }
}

struct GitHubUser: Codable {
    let id: Int
    let login: String
    let name: String?
    let email: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, email
        case avatarUrl = "avatar_url"
    }
}

struct GitHubTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}

final class GitHubAuthSessionManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = GitHubAuthSessionManager()
    
    private var authSession: ASWebAuthenticationSession?
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
    
    func startSession(url: URL, callbackScheme: String, completion: @escaping (URL?, Error?) -> Void) {
        authSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackScheme,
            completionHandler: { [weak self] callbackURL, error in
                self?.authSession = nil
                completion(callbackURL, error)
            }
        )
        
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    func cancelSession() {
        authSession?.cancel()
        authSession = nil
    }
}

extension AuthModel {
    
    func signInWithGitHub() {
        guard let authURL = GitHubOAuthConfig.authorizationURL else {
            showAlert(message: "Invalid GitHub OAuth configuration")
            return
        }
        
        isLoading = true
        
        GitHubAuthSessionManager.shared.startSession(
            url: authURL,
            callbackScheme: "zadanie5"
        ) { [weak self] callbackURL, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    // Don't show error for user cancellation
                    if (error as? ASWebAuthenticationSessionError)?.code != .canceledLogin {
                        self?.showAlert(message: "GitHub Sign-In failed: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let callbackURL = callbackURL,
                      let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "code" })?.value else {
                    self?.isLoading = false
                    self?.showAlert(message: "Failed to get authorization code")
                    return
                }
                
                self?.exchangeGitHubCode(code)
            }
        }
    }
    
    private func exchangeGitHubCode(_ code: String) {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            isLoading = false
            return
        }
        
        let body: [String: String] = [
            "client_id": GitHubOAuthConfig.clientId,
            "client_secret": GitHubOAuthConfig.clientSecret,
            "code": code
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.showAlert(message: "Failed to exchange code for token")
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(GitHubTokenResponse.self, from: data)
                self?.fetchGitHubUser(accessToken: tokenResponse.accessToken)
            } catch {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.showAlert(message: "Failed to parse token response")
                }
            }
        }.resume()
    }
    
    private func fetchGitHubUser(accessToken: String) {
        guard let url = URL(string: "https://api.github.com/user") else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data, error == nil else {
                    self?.showAlert(message: "Failed to fetch user info")
                    return
                }
                
                do {
                    let githubUser = try JSONDecoder().decode(GitHubUser.self, from: data)
                    
                    let nameParts = (githubUser.name ?? githubUser.login).split(separator: " ")
                    let firstName = String(nameParts.first ?? Substring(githubUser.login))
                    let lastName = nameParts.count > 1 ? String(nameParts.dropFirst().joined(separator: " ")) : ""
                    
                    let user = User(
                        firstName: firstName,
                        lastName: lastName,
                        username: githubUser.email ?? githubUser.login,
                        authProvider: .github
                    )
                    
                    self?.user = user
                    
                    self?.sendToken(
                        id: githubUser.login,
                        token: accessToken,
                        provider: .github
                    )
                } catch {
                    self?.showAlert(message: "Failed to parse user info")
                }
            }
        }.resume()
    }
}
