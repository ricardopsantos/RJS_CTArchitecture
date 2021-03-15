//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
//
import ComposableArchitecture

//
// What was done on V1: Basic Setup
//
// Note - From Part 1 of the videos (A Tour of the Composable Architecture: Part 1)
//

struct SwiftUIViewV1_Previews: PreviewProvider {
    static var previews: some View {
        Todo_V1.ContentView(store: Todo_V1.store)
    }
}

struct Todo_V1 {
    static let todos = [
        Todo(description: "Milk", id: UUID(), isComplete: false),
        Todo(description: "Eggs", id: UUID(), isComplete: false),
        Todo(description: "Hand Soap", id: UUID(), isComplete: false)]
    
    static let store = Store(
        initialState: AppState(todos: todos),
        reducer: appReducer_V1,
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
    
    struct AppState: Equatable {
        var todos: [Todo] = []
    }
    
    // The state is typically a struct because it holds a bunch of independent pieces of data,
    // though it does not always need to be a struct.
    enum AppAction {
        
    }
    
    // The actions are typically an enum because it represents one of many different
    // types of actions that a user can perform in the UI, such as tapping a button or entering text into a text field.
    
    struct AppEnvironment {
        
    }
    
    // Next we would define a reducer for our application, which is the thing that
    // glues together the state, action and environment into a cohesive package.
    // It’s the thing responsible for the business logic that runs the application.
    // Creating one for our domain involves providing a closure that is handed the current
    // state, an incoming action, and the environment:
    //
    // All the pure logic happens on the STATE mutations
    // All tne non pure logic happens on the EFFECTS
    // The Reducer powers the bussiness logic
    //
    static let appReducer_V1 = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        
        // We will make any mutations to the state necessary for the action.
        // The state value passed in here is an inout argument. So when an
        // action comes in, say the user tapping the todo checkbox,
        // we can just go into the state and mutate a todo’s isComplete field to be true.
        
        switch action {
        
        }
        
        // After you have performed all of the mutations you want to state,
        // you can return an EFFECT. An EFFECT is a special type that allows you to
        // communicate with the outside world, like executing an API request, writing
        // data to disk, or tracking analytics, and it allows you to feed data from the
        // outside world back into this reducer.
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
                        ForEach(viewStore.todos, id: \.id) { todo in
                            Text(todo.description)
                        }
                    }
                    .navigationBarTitle("Todos")
                }
            }
        }
    }
}
