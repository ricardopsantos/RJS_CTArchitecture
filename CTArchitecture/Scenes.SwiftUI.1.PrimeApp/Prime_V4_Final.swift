//
//  Created by Ricardo Santos on 12/03/2021.
//

import Foundation
import SwiftUI
//
import RJSLibUFBase

//
// MARK:- PreviewProvider
//

struct PrimeApp_Previews: PreviewProvider {
    static var previews: some View {
        PrimeV3.ContentView(store: AppStores.PrimeApp.store)
    }
}

//
// MARK:- Store
//

extension AppStores {
    struct PrimeApp {
        #warning("fix!!!!! wrong app")
        #warning("fix!!!!! wrong app")
        #warning("fix!!!!! wrong app")

       static let store = PrimeV3.Store(initialValue: PrimeV3.AppState(), reducer: PrimeV3().appReducer)
    }
}

//
// MARK:- Domain
//

extension D {
    
    struct PrimeApp {
        
        //
        // MARK:- View Domain (ContentView)
        //
        
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
        
        enum AppAction {
            case counter(CounterAction)
            case primeModal(PrimeModalAction)
            case favoritePrime(FavoritePrimeAction)
        }
        
        //
        // MARK:- App Domain
        //
        
        struct AppState {
            var number: Int = 0
            var favoritPrimes: [Int] = [3]
            var activityFeed: [Activity] = []
            
            struct Activity {
                let timestamp: Date
                let type: ActivityType
                enum ActivityType {
                    case addedFavoritePrime(Int)
                    case removedFavoritePrime(Int)
                }
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
    }
}



//
// MARK:- Reducer
//

extension AppReducers {
    struct PrimeApp {
        typealias AppAction = D.PrimeApp.AppAction
        typealias AppState  = D.PrimeApp.AppState
        
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
    }
}

//
// MARK:- Views
//

extension V {
    struct PrimeApp {
        
        typealias AppAction = D.PrimeApp.AppAction
        typealias AppState  = D.PrimeApp.AppState
        
        struct ContentView: View {
            //@ObservedObject var state: AppState
            @ObservedObject var store: GenericStore<AppState, AppAction>
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
            @ObservedObject var store: GenericStore<AppState, AppAction>
            @State var isPrimeModalShown: Bool = false // Local state
            @State var alertNthPrimeShow: Bool = false // Local state
            @State var alertNthPrime: Int? = nil       // Local state
            @State var isLoadingAPI: Bool = false      // Local state
            var body: some View {
                VStack {
                    Text("CounterView_RELOAD").foregroundColor(Color.random).font(.body)
                    HStack {
                        Button(action: {
                            store.send(.counter(.decrementTap))
                        }, label: { Text("-") })
                        Text("\(store.value.number)")
                        Button(action: {
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
                .sheet(isPresented: $isPrimeModalShown) { IsPrimeModalView(store: store) }
                .alert(isPresented: $alertNthPrimeShow) {
                    Alert(title: Text("The nth prime is \(alertNthPrime!)"), message: Text(""), dismissButton: .default(Text("OK")))
                }
            }
        }
        
        struct IsPrimeModalView: View {
            @ObservedObject var store: GenericStore<AppState, AppAction>
            var body: some View {
                VStack {
                    Text("IsPrimeModalView_RELOAD").foregroundColor(Color.random).font(.body)
                    if store.value.number.isPrime {
                        Text("\(store.value.number) is prime")
                        Text("favoritPrimes: \(store.value.favoritPrimes.count)")
                        if store.value.isFavoritPrime {
                            Button(action: {
                                store.send(.primeModal(.saveFavoritePrimeTap))
                            }, label: { Text("Remove from favorite primes") })
                        } else {
                            Button(action: {
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
            @ObservedObject var store: GenericStore<AppState, AppAction>
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
}
