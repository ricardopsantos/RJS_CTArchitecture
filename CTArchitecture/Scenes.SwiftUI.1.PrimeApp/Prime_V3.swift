//
//  Created by Ricardo Santos on 12/03/2021.
//

import Foundation
import SwiftUI
//
import RJSLibUFBase

//
// https://www.pointfree.co/episodes/ep68-composable-state-management-reducers
//

//
// What was done on V3: Added reducer
//

struct PrimeV3_Previews: PreviewProvider {
    static var previews: some View {
        PrimeV3.ContentView(store: PrimeV3.Store(initialValue: PrimeV3.AppState(), reducer: PrimeV3().appReducer))
    }
}

struct PrimeV3 {
    
    final class Store<Value, Action>: ObservableObject {
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
    
    enum FavoritePrimeAction {
        case deleteFavoritePrimes(IndexSet)
    }
    enum PrimeModalAction {
        case saveFavoritePrimeTap
        case removeFavoritePrimeTap
    }
    
    enum CounterAction {
        case decrementTap
        case incrementTap
    }
    
    // AppAction is a type to nest other app actions
    enum AppAction {
        case counter(CounterAction)
        case primeModal(PrimeModalAction)
        case favoritePrime(FavoritePrimeAction)
    }
    
    // inout cauze we are change the `state` instead of doing a copy, changing the copy and return it
    func appReducer(state: inout AppState, action: AppAction) -> Void {
        switch action {
        case .counter(.decrementTap):
            state.number -= 1
        case .counter(.incrementTap):
            state.number += 1
        case .primeModal(.saveFavoritePrimeTap):
            state.favoritPrimes.append(state.number)
            state.activityFeed.append(AppState.Activity(timestamp: Date(), type: .addedFavoritePrime(state.number)))
        case .primeModal(.removeFavoritePrimeTap):
            state.favoritPrimes = state.favoritPrimes.filter({ $0 != state.number })
            state.activityFeed.append(AppState.Activity(timestamp: Date(), type: .removedFavoritePrime(state.number)))
        case .favoritePrime(.deleteFavoritePrimes(let index)):
            state.favoritPrimes.remove(atOffsets: index)
        //let prime = state.favoritPrimes[index]
        //state.activityFeed.append(AppState.Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
    }
    
    // MARK: - Model
    
    struct AppState {
        var number: Int = 0
        var favoritPrimes: [Int] = [3]
        var activityFeed: [Activity] = []
        var userIsLoged: User?
        
        struct Activity {
            let timestamp: Date
            let type: ActivityType
            enum ActivityType {
                case addedFavoritePrime(Int)
                case removedFavoritePrime(Int)
            }
        }
        
        struct User {
            let id: String
            let name: String
            let bio: String
        }
        
        var upperRange: Int {
            if favoritPrimes.count == 0 {
                return 0
            } else {
                return favoritPrimes.count-1
            }
        }
        
        func printState(sender: String, aux: String) {
            RJS_Logs.info("# \(sender)")
            RJS_Logs.info("# number: \(number)")
            RJS_Logs.info("# favoritPrimes: \(favoritPrimes)")
            RJS_Logs.info("# activityFeed: \(activityFeed.map({ $0.type }))")
        }
        
        var isPrime: Bool {
            let result = number.isPrime
            printState(sender: #function, aux: "\(result)")
            return result
        }
        var isFavoritPrime: Bool {
            let result = favoritPrimes.filter{ $0 == number }.count >= 1
            printState(sender: #function, aux: "\(result)")
            return result
        }
        
    }
    
    struct PrimeAlert: Identifiable {
        let prime: Int
        var id: Int { prime }
    }
    
    struct ContentView: View {
        //@ObservedObject var state: AppState
        @ObservedObject var store: Store<AppState, AppAction>
        var body: some View {
            NavigationView {
                List {
                    Text("ContentView_RELOAD").foregroundColor(Color.random).font(.body)
                    NavigationLink(destination: CounterView(store: store)) {
                        Text("Find primes")
                    }
                    NavigationLink(destination: FavoritPrimesView(store: store)) {
                        Text("My favorit primes")
                    }
                }
                .navigationBarTitle("ContentView")
            }
        }
    }
    
    struct CounterView: View {
        @ObservedObject var store: Store<AppState, AppAction>
        @State var isPrimeModalShown: Bool = false // Local state
        @State var alertNthPrimeShow: Bool = false // Local state
        @State var alertNthPrime: Int? = nil       // Local state
        @State var isLoadingAPI: Bool = false      // Local state
        var body: some View {
            VStack {
                Text("CounterView_RELOAD").foregroundColor(Color.random).font(.body)
                HStack {
                    Button(action: {
                        //store.value.decrement()
                        //store.value = counterReducer(state: store.value, action: .decrementTap)
                        //store.send(.decrementTap)
                        store.send(.counter(.decrementTap))
                    }, label: { Text("-") })
                    Text("\(store.value.number)")
                    Button(action: {
                        //store.value.increment()
                        //store.value = counterReducer(state: store.value, action: .incrementTap)
                        // store.send(.incrementTap)
                        store.send(.counter(.incrementTap))
                    }, label: { Text("+") })
                }
                Button(action: {
                    isPrimeModalShown = true
                }, label: { Text("Is this prime?") })
                Button(action: {
                    isLoadingAPI = true
                    nthPrimeV1(store.value.number) { some in
                        alertNthPrimeShow = some != nil
                        alertNthPrime = some
                        isLoadingAPI = false
                    }
                }, label: { Text("What is the \(store.value.number)th prime?") })
                .disabled(isLoadingAPI)
            }
            //.navigationTitle("CounterView")
            .sheet(isPresented: $isPrimeModalShown) { IsPrimeModalView(store: store) }
            .alert(isPresented: $alertNthPrimeShow) {
                Alert(title: Text("The nth prime is \(alertNthPrime!)"), message: Text(""), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    struct IsPrimeModalView: View {
        @ObservedObject var store: Store<AppState, AppAction>
        var body: some View {
            VStack {
                Text("IsPrimeModalView_RELOAD").foregroundColor(Color.random).font(.body)
                if store.value.number.isPrime {
                    Text("\(store.value.number) is prime")
                    Text("favoritPrimes: \(store.value.favoritPrimes.count)")
                    if store.value.isFavoritPrime {
                        Button(action: {
                            store.send(.primeModal(.saveFavoritePrimeTap))
                            //store.value.removePrime()
                        }, label: { Text("Remove from favorite primes") })
                    } else {
                        Button(action: {
                            //store.value.addPrime()
                            store.send(.primeModal(.saveFavoritePrimeTap))
                        }, label: { Text("Save to favorite primes") })
                    }
                } else {
                    Text("\(store.value.number) is not prime")
                }
            }
        }
    }
    
    struct FavoritPrimesView: View {
        @ObservedObject var store: Store<AppState, AppAction>
        var body: some View {
            List {
                ForEach((0...store.value.upperRange), id: \.self) {
                    if let prime = store.value.favoritPrimes.element(at: $0) {
                        Text("\(prime)").padding()
                    } else {
                        EmptyView()
                    }
                }.onDelete { indexSet in
                    store.send(.favoritePrime(.deleteFavoritePrimes(indexSet)))
                    //  store.value.removeFavoritPrime(at: indexSet)
                }
            }
        }
    }
    
}

