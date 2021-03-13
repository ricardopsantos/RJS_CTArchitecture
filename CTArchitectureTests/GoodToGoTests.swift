//
//  GoodToGoTests.swift
//  GoodToGoTests
//
//  Created by Ricardo Santos on 01/03/2021.
//

import XCTest
@testable import CTArchitecture
import ComposableArchitecture

//
// https://github.com/pointfreeco/swift-composable-architecture
//

class CTArchitectureTests: XCTestCase {
    
    func testCompletingTodo() {
        let todos = [
            Todo_V6.Todo(description: "Milk",
                         id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                         isComplete: false)
        ]
        let store = TestStore(
            initialState: Todo_V6.AppState(todos: todos),
            reducer: Todo_V6.appReducer_V3,
            environment: Todo_V6.AppEnvironment(uuid: {
                fatalError("This should not be called on this test")
            })
        )
        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            }
        )
    }
    
    func testAddTodo() {

        let reducerWithDependency    = Todo_V6.appReducer_V3
        let reducerWithOutDependency = Todo_V6.appReducer_V4
        let reducer = reducerWithOutDependency
        
        // The problem with reducer [appReducer_V3] is that we have a
        // dependency on UUID in our reducer that is not properly controlled.
        // By invoking the UUID initializer directly we are reaching out
        // into the real world to compute a random UUID, and we have no way
        // to control that.
        //
        // This is precisely what the third generic of the Reducer type is for,
        // and it’s called the environment.
        //
        // You can of course always reach out to global dependencies and
        // functions in your reducer, but if you want things to be testable
        // you should throw those dependencies in the environment and then
        // you get a shot at controlling them later.
        
        var uuidDependency: UUID {
            return UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
        }
        let store = TestStore(
            initialState: Todo_V6.AppState(todos: []),
            reducer: reducer,
            environment: Todo_V6.AppEnvironment(uuid: {
                uuidDependency
            })
        )

        let addedTodo = Todo_V6.Todo(description: "",
                                     id: uuidDependency,
                                     isComplete: false)
        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [addedTodo]
            }
        )
    }
    
    func testTodoSorting() {
        
        let todos = [
            Todo_V6.Todo(
              description: "Milk",
              id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
              isComplete: false
            ),
            Todo_V6.Todo(
              description: "Eggs",
              id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
              isComplete: false
            )
        ]
        
        var uuidDependency: UUID {
            return UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
        }
        
        let store = TestStore(
            initialState: Todo_V6.AppState(todos: todos),
            reducer: Todo_V6.appReducer_V4,
            environment: Todo_V6.AppEnvironment(uuid: {
                fatalError("This should not be called on this test")
            })
        )

        store.assert(
          .send(.todo(index: 0, action: .checkboxTapped)) {
            if Bool.random() {
                // Version 1 : Works
                $0.todos[0].isComplete = true
                $0.todos = [
                  $0.todos[1],
                  $0.todos[0],
                ]
            } else {
                // Version 2 : Works
                $0.todos = [
                    Todo_V6.Todo(
                    description: "Eggs",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    isComplete: false
                  ),
                    Todo_V6.Todo(
                    description: "Milk",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    isComplete: true
                  )
                ]

            }
          }
        )
    }
}
