//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture
import RJSLibUFBase

//
// What was done on V5:
// 1 - Separated ContentView with subview : ForEachStore(state:action:) -> ForEachStore(state:action:content)
// 2 - Added Add btn with a new reducer (on the current reduzer using the combine operator), see appReducer_V3
//
// Note - From Part 2 of the videos (A Tour of the Composable Architecture: Part 2)
//

struct SwiftUIViewV5_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V5.ContentView(store: Todo_V5.store)
    }
}

struct Todo_V5 {
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: true),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]

    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: appReducer_V3,
        environment: AppEnvironment()
      )

    //
    // MARK:- ToDo Domain
    //

    struct Todo: Equatable, Identifiable {
      var description = ""
      let id: UUID
      var isComplete = false
    }

    struct TodoEnvironment {
        
    }

    enum TodoAction {
      case checkboxTapped
      case textFieldChanged(String)
    }
    
    // A reducer that operates on just a single todo and just with TodoActions
    static let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, _ in
      switch action {
      case .checkboxTapped:
        state.isComplete.toggle()
        return .none
      case .textFieldChanged(let text):
        state.description = text
        return .none
      }
    }.debug()
    
    struct AppState: Equatable {
        var todos: [Todo] = []
    }
    
    //
    // MARK:- App Domain
    //

    enum AppAction {
        case addButtonTapped
        case todo(index: Int, action: TodoAction)
    }

    struct AppEnvironment {

    }

    // Deprecated
    static let appReducer_V2_ = Reducer<AppState, AppAction, AppEnvironment>.combine(
      todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
      )
    )
    
    static let appReducer_V3 = Reducer<AppState, AppAction, AppEnvironment>.combine(
      todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
      ),
        // New reducer
      Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
          state.todos.insert(Todo(id: UUID()), at: 0)
          return .none
        case .todo(index: let index, action: let action):
            // We can also ignore todo actions.
          return .none
        }
      }
    )
      .debug()
    
    
    //
    // MARK:- UI
    //

    
    struct ContentView: View {
        let store: Store<AppState, AppAction>
        
        var body: some View {
          NavigationView {
            WithViewStore(self.store) { viewStore in
              List {
                ForEachStore(
                  self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
                  content: TodoView.init(store:)
                )
              }
              .navigationBarTitle("Todos")
              .navigationBarItems(trailing: Button("Add") {
                viewStore.send(.addButtonTapped)
              })
            }
          }
        }
        
        var body_before_separation: some View {
          NavigationView {
            WithViewStore(self.store) { viewStore in
              List {
                ForEachStore(
                  self.store.scope(state: \.todos, action: AppAction.todo(index:action:))
                ) { todoStore in
                  WithViewStore(todoStore) { todoViewStore in
                    HStack {
                      Button(action: { todoViewStore.send(.checkboxTapped) }) {
                        Image(systemName: todoViewStore.isComplete ? "checkmark.square" : "square")
                      }
                      .buttonStyle(PlainButtonStyle())
                      TextField(
                        "Untitled Todo",
                        text: todoViewStore.binding(
                          get: \.description,
                          send: TodoAction.textFieldChanged
                        )
                      )
                    }
                    .foregroundColor(todoViewStore.isComplete ? .gray : nil)
                  }
                }
              }
              .navigationBarTitle("Todos")
            }
          }
        }
        
    }
    
    struct TodoView: View {
      let store: Store<Todo, TodoAction>
      
      var body: some View {
        WithViewStore(self.store) { viewStore in
          HStack {
            Button(action: { viewStore.send(.checkboxTapped) }) {
              Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(PlainButtonStyle())
            TextField(
              "Untitled todo",
              text: viewStore.binding(
                get: \.description,
                send: TodoAction.textFieldChanged
              )
            )
          }
          .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
      }
    }
}


