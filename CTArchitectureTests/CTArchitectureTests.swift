//
//  GoodToGoTests.swift
//  GoodToGoTests
//
//  Created by Ricardo Santos on 01/03/2021.
//

import XCTest
import Combine
//
import ComposableArchitecture
import Nimble
//
@testable import CTArchitecture

//
// https://github.com/pointfreeco/swift-composable-architecture
//

extension Scheduler {
    public static var testScheduler: AnySchedulerOf<DispatchQueue>  {
        DispatchQueue.testScheduler.eraseToAnyScheduler()
    }
    public static var appScheduler: AnySchedulerOf<DispatchQueue>  {
        DispatchQueue.testScheduler.eraseToAnyScheduler()
    }
}

class CTArchitectureTests: XCTestCase {
    
    let testsQueue = DispatchQueue.testScheduler
    let mainQue = DispatchQueue.main
    //let testsQueue = DispatchQueue.testScheduler.eraseToAnyScheduler()
   // let testsQueue = DispatchQueue.main.eraseToAnyScheduler()
    var uuidDependency: UUID {
        return UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
    }

    func testCompletingTodo_v6() {
        let todos = [
            Todo_V6.Todo(description: "Milk_1",
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
    
    //
    // [testCompletingTodo_v8] is [testCompletingTodo_v6] fixed for side effects added on app version 7
    // Basicly we now need to say what to expect after the tap, AND after the efect
    func testCompletingTodo_v8() {

        //
        // Test after effects
        //
        
        //
        // Failed with :
        //   - Some effects are still running. All effects must complete by the end of the assertion.
        //     This can happen for a few reasons:
        //     • If you are using a scheduler in your effect, then make sure that you wait enough time for the
        //       effect to finish. If you are using a test scheduler, then make sure you advance the scheduler so that the effects complete.
        //     • If you are using long-living effects (for example timers, notifications, etc.), then ensure those
        //       effects are completed by returning an `Effect.cancel` effect from a particular action in your reducer,
        //       and sending that action in the test.
        //
        // Solution: The assert method supports inserting little imperative tasks like that in between steps,
        // and it’s called a [do] block: Use [XCTWaiter]
        //
        // Failed now with:
        //   Received 1 unexpected action: …
        //   Unhandled actions: [
        //     AppAction.todoDelayCompleted,
        //   ]
        // Solution: Use [.receive(.todoDelayCompleted)]
        
        let initialState = false
        let todos = [
            Todo_V8.Todo(description: "Milk_1",
                         id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                         isComplete: initialState),
        ]
        let store = TestStore(
            initialState: Todo_V8.AppState(todos: todos),
            reducer: Todo_V8.appReducer_V6,
            environment: Todo_V8.AppEnvironment(mainQueue: mainQue.eraseToAnyScheduler(),
                                                uuid: {
                fatalError("This should not be called on this test")
            })
        )
        store.assert(
          .send(.todo(index: 0, action: .checkboxTapped)) { //
            $0.todos[0].isComplete = !initialState
          },
          .do {
            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
          },
            .receive(.todoDelayCompleted) { // Dont forget to add after XCTWaiter to say we are expecting to receive this action
                $0.todos = [
                    Todo_V8.Todo(description: "Milk_1",
                                 id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                                 isComplete: !initialState)
                ]
            },

          .send(.todo(index: 0, action: .checkboxTapped)) {  // check again un-check
            $0.todos[0].isComplete = initialState
          },
          .do {
            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
          },
            .receive(.todoDelayCompleted) { // Dont forget to add after XCTWaiter to say we are expecting to receive this action
                $0.todos = [
                    Todo_V8.Todo(description: "Milk_1",
                                 id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                                 isComplete: initialState)
                ]
            }
        )

    }
    
    func testAddTodo_v6() {
        
        //
        // Test before adding effects
        //
        
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
        
        let store = TestStore(
            initialState: Todo_V6.AppState(todos: []),
            reducer: reducer,
            environment: Todo_V6.AppEnvironment(uuid: { [weak self] in self!.uuidDependency } )
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
    
    //
    // [testAddTodo_v8] is [testAddTodo_v6] fixed for side effects added on app version 7
    //
    func testAddTodo_v8() {
        //
        // Test after effects
        //
        let reducer = Todo_V8.appReducer_V6
        let store = TestStore(
            initialState: Todo_V8.AppState(todos: []),
            reducer: reducer,
            environment: Todo_V8.AppEnvironment(mainQueue: mainQue.eraseToAnyScheduler(),
                                                uuid: { [weak self] in self!.uuidDependency } )
        )

        let addedTodo = Todo_V8.Todo(description: "",
                                     id: uuidDependency,
                                     isComplete: false)
        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [addedTodo]
            }
        )
    }
    
    func testTodoSorting_v6() {
            
            //
            // Test before adding effects
            //
            
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
                    //$0.todos[0].isComplete = true
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

    //
    // [testTodoSorting_v8] is [testTodoSorting_v6] fixed for side effects added on app version 7
    // Basicly we now need to say what to expect after the tap, AND after the efect
    func testTodoSorting_v8_on_main_queu() {
            
            //
            // Test fixed after adding effects
            //
        
            let todos = [
                Todo_V8.Todo(
                  description: "Milk_1",
                  id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                  isComplete: true
                ),
                Todo_V8.Todo(
                  description: "Milk_2",
                  id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                  isComplete: true
                )
            ]
            
            let store = TestStore(
                initialState: Todo_V8.AppState(todos: todos),
                reducer: Todo_V8.appReducer_V6,
                environment: Todo_V8.AppEnvironment(mainQueue: mainQue.eraseToAnyScheduler(),
                                                    uuid: {
                    fatalError("This should not be called on this test")
                })
            )

            store.assert(
                .send(.todo(index: 1, action: .checkboxTapped)) {
                    // What we expect after tap?
                    // 1 : We say that when we tap on index 1, index 1 should toggle
                    $0.todos[1].isComplete = false
                },
                .do {
                  _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
                },
                .receive(.todoDelayCompleted) { // Dont forget to add after XCTWaiter to say we are expecting to receive this action
                    // What we expect after todoDelayCompleted?
                    // 2 : We say that milk 2 should be first now, and not completed
                    $0.todos = [
                        Todo_V8.Todo(
                          description: "Milk_2",
                          id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                          isComplete: false
                        ),
                        Todo_V8.Todo(
                          description: "Milk_1",
                          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                          isComplete: true
                        )
                    ]
                }
            )
    }
    
    //
    // [testTodoSorting_v8] is [testTodoSorting_v6] fixed for side effects added on app version 7
    // Basicly we now need to say what to expect after the tap, AND after the efect
    func testTodoSorting_v8_on_tests_qeue() {
            
            //
            // Test fixed after adding effects
            //
        
            let todos = [
                Todo_V8.Todo(
                  description: "Milk",
                  id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                  isComplete: false
                ),
                Todo_V8.Todo(
                  description: "Eggs",
                  id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                  isComplete: false
                )
            ]
            
            let store = TestStore(
                initialState: Todo_V8.AppState(todos: todos),
                reducer: Todo_V8.appReducer_V6,
                environment: Todo_V8.AppEnvironment(mainQueue: testsQueue.eraseToAnyScheduler(),
                                                    uuid: {
                    fatalError("This should not be called on this test")
                })
            )

            store.assert(
                .send(.todo(index: 0, action: .checkboxTapped)) {
                    // What we expect after tap?
                    // 1 : We say that when we tap on index 1, index 1 should toggle
                    $0.todos[0].isComplete = true
                },
                .do {
                 // _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
                    self.testsQueue.advance(by: 1) // No need to wayt any more, we just skip 1s further
                },
                .receive(.todoDelayCompleted) { // Dont forget to add after XCTWaiter to say we are expecting to receive this action
                    // What we expect after todoDelayCompleted?
                    // 2 : We say that milk 2 should be first now, and not completed
                    $0.todos.swapAt(0, 1)
                }
            )
    }
}
