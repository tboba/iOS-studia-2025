//
//  Todo.swift
//  zadanie2
//
//  Created by Tymoteusz on 11/21/25.
//

import Foundation

enum TodoStatus: String, CaseIterable, Codable, Hashable {
    case todo = "Nowe"
    case inProgress = "W trakcie"
    case done = "Zrobione"

    var iconName: String {
        switch self {
        case .todo: return "circle"
        case .inProgress: return "arrow.right.circle.fill"
        case .done: return "checkmark.circle.fill"
        }
    }
}

struct Todo: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var imageName: String
    var status: TodoStatus

    init(id: UUID = UUID(), title: String, imageName: String, status: TodoStatus = .todo) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.status = status
    }
}

extension Array where Element == Todo {
    static var sample: [Todo] {
        [
            Todo(title: "Zadanie 1", imageName: "one", status: .todo),
            Todo(title: "Zadanie 2", imageName: "two", status: .inProgress),
            Todo(title: "Zadanie 3", imageName: "three", status: .done),
            Todo(title: "Zadanie 4", imageName: "four", status: .todo)
        ]
    }
}
