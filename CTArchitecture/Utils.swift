//
//  Created by Ricardo Santos on 13/03/2021.
//

import Foundation
import Combine
import ComposableArchitecture

struct AppViews { private init() { } }
typealias V = AppViews

struct AppDomain { private init() { } }
typealias D = AppDomain

struct AppReducers { private init() { } }

public func nthPrimeV1(_ n: Int, callback: @escaping (Int?) -> Void) {
    let seconds = 3.0
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        if Bool.random() {
            callback(n * n)
        } else {
            callback(nil)
        }
    }
}

final class GenericStore<Value, Action>: ObservableObject {
    //typealias ReducerType = (inout Value, Action) -> Void

    // Reducer that takes a value and action and return a new value
    let reducer: (inout Value, Action) -> Void
    @Published var value: Value
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}
