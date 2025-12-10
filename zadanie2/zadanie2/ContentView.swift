//
//  ContentView.swift
//  zadanie2
//
//  Created by Tymoteusz on 11/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var todos: [Todo] = .sample

    var body: some View {
        NavigationStack {
            List {
                ForEach($todos) { $todo in
                    NavigationLink {
                        TodoView(todo: $todo)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: todo.status.iconName)
                                .foregroundStyle(color(for: todo.status))

                            Text(todo.title)

                            Spacer()

                            Text(todo.status.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Lista zadań")
        }
    }

    private func delete(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }

    private func color(for status: TodoStatus) -> Color {
        switch status {
        case .todo: return .gray
        case .inProgress: return .yellow
        case .done: return .green
        }
    }
}

#Preview {
    ContentView()
}
