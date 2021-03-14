import Combine
import ComposableArchitecture
import SwiftUI

//
// MARK:- PreviewProvider
//

struct LiveNumberApp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            V.LiveNumberApp.EffectsBasicsView(store: AppStores.LiveNumberApp.store)
        }
    }
}

//
// MARK:- Stores
//

extension AppStores {
    struct LiveNumberApp {
        
        typealias EffectsBasicsState       = D.LiveNumberApp.EffectsBasicsState
        typealias EffectsBasicsAction      = D.LiveNumberApp.EffectsBasicsAction
        typealias EffectsBasicsEnvironment = D.LiveNumberApp.EffectsBasicsEnvironment
        
        static let store = Store(
            initialState: EffectsBasicsState(),
            reducer: AppReducers.LiveNumberApp().effectsBasicsReducer,
            environment: EffectsBasicsEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                numberFact: liveNumberFact(for:))
        )
    }
}

//
// MARK:- Domain
//

extension D {
    
    struct LiveNumberApp {
        
        //
        // MARK:- View Domain (ContentView)
        //
        
        struct EffectsBasicsState: Equatable {
            var count = 0
            var isNumberFactRequestInFlight = false
            var numberFact: String?
        }
        
        enum EffectsBasicsAction: Equatable {
            case decrementButtonTapped
            case incrementButtonTapped
            case numberFactButtonTapped
            case numberFactResponse(Result<String, NumbersApiError>)
        }
        
        struct EffectsBasicsEnvironment {
            var mainQueue: AnySchedulerOf<DispatchQueue>
            var numberFact: (Int) -> Effect<String, NumbersApiError>
        }
        
        //
        // MARK:- Others
        //
        
        struct NumbersApiError: Error, Equatable {}
        
    }
}

private let readMe = """
  This application has two simple side effects:

  • Each time you count down the number will be incremented back up after a delay of 1 second.
  • Tapping "Number fact" will trigger an API request to load a piece of trivia about that number.

  Both effects are handled by the reducer, and a full test suite is written to confirm that the \
  effects behave in the way we expect.
  """

//
// MARK:- Reducer
//

extension AppReducers {
    struct LiveNumberApp {
        
        typealias EffectsBasicsState       = D.LiveNumberApp.EffectsBasicsState
        typealias EffectsBasicsAction      = D.LiveNumberApp.EffectsBasicsAction
        typealias EffectsBasicsEnvironment = D.LiveNumberApp.EffectsBasicsEnvironment
        
        let effectsBasicsReducer = Reducer<
            EffectsBasicsState, EffectsBasicsAction, EffectsBasicsEnvironment
        > { state, action, environment in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.numberFact = nil
                // Return an effect that re-increments the count after 1 second.
                return Effect(value: EffectsBasicsAction.incrementButtonTapped)
                    .delay(for: 1, scheduler: environment.mainQueue)
                    .eraseToEffect()
                
            case .incrementButtonTapped:
                state.count += 1
                state.numberFact = nil
                return .none
                
            case .numberFactButtonTapped:
                state.isNumberFactRequestInFlight = true
                state.numberFact = nil
                // Return an effect that fetches a number fact from the API and returns the
                // value back to the reducer's `numberFactResponse` action.
                return environment.numberFact(state.count)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(EffectsBasicsAction.numberFactResponse)
                
            case let .numberFactResponse(.success(response)):
                state.isNumberFactRequestInFlight = false
                state.numberFact = response
                return .none
                
            case .numberFactResponse(.failure):
                state.isNumberFactRequestInFlight = false
                return .none
            }
        }
    }
}


//
// MARK:- Views
//

extension V {
    
    struct LiveNumberApp {
        
        typealias EffectsBasicsState       = D.LiveNumberApp.EffectsBasicsState
        typealias EffectsBasicsAction      = D.LiveNumberApp.EffectsBasicsAction
        typealias EffectsBasicsEnvironment = D.LiveNumberApp.EffectsBasicsEnvironment
        
        struct EffectsBasicsView: View {
            let store: Store<EffectsBasicsState, EffectsBasicsAction>
            
            var body: some View {
                WithViewStore(self.store) { viewStore in
                    Form {
                        Section(header: Text(readMe)) {
                            EmptyView()
                        }
                        
                        Section(
                            footer: Button("Number facts provided by numbersapi.com") {
                                UIApplication.shared.open(URL(string: "http://numbersapi.com")!)
                            }
                        ) {
                            HStack {
                                Spacer()
                                Button("−") { viewStore.send(.decrementButtonTapped) }
                                Text("\(viewStore.count)")
                                    .font(Font.body.monospacedDigit())
                                Button("+") { viewStore.send(.incrementButtonTapped) }
                                Spacer()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button("Number fact") { viewStore.send(.numberFactButtonTapped) }
                            if viewStore.isNumberFactRequestInFlight {
                                ActivityIndicator()
                            }
                            
                            viewStore.numberFact.map(Text.init)
                        }
                    }
                }
                .navigationBarTitle("Effects")
            }
        }
        
        // MARK: - Feature SwiftUI previews
    }
    
}

