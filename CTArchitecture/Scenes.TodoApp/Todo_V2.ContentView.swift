//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture
import RJSLibUFBase

//
// What was done on V2:
// - Improved `ContentView: View`
// - added actions on appReducer_V1 logic to Reducer
//

struct SwiftUIViewV2_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V2.ContentView(store: Todo_V2.store)
    }
}

struct Todo_V2 {
    static let regularReducer = appReducer_V1
    static let reducerOnDebug = appReducer_V1.debug() // Will log all events
    static let reducer = RJS_Utils.onSimulator ? reducerOnDebug : regularReducer
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: false),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]

    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: reducer,
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

    //
    // MARK:- Domain CTA
    //

    struct AppState: Equatable {
        var todos: [Todo] = []
    }

    // The state is typically a struct because it holds a bunch of independent pieces of data,
    // though it does not always need to be a struct.
    enum AppAction {
        case todoCheckboxTapped(index: Int)
        case todoTextFieldChanged(index: Int, text: String)
    }

    // The actions are typically an enum because it represents one of many different
    // types of actions that a user can perform in the UI, such as tapping a button or entering text into a text field.

    struct AppEnvironment {

    }

    static let appReducer_V1 = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        switch action {
        case .todoCheckboxTapped(index: let index):
            state.todos[index].isComplete.toggle()
            return .none // No side effects
        case .todoTextFieldChanged(index: let index, text: let text):
            state.todos[index].description = text
            return .none // No side effects
        }
    }

    //
    // MARK:- UI
    //

    struct ContentView: View {
        let store: Store<AppState, AppAction>
        var body: some View {
          NavigationView {
            WithViewStore(self.store) { viewStore in
              List {
                ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
                    HStack {
                      Button(action: {
                        // Sending event (action) to ViewStore
                        viewStore.send(.todoCheckboxTapped(index: index))
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
                            send: { .todoTextFieldChanged(index: index, text: $0) }
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
