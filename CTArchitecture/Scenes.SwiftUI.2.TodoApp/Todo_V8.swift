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
// What was done on V8:
// - Fixing unit tests broken by the effects
// - Added app enviroment var [var mainQueue: AnySchedulerOf<DispatchQueue>] so that we
//   have control over time when writing tests
// - appReducer_V5 is deprecated now. use appReducer_V6 that is using the [var mainQueue]
//
// Note - From Part 4 of the videos (A Tour of the Composable Architecture: Part 4)
//

struct SwiftUIViewV8_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V8.ContentView(store: Todo_V8.store)
    }
}

struct Todo_V8 {
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: true),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]

    // Note: dont forget to type erasure on [mainQueue]
    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: appReducer_V6,
        environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                    uuid: UUID.init)
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
    
    static let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, _ in
      switch action {
      case .checkboxTapped:
        //RJS_Logs.debug("[\(state.description)] tapped", tag: .client)
        state.isComplete.toggle()
        return .none
      case .textFieldChanged(let text):
        state.description = text
        return .none
      }
    }//.debug()
    
    struct AppState: Equatable {
        var todos: [Todo] = []
    }
    
    //
    // MARK:- App Domain
    //

    enum AppAction: Equatable {
        case addButtonTapped
        case todo(index: Int, action: TodoAction)
        case todoDelayCompleted
    }

    // [AnySchedulerOf<DispatchQueue>] is a typealias for
    // [AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>]
    struct AppEnvironment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
        var uuid: () -> UUID
    }
    
    // deprecated
    static let _appReducer_V5 = Reducer<AppState, AppAction, AppEnvironment>.combine(
      todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
      ),
      Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
          return .none
        case .todo(index: _, action: .checkboxTapped):
            if Bool.random() {
                let cancelId = "todo completion effect"

                //
                // Version 1.0: were we cancel using the id, and manually
                //
                
                // First cancel, then (restart) delay
                return .concatenate(
                    
                    // Effect A
                    
                    Effect.cancel(id: cancelId), // This effect, when runs, cancel all pending effects with same id
                    
                    // Effect B
                    
                    Effect(value: AppAction.todoDelayCompleted)
                        .delay(for: 1, scheduler: DispatchQueue.main)
                        .eraseToEffect()      // Dont forget to eraseToEffect on end
                        .cancellable(id: cancelId))
            } else {
                
                //
                // Version 1.1: we can use the "cancelInFlight" param to cancel automaticly
                //
                
                struct CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects: Hashable { }
                
                let cancelId = Bool.random() ? "todo completion effect" : "\(CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects())"

                return Effect(value: AppAction.todoDelayCompleted)
                    .delay(for: 1, scheduler: DispatchQueue.main)
                    .eraseToEffect()      // Dont forget to eraseToEffect on end
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
     // .debug()
    
    static let appReducer_V6 = Reducer<AppState, AppAction, AppEnvironment>.combine(
      todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
      ),
      Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
          return .none
        case .todo(index: _, action: .checkboxTapped):
            if Bool.random() {
                let cancelId = "todo completion effect"

                //
                // Version 1.0: were we cancel using the id, and manually
                //
                
                // First cancel, then (restart) delay
                return .concatenate(
                    
                    // Effect A
                    
                    Effect.cancel(id: cancelId), // This effect, when runs, cancel all pending effects with same id
                    
                    // Effect B
                    
                    Effect(value: AppAction.todoDelayCompleted)
                        .delay(for: 1, scheduler: environment.mainQueue)
                        .eraseToEffect()      // Dont forget to eraseToEffect on end
                        .cancellable(id: cancelId))
            } else {
                
                //
                // Version 1.1: we can use the "cancelInFlight" param to cancel automaticly
                //
                
                struct CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects: Hashable { }
                
                let cancelId = Bool.random() ? "todo completion effect" : "\(CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects())"

                return Effect(value: AppAction.todoDelayCompleted)
                    .delay(for: 1, scheduler: environment.mainQueue)
                    .eraseToEffect()      // Dont forget to eraseToEffect on end
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
