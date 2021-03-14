//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture
import RJSLibUFBase
import RJSLibUFDesignables

//
// What was done on V7:
//  - Intro to Effects
//  - New recucer to handle effect: appReducer_V5
//  - Intro to [Effect.cancel]
//
// Note - From Part 3 of the videos (A Tour of the Composable Architecture: Part 3)
//

//
// Delaying the sort
//
// What if we could add a little delay so that when you complete a todo you have a wait a
// second before the sorting is done. Since we are involving time here and want to do
// something outside the lifetime of our reducer being called, we definitely need to use
// effects. So far we haven’t had to use the Effect type at all because everything could
// just be done right in the reducer. But now we need to speak to the outside world, and
// then have the outside world speak back to us, and therefore effects are necessary.
//
// Effects are modeled in the Composable Architecture as Combine publishers that are
// returned from the reducer. After a reducer finishes its state mutation logic, it
// can return an effect publisher that will later be run by the store, and any data
// those effects produce will be fed back into the store so that we can react to it.
//
// We can’t return just any type of publisher, it has to be the Effect type
// that the library provides.
//

struct SwiftUIViewV7_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V7.ContentView(store: Todo_V7.store)
    }
}

struct Todo_V7 {
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: true),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]

    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: appReducer_V5,
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
        case todoDelayCompleted // New action from [Todo_V7], and to be return on the reducer efect
    }

    struct AppEnvironment {
        var uuid: () -> UUID // Function with no input ant that returns a UUID
    }
    
    // DEPRECATED
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
            // stale sort
            state.todos = state.todos
              .enumerated()
              .sorted(by: { lhs, rhs in
                (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
              })
              .map(\.element)
          return .none
        case .todo(index: let index, action: let action):
          return .none
        case .todoDelayCompleted:
            fatalError("created to be used on appReducer_V5")
        }
      }
    )
      .debug()
    
    static let appReducer_V5 = Reducer<AppState, AppAction, AppEnvironment>.combine(
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
        case .todo(index: _, action: .checkboxTapped):
            if false {
                // On effects we can add then combine operators
                return Effect(value: AppAction.todoDelayCompleted)
                    .delay(for: 1, scheduler: DispatchQueue.main)
                    .eraseToEffect() // Dont forget to eraseToEffect on end
                
                // But there’s a caveat. If I add a bunch of todos, and then slowly
                // check them off, we see that eventually the sorting happens right in
                // the middle of me trying to complete a task. This is because as I am
                // checking off todos we are not reseting the 1 second delay.
                // Once a second has passed from the first completion action it will
                // trigger a sort of the todos, even if you are still tapping around.
                //
                // The problem is that when we tap a checkbox we should cancel
                // any effects for todo completion that might be inflight.
            } else {
                
                if Bool.random() {
                    let id = "todo completion effect"

                    //
                    // Version 1.0: were we cancel using the id, and manually
                    //
                    
                    // First cancel, then (restart) delay
                    return .concatenate(
                        
                        // Effect A
                        
                        Effect.cancel(id: id), // This effect, when runs, cancel all pending effects with same id
                        
                        // Effect B
                        
                        Effect(value: AppAction.todoDelayCompleted)
                            .delay(for: 1, scheduler: DispatchQueue.main)
                            .eraseToEffect()      // Dont forget to eraseToEffect on end
                            .cancellable(id: id))
                } else {
                    
                    //
                    // Version 1.1: we can use the "cancelInFlight" param to cancel automaticly
                    //
                    
                    struct CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects: Hashable { }
                    
                    let id = Bool.random() ? "todo completion effect" : "\(CancelableIdThatWillNeverBeRepeatedAndMessUpOtherEffects())"

                    return Effect(value: AppAction.todoDelayCompleted)
                        .delay(for: 1, scheduler: DispatchQueue.main)
                        .eraseToEffect()      // Dont forget to eraseToEffect on end
                        .cancellable(id: id, cancelInFlight: true)
                }

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


