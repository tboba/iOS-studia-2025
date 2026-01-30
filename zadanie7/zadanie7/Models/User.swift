//
//  User.swift
//  zadanie7
//
// Created by Tymoteusz on 1/29/26.
//

import Foundation

struct User: Codable {
    let firstName: String
    let lastName: String
    let username: String
    let authProvider: AuthProvider?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        
        if let components = formatter.personNameComponents(from: "\(firstName) \(lastName)") {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return String(firstName.prefix(1) + lastName.prefix(1)).uppercased()
    }
    
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    init(firstName: String, lastName: String, username: String, authProvider: AuthProvider? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.authProvider = authProvider
    }
}

enum AuthProvider: String, Codable {
    case server = "server"
    case google = "google"
    case github = "github"
}

extension User {
    static var mockUser = User(
        firstName: "John",
        lastName: "Doe",
        username: "johndoe12",
        authProvider: .server
    )
}

