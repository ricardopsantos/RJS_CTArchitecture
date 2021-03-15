//
//  GoodToGoTests.swift
//  GoodToGoTests
//
//  Created by Ricardo Santos on 01/03/2021.
//

import XCTest
import Combine
@testable import CTArchitecture
import ComposableArchitecture

//
// https://github.com/pointfreeco/swift-composable-architecture
//

class TodoAppFinalTests: XCTestCase {

    fileprivate let reducer    = AppReducers.TodoApp().appReducer
    fileprivate let testsQueue = DispatchQueue.testScheduler
    fileprivate let mainQue    = DispatchQueue.main
    fileprivate var uuidDependency: UUID { return UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }

    fileprivate typealias TodoAction = D.TodoApp.TodoView.TodoAction
    fileprivate typealias Todo       = D.TodoApp.TodoView.Todo
    fileprivate typealias AppState   = D.TodoApp.App.AppState

    fileprivate typealias AppEnvironment = D.TodoApp.App.AppEnvironment

    func test_Completing() {

        let initialState = false
        let todos = [
            Todo(description: "Milk_1",
                 id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                 isComplete: initialState),
        ]

        let store = TestStore(
            initialState: AppState(todos: todos),
            reducer: reducer,
            environment: AppEnvironment(
                mainQueue: mainQue.eraseToAnyScheduler(),
                uuid: { fatalError("This should not be called on this test") })
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
                    Todo(description: "Milk_1",
                         id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                         isComplete: !initialState)
                ]
            },

            .send(.todo(index: 0, action: .checkboxTapped)) {  // check again, un-check
                $0.todos[0].isComplete = initialState
            },
            .do {
                _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
            },
            .receive(.todoDelayCompleted) { // Dont forget to add after XCTWaiter to say we are expecting to receive this action
                $0.todos = [
                    Todo(description: "Milk_1",
                         id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                         isComplete: initialState)
                ]
            }
        )

    }

    func test_Add() {

        let store = TestStore(
            initialState: AppState(todos: []),
            reducer: reducer,
            environment: AppEnvironment(
                mainQueue: mainQue.eraseToAnyScheduler(),
                uuid: { self.uuidDependency })
        )

        let addedTodo = Todo(description: "", id: uuidDependency, isComplete: false)
        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [addedTodo]
            }
        )
    }

    func test_SortingMainQueu() {

        let todos = [
            Todo(description: "Milk_1", id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, isComplete: true),
            Todo(description: "Milk_2", id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, isComplete: true)
        ]

        let store = TestStore(
            initialState: AppState(todos: todos),
            reducer: reducer,
            environment: AppEnvironment(
                mainQueue: mainQue.eraseToAnyScheduler(),
                uuid: { fatalError("This should not be called on this test") })
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
                    Todo(description: "Milk_2", id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, isComplete: false),
                    Todo(description: "Milk_1", id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, isComplete: true)
                ]
            }
        )
    }

    func test_SortingTestsQueu() {

        let todos = [
            Todo(description: "Milk", id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, isComplete: false),
            Todo(description: "Eggs", id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, isComplete: false)
        ]

        let store = TestStore(
            initialState: AppState(todos: todos),
            reducer: reducer,
            environment: AppEnvironment(
                mainQueue: testsQueue.eraseToAnyScheduler(),
                uuid: { fatalError("This should not be called on this test") })
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
