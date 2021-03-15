//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture
import RJSLibUFBase
import RJSLibUFDesignables

//
// What was done on V6:
//  - Adding tests
//  - Moving UUID depedency from Reducer to AppEnvironment
//  - Adding sort
//
// Note - From Part 3 of the videos (A Tour of the Composable Architecture: Part 3)
//

struct SwiftUIViewV6_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V6.ContentView(store: Todo_V6.store)
    }
}

struct Todo_V6 {
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: true),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]
    
    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: appReducer_V4,
        environment: AppEnvironment(uuid: UUID.init)
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
    
    enum TodoAction: Equatable {
        case checkboxTapped
        case textFieldChanged(String)
    }
    
    // The todoReducer dont have acess to all the todos (list), just
    // have acess to a single todo, so if we want to SORT the todos, we cant do it
    // here because we dont have acess to do it. BUT in the main app reducer, we have
    // acess to everything
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
    
    enum AppAction: Equatable {
        case addButtonTapped
        case todo(index: Int, action: TodoAction)
    }
    
    struct AppEnvironment {
        // You can of course always reach out to global dependencies and
        // functions in your reducer, but if you want things to be testable
        // you should throw those dependencies in the environment and then
        // you get a shot at controlling them later.
        var uuid: () -> UUID // Function with no input ant that returns a UUID
    }
    
    static let appReducer_V3 = Reducer<AppState, AppAction, AppEnvironment>.combine(
        todoReducer.forEach(state: \AppState.todos, action: /AppAction.todo(index:action:), environment: { _ in TodoEnvironment() } ),
        // New reducer
        Reducer { state, action, environment in
            switch action {
            case .addButtonTapped:
                state.todos.insert(Todo(id: UUID()), at: 0)
                return .none
            case .todo(index: let index, action: let action):
                return .none
            }
        }
    )
    .debug()
    
    // Added new reducer that dont dependes on UUID inside, Its now on AppEnvironment
    //
    // So, we took advantage of the extra Environment generic that all reducers
    // have in order to properly pass down dependencies to the reducer, and this made
    // it very easy to control the UUID function and write tests.
    static let appReducer_V4 = Reducer<AppState, AppAction, AppEnvironment>.combine(
        todoReducer.forEach(
            state: \AppState.todos,
            action: /AppAction.todo(index:action:),
            environment: { _ in TodoEnvironment() }
        ),
        // New reducer
        Reducer { state, action, environment in
            switch action {
            case .addButtonTapped:
                state.todos.insert(Todo(id: environment.uuid()), at: 0)
                return .none
            // SORTING Todos on main reducer because have acess to all todos
            case .todo(index: _, action: .checkboxTapped):
                if true {
                    // The standard library sort method is not what is known as a
                    // “stable” sort. This means that two todos for which this
                    // condition returns false are not guaranteed to stay in
                    // the same order relative to each other.
                    state.todos.sort { !$0.isComplete && $1.isComplete }
                } else {
                    // stale sort
                    state.todos = state.todos
                        .enumerated()
                        .sorted(by: { lhs, rhs in
                            (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
                        })
                        .map(\.element)
                }
                return .none
            case .todo(index: let index, action: let action):
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
