//
//  Created by Ricardo Santos on 12/03/2021.
//

import SwiftUI
import Foundation

//
// What was done on V1: Basic Setup
//

struct PrimeV1_Previews: PreviewProvider {
    static var previews: some View {
        PrimeV1.ContentView(state: PrimeV1.AppState())
    }
}

struct PrimeV1 {
    
    class AppState: ObservableObject {
        @Published var count: Int = 0
        @Published var favoritPrimes: [Int] = []
        
        var isFavoritPrime: Bool { favoritPrimes.contains(count) }
        func addPrime() { favoritPrimes.append(count) }
        func removePrime() { favoritPrimes = favoritPrimes.filter({ $0 != count }) }
    }
    
    struct ContentView: View {
        @ObservedObject var state: AppState
        var body: some View {
            NavigationView {
                List {
                    Text("\(state.count)")
                    NavigationLink(destination: CounterView(state: state)) {
                        Text("Favorit primes")
                    }
                    NavigationLink(destination: FavoritePrimesView(state: state)) {
                        Text("Favorit primes")
                    }
                }
            }
            .navigationBarTitle("Title2").foregroundColor(.blue)
        }
    }
    
    struct CounterView: View {
        @ObservedObject var state: AppState        // Global state
        @State var isPrimeModalShown: Bool = false // Local state
        @State var alertNthPrimeShow: Bool = false // Local state
        @State var alertNthPrime: Int?             // Local state
        var body: some View {
            VStack {
                HStack {
                    Button(action: { state.count += 1 }, label: { Text("+") })
                    Text("\(state.count)")
                    Button(action: { state.count -= 1 }, label: { Text("-") })
                }
                Button(action: {
                    isPrimeModalShown = true
                }, label: { Text("Is this prime?") })
                Button(action: {
                    nthPrimeV1(state.count) { some in
                        alertNthPrimeShow = some != nil
                        alertNthPrime = some
                    }
                }, label: { Text("What is the \(state.count)th prime?") })
            }
            .font(.title)
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
                if state.count.isPrime {
                    Text("\(state.count) is prime")
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
                    Text("\(state.count) is not prime")
                }
            }
        }
    }
    
    struct FavoritePrimesView: View {
        @ObservedObject var state: AppState        // Global state
        var body: some View {
            VStack {
                ForEach((0...state.favoritPrimes.count-1), id: \.self) {
                    Text("\(state.favoritPrimes[$0-1])").padding()
                }.onDelete { (indexSet) in
                    for index in indexSet {
                        state.favoritPrimes.remove(at: index)
                    }
                }
            }
            .font(.title)
            // .navigationTitle("FavoritePrimesView")
        }
    }
    
}
