//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
import Combine
//
import ComposableArchitecture
import RJSLibUFBase
import RJSLibUFDesignables

//
// MARK:- PreviewProvider
//

struct ToDoApp_Previews: PreviewProvider {
    static var previews: some View {
        V.TodoApp.ContentView(store: AppStores.TodoApp().store)
    }
}

//
// MARK:- Store
//

extension AppStores {
    
    struct TodoApp {
        
        typealias Todo            = D.TodoApp.TodoView.Todo
        typealias TodoEnvironment = D.TodoApp.TodoView.TodoEnvironment
        typealias TodoAction      = D.TodoApp.TodoView.TodoAction
        typealias AppEnvironment  = D.TodoApp.App.AppEnvironment
        typealias AppAction       = D.TodoApp.App.AppAction
        typealias AppState        = D.TodoApp.App.AppState
        
        static let todos = [
            Todo(description: "Milk", id: UUID(), isComplete: false),
            Todo(description: "Eggs", id: UUID(), isComplete: true),
            Todo(description: "Hand Soap", id: UUID(), isComplete: false)]
        
        var initialState: AppState = AppState(todos: todos)
        var reducer : Reducer<AppState, AppAction, AppEnvironment> { AppReducers.TodoApp().appReducer }
        var environment : AppEnvironment { AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(), uuid: UUID.init) }
        
        // Note: dont forget to type erasure on [mainQueue]
        var store: Store<AppState, AppAction> { Store(initialState: initialState, reducer: reducer, environment: environment) }
    }
    
}

//
// MARK:- Domain
//

extension D {
    
    struct TodoApp {
        
        typealias Todo            = D.TodoApp.TodoView.Todo
        typealias TodoEnvironment = D.TodoApp.TodoView.TodoEnvironment
        typealias TodoAction      = D.TodoApp.TodoView.TodoAction
        typealias AppEnvironment  = D.TodoApp.App.AppEnvironment
        typealias AppAction       = D.TodoApp.App.AppAction
        typealias AppState        = D.TodoApp.App.AppState
        
        //
        // MARK:- View Domain (ContentView)
        //
        
        struct ContentView {
            private init() { }
            struct Content: Equatable, Identifiable { let id: UUID }
            struct ContentEnvironment { }
            enum ContentAction: Equatable { }
        }
        
        //
        // MARK:- View Domain (TodoView)
        //
        
        struct TodoView {
            private init() { }
            struct Todo: Equatable, Identifiable {
                var description = ""
                let id: UUID
                var isComplete = false
            }
            
            struct TodoEnvironment { }
            
            enum TodoAction: Equatable {
                case checkboxTapped
                case textFieldChanged(String)
            }
        }
        
        //
        // MARK:- App Domain 
        //
        
        struct App {
            private init() { }
            enum AppAction: Equatable {
                case addButtonTapped
                case todo(index: Int, action: TodoAction)
                case todoDelayCompleted
            }
            
            struct AppEnvironment {
                // [AnySchedulerOf<DispatchQueue>] is a typealias for
                // [AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>]
                var mainQueue: AnySchedulerOf<DispatchQueue>
                var uuid: () -> UUID
            }
            
            struct AppState: Equatable {
                var todos: [Todo] = []
            }
        }
    }
}

//
// MARK:- Reducer
//

extension AppReducers {
    
    struct TodoApp {
        
        typealias Todo            = D.TodoApp.TodoView.Todo
        typealias TodoEnvironment = D.TodoApp.TodoView.TodoEnvironment
        typealias TodoAction      = D.TodoApp.TodoView.TodoAction
        typealias AppEnvironment  = D.TodoApp.App.AppEnvironment
        typealias AppAction       = D.TodoApp.App.AppAction
        typealias AppState        = D.TodoApp.App.AppState
        
        var todoReducer: Reducer<Todo, TodoAction, TodoEnvironment> { Reducer<Todo, TodoAction, TodoEnvironment> { state, action, _ in
            switch action {
            case .checkboxTapped:
                state.isComplete.toggle()
                return .none
            case .textFieldChanged(let text):
                state.description = text
                return .none
            }
        }
        }
        
        var appReducer: Reducer<AppState, AppAction, AppEnvironment> { Reducer<AppState, AppAction, AppEnvironment>.combine(
            todoReducer.forEach(state: \AppState.todos, action: /AppAction.todo(index:action:), environment: { _ in TodoEnvironment() } ),
            Reducer { state, action, environment in
                switch action {
                case .addButtonTapped:
                    state.todos.insert(Todo(id: environment.uuid()), at: 0)
                    return .none
                case .todo(index: _, action: .checkboxTapped):
                    let effectCancelationId = "todo completion effect"
                    if Bool.random() {
                        // Version 1: were we cancel using the id, and manually
                        // First cancel, then (restart) delay
                        return .concatenate(
                            // Effect A
                            Effect.cancel(id: effectCancelationId), // This effect, when runs, cancel all pending effects with same id
                            
                            // Effect B
                            Effect(value: AppAction.todoDelayCompleted)
                                .delay(for: 1, scheduler: environment.mainQueue)
                                .eraseToEffect() // Dont forget to eraseToEffect on end
                                .cancellable(id: effectCancelationId))
                    } else {
                        // Version 2: we can use the "cancelInFlight" param to cancel automaticly
                        struct CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects: Hashable { }
                        let cancelId = Bool.random() ? effectCancelationId : "\(CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects())"
                        return Effect(value: AppAction.todoDelayCompleted)
                            .delay(for: 1, scheduler: environment.mainQueue)
                            .eraseToEffect() // Dont forget to eraseToEffect on end
                            .cancellable(id: cancelId, cancelInFlight: true)
                    }
                    
                case .todo(index: let index, action: let action):
                    return .none
                case .todoDelayCompleted:
                    state.todos = state.todos
                        .enumerated()
                        .sorted(by: { lhs, rhs in
                            (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
                        })
                        .map(\.element)
                    return .none
                }
            }
        )
        .debug()}
    }
}



//
// MARK:- Views
//

extension V {
    
    struct TodoApp {
        
        typealias Todo            = D.TodoApp.TodoView.Todo
        typealias TodoEnvironment = D.TodoApp.TodoView.TodoEnvironment
        typealias TodoAction      = D.TodoApp.TodoView.TodoAction
        typealias AppEnvironment  = D.TodoApp.App.AppEnvironment
        typealias AppAction       = D.TodoApp.App.AppAction
        typealias AppState        = D.TodoApp.App.AppState
        
        //
        // ContentView
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
        
        //
        // TodoView
        //
        
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
}
