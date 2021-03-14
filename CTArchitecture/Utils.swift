//
//  Created by Ricardo Santos on 13/03/2021.
//

import Foundation
import Combine
import ComposableArchitecture
import UIKit
import SwiftUI

struct AppViews { private init() { } }
typealias V = AppViews

struct AppDomain { private init() { } }
typealias D = AppDomain

struct AppReducers { private init() { } }
struct AppStores { private init() { } }

let cellIdentifier = "Cell"

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

struct ActivityIndicator: View {
    var body: some View {
        UIViewRepresented(makeUIView: { _ in
            let view = UIActivityIndicatorView()
            view.startAnimating()
            return view
        })
    }
}



func liveNumberFact(for n: Int) -> Effect<String, D.LiveNumberApp.NumbersApiError> {
    return URLSession.shared.dataTaskPublisher(for: URL(string: "http://numbersapi.com/\(n)/trivia")!)
        .map { data, _ in String(decoding: data, as: UTF8.self) }
        .catch { _ in
            // Sometimes numbersapi.com can be flakey, so if it ever fails we will just
            // default to a mock response.
            Just("\(n) is a good number Brent")
                .delay(for: 1, scheduler: DispatchQueue.main)
        }
        .setFailureType(to: D.LiveNumberApp.NumbersApiError.self)
        .eraseToEffect()
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


struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
    let makeUIView: (Context) -> UIViewType
    let updateUIView: (UIViewType, Context) -> Void = { _, _ in }
    
    func makeUIView(context: Context) -> UIViewType {
        self.makeUIView(context)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        self.updateUIView(uiView, context)
    }
}
