//
//  OAuthView.swift
//  zadanie7
//
// Created by Tymoteusz on 1/29/26.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct OAuthView: View {
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        VStack(spacing: 16) {
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(
                scheme: .dark,
                style: .wide,
                state: .normal
            )) {
                authModel.signInWithGoogle()
            }
            .frame(height: 50)
            .padding(.horizontal)
            
            Button {
                authModel.signInWithGitHub()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.title3)
                    Text("Sign in with GitHub")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    OAuthView()
        .environmentObject(AuthModel())
}

