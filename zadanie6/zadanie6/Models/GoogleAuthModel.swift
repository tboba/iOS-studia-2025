//
//  GoogleAuthModel.swift
//  zadanie6
//
// Created by Tymoteusz on 1/24/26.
//

import Foundation
import GoogleSignIn
import SwiftUI

extension AuthModel {
    
    func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showAlert(message: "Unable to get root view controller")
            return
        }
        
        isLoading = true
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showAlert(message: "Google Sign-In failed: \(error.localizedDescription)")
                    return
                }
                
                guard let result = signInResult,
                      let profile = result.user.profile else {
                    self?.showAlert(message: "Failed to get user profile")
                    return
                }
                
                let user = User(
                    firstName: profile.givenName ?? profile.name,
                    lastName: profile.familyName ?? "",
                    username: profile.email,
                    authProvider: .google
                )
                
                self?.user = user
                
                self?.sendToken(
                    id: profile.email,
                    token: result.user.accessToken.tokenString,
                    provider: .google
                )
            }
        }
    }
}

