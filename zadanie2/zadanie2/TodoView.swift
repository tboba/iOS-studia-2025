//
//  TodoView.swift
//  zadanie2
//
//  Created by Tymoteusz on 11/21/25.
//

import SwiftUI
import UIKit

struct TodoView: View {
    @Binding var todo: Todo

    var body: some View {
        Form {
            Section("Szczegóły") {
                TextField("Tytuł", text: $todo.title)
            }

            Section("Obraz") {
                if let uiImage = UIImage(named: todo.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .foregroundStyle(.secondary)
                        .padding(30)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
            }

            Section("Status") {
                ForEach(TodoStatus.allCases, id: \.self) { status in
                    Button {
                        todo.status = status
                    } label: {
                        HStack {
                            Image(systemName: status.iconName)
                            Text(status.rawValue)
                            Spacer()
                            if todo.status == status {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
        }
        .navigationTitle(todo.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var previewTodo = Todo(title: "Zadanie 1", imageName: "image1", status: .todo)
    NavigationStack { TodoView(todo: $previewTodo) }
}

