//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture
import RJSLibUFBase

//
// What was done on V4: ForEach -> ForEachStore
//
// Note - From Part 2 of the videos (A Tour of the Composable Architecture: Part 2)
//

struct SwiftUIViewV4_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V4.ContentView(store: Todo_V4.store)
    }
}

struct Todo_V4 {
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: true),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]
    
    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: appReducer_V2,
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
        case todo(index: Int, action: TodoAction)
    }
    
    struct AppEnvironment {
        
    }
    
    static let appReducer_V2 = Reducer<AppState, AppAction, AppEnvironment>.combine(
        todoReducer.forEach(state: \AppState.todos, action: /AppAction.todo(index:action:), environment: { _ in TodoEnvironment() } )
    )
    
    //
    // MARK:- UI
    //
    
    /**
     
     ```
     ForEachStore(
     self.store.scope(
     state: "Describes how we want to transform the global state into local state",
     action: "The second function describes how to transform the local action into the global action"
     )
     ) { todoStore in
     
     )
     ```
     
     Previously, when using a simple `ForEach`, we had direct access to the todo value so that we could easily construct the views by accessing the fields on the `Todo` model. However, that is no longer the case, we instead of one of these todoStores, and we need wrap everything in a `WithViewStore` so that we can actually observe changes to this store
     
     */
    
    struct ContentView: View {
        let store: Store<AppState, AppAction>
        
        var body: some View {
            NavigationView {
                WithViewStore(self.store) { viewStore in
                    List {
                        ForEachStore(self.store.scope(state: \.todos, action: AppAction.todo(index:action:))) { todoStore in
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
        
        var body_before_ForEachStore: some View {
            NavigationView {
                WithViewStore(self.store) { viewStore in
                    List {
                        ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
                            HStack {
                                Button(action: {
                                    viewStore.send(.todo(index: index, action: .checkboxTapped))
                                }) {
                                    Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                                }
                                .buttonStyle(PlainButtonStyle())
                                TextField(
                                    "Untitled Todo",
                                    text: viewStore.binding(
                                        get: { $0.todos[index].description }, // acess to viewstore state
                                        send: { .todo(index: index, action: .textFieldChanged($0)) }
                                    )
                                )
                            }.foregroundColor(todo.isComplete ? .gray : nil)
                        }
                    }
                    .navigationBarTitle("Todos")
                }
            }
        }
    }
}
