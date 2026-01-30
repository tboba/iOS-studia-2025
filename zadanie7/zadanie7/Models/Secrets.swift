//
//  Secrets.swift
//  zadanie7
//
// Created by Tymoteusz on 1/29/26.
//

import Foundation

enum Secrets {
    private static var infoDictionary: [String: Any] {
        Bundle.main.infoDictionary ?? [:]
    }
    
    static var githubClientId: String {
        infoDictionary["GITHUB_CLIENT_ID"] as? String ?? ""
    }
    
    static var githubClientSecret: String {
        infoDictionary["GITHUB_CLIENT_SECRET"] as? String ?? ""
    }
}
