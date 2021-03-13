//
//  Created by Ricardo Santos on 12/03/2021.
//

import Foundation
import SwiftUI
//
import RJSLibUFBase

//
// What was done on V2: Added activityFeed, fixed crash on delete, improved ui
//

struct PrimeV2_Previews: PreviewProvider {
    static var previews: some View {
        PrimeV2.ContentView(state: PrimeV2.AppState())
    }
}

struct PrimeV2 {
    class AppState: ObservableObject {
        @Published var number: Int = 0
        @Published var favoritPrimes: [Int] = [3]
        @Published var activityFeed: [Activity] = []

        struct Activity {
            let timestamp: Date
            let type: ActivityType
            enum ActivityType {
                case addedFavoritePrime(Int)
                case removedFavoritePrime(Int)
            }
        }

        struct User {
            let userId: String
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
        func increment() {
            number += 1
            printState(sender: #function, aux: "")
        }
        func decrement() {
            number -= 1
            printState(sender: #function, aux: "")
        }
        var isPrime: Bool {
            let result = number.isPrime
            printState(sender: #function, aux: "\(result)")
            return result
        }
        var isFavoritPrime: Bool {
            let result = favoritPrimes.filter { $0 == number }.count >= 1
            printState(sender: #function, aux: "\(result)")
            return result
        }
        func addPrime() {
            favoritPrimes.append(number)
            activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(number)))
        }
        func removePrime() {
            favoritPrimes = favoritPrimes.filter({ $0 != number })
            activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(number)))
            printState(sender: #function, aux: "")
        }
        func removeFavoritPrime(_ n: Int) {
            favoritPrimes = favoritPrimes.filter({ $0 != n })
            activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(n)))
            printState(sender: #function, aux: "")
        }
        func removeFavoritPrime(at index: IndexSet) {
            favoritPrimes.remove(atOffsets: index)
        }
    }

    struct ContentView: View {
        @ObservedObject var state: AppState
        var body: some View {
            NavigationView {
                List {
                    Text("ContentView_RELOAD").foregroundColor(Color(UIColor.random)).font(.body)
                    NavigationLink(destination: CounterView(state: state)) {
                        Text("Find primes")
                    }
                    NavigationLink(destination: FavoritPrimesView(state: state)) {
                        Text("My favorit primes")
                    }
                }
                .navigationBarTitle("ContentView")
            }
        }
    }

    struct CounterView: View {
        @ObservedObject var state: AppState        // Global state
        @State var isPrimeModalShown: Bool = false // Local state
        @State var alertNthPrimeShow: Bool = false // Local state
        @State var alertNthPrime: Int?             // Local state
        @State var isLoadingAPI: Bool = false      // Local state
        var body: some View {
            VStack {
                Text("CounterView_RELOAD").foregroundColor(Color(UIColor.random)).font(.body)
                HStack {
                    Button(action: { state.decrement() }, label: { Text("-") })
                    Text("\(state.number)")
                    Button(action: { state.increment() }, label: { Text("+") })
                }
                Button(action: {
                    isPrimeModalShown = true
                }, label: { Text("Is this prime?") })
                Button(action: {
                    isLoadingAPI = true
                    nthPrimeV1(state.number) { some in
                        alertNthPrimeShow = some != nil
                        alertNthPrime = some
                        isLoadingAPI = false
                    }
                }, label: { Text("What is the \(state.number)th prime?") })
                .disabled(isLoadingAPI)
            }
            //.navigationTitle("CounterView")
            .sheet(isPresented: $isPrimeModalShown) { IsPrimeModalView(state: state) }
            .alert(isPresented: $alertNthPrimeShow) {
                       Alert(title: Text("The nth prime is \(alertNthPrime!)"), message: Text(""), dismissButton: .default(Text("OK")))
                   }
        }
    }

    struct IsPrimeModalView: View {
        @ObservedObject var state: AppState // Global state
        var body: some View {
            VStack {
                Text("IsPrimeModalView_RELOAD").foregroundColor(Color(UIColor.random)).font(.body)
                if state.number.isPrime {
                    Text("\(state.number) is prime")
                    Text("favoritPrimes: \(state.favoritPrimes.count)")
                    if state.isFavoritPrime {
                        Button(action: {
                            state.removePrime()
                        }, label: { Text("Remove from favorite primes") })
                    } else {
                        Button(action: {
                            state.addPrime()
                        }, label: { Text("Save to favorite primes") })
                    }
                } else {
                    Text("\(state.number) is not prime")
                }
            }
        }
    }

    struct FavoritPrimesView: View {
        @ObservedObject var state: AppState
        var body: some View {
            List {
                ForEach((0...state.upperRange), id: \.self) {
                    if let prime = state.favoritPrimes.element(at: $0) {
                        Text("\(prime)").padding()
                    } else {
                        EmptyView()
                    }
                }.onDelete { indexSet in
                    state.removeFavoritPrime(at: indexSet)
                }
            }
        }
    }
}
