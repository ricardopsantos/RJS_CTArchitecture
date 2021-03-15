//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture
import RJSLibUFBase

//
// What was done on V3:
//  - Added a TodoReducer to handle specific events on the Todo Actions
//  - appReducer_V1 was deprecated. Use appReducer_V2
//
// Note - From Part 1 of the videos (A Tour of the Composable Architecture: Part 1)
//

struct SwiftUIViewV3_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V3.ContentView(store: Todo_V3.store)
    }
}

struct Todo_V3 {
    //static let regularReducer = appReducer_V2
    //static let reducerOnDebug = appReducer_V2.debug() // Will log all events
    //static let reducer = RJS_Utils.onSimulator ? reducerOnDebug : regularReducer
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
    // MARK:- Domain
    //
    
    struct Todo: Equatable, Identifiable {
        var description = ""
        let id: UUID
        var isComplete = false
    }
    
    // We also need an environment to hold all of this feature’s dependencies
    struct TodoEnvironment {
        
    }
    
    //  What we can do is define a new domain for just the todo row
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
    // MARK:- Domain App
    //
    
    enum AppAction {
        //case todoCheckboxTapped(index: Int)
        //case todoTextFieldChanged(index: Int, text: String)
        case todo(index: Int, action: TodoAction)
    }
    
    // The actions are typically an enum because it represents one of many different
    // types of actions that a user can perform in the UI, such as tapping a button or entering text into a text field.
    
    struct AppEnvironment {
        
    }
    
    // deprecated
    static let appReducer_V1 = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        /*
         switch action {
         case .todoCheckboxTapped(index: let index):
         state.todos[index].isComplete.toggle()
         return .none // No side effects
         case .todoTextFieldChanged(index: let index, text: let text):
         state.todos[index].description = text
         return .none // No side effects
         }
         
         */
        return .none
    }
    
    static let appReducer_V2 = Reducer<AppState, AppAction, AppEnvironment>.combine(
        todoReducer.forEach(
            state: \AppState.todos,
            action: /AppAction.todo(index:action:),
            environment: { _ in TodoEnvironment() }
        )
    )
    
    //
    // MARK:- UI
    //
    
    struct ContentView: View {
        let store: Store<AppState, AppAction>
        //var body: some View { Text("") }
        var body: some View {
            NavigationView {
                WithViewStore(self.store) { viewStore in
                    List {
                        ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
                            HStack {
                                Button(action: {
                                    // Sending event (action) to ViewStore
                                    //viewStore.send(.todoCheckboxTapped(index: index))
                                    viewStore.send(.todo(index: index, action: .checkboxTapped))
                                }) {
                                    Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                                }
                                .buttonStyle(PlainButtonStyle())
                                // The ViewStore object comes with a helper method that is specifically
                                // for deriving bindings for situations like this. We can create a
                                // binding by describing what state in the store should be used for
                                // the binding, and specifying what action should be sent when the
                                // binding changes
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
