import Combine
import ComposableArchitecture
import SwiftUI
import UIKit

//
// MARK:- PreviewProvider
//

struct UIKIT_CounterView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = V.CounterViewApp.CounterViewController(store: AppStores.CounterViewApp.store)
        return UIViewRepresented(makeUIView: { _ in vc.view })
    }
}

//
// MARK:- Store
//

extension AppStores {
    struct CounterViewApp {
        
        typealias CounterState       = D.CounterViewApp.CounterState
        typealias CounterAction      = D.CounterViewApp.CounterAction
        typealias CounterEnvironment = D.CounterViewApp.CounterEnvironment
        
        static let store = Store(
            initialState: CounterState(),
            reducer: AppReducers.CounterViewApp.counterReducer,
            environment: CounterEnvironment())
    }
}

//
// MARK:- Domain
//

extension D {
    
    struct CounterViewApp {
        
        //
        // MARK:- View Domain (Counter)
        //
        
        struct CounterState: Equatable {
            var count = 0
        }
        
        enum CounterAction: Equatable {
            case decrementButtonTapped
            case incrementButtonTapped
        }
        
        struct CounterEnvironment { }
        
        //
        // MARK:- App Domain
        //
        
        struct App {
            private init() { }
            enum AppAction: Equatable { }
            struct AppEnvironment { }
            struct AppState: Equatable { }
        }
    }

}

//
// MARK:- Reducer
//

extension AppReducers {
    struct CounterViewApp {
        
        typealias CounterState       = D.CounterViewApp.CounterState
        typealias CounterAction      = D.CounterViewApp.CounterAction
        typealias CounterEnvironment = D.CounterViewApp.CounterEnvironment

        static let counterReducer = Reducer<CounterState, CounterAction, CounterEnvironment> { state, action, _ in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
            case .incrementButtonTapped:
                state.count += 1
                return .none
            }
        }
    }
}

//
// MARK:- Views
//

extension V {

    struct CounterViewApp {
        
        typealias CounterState       = D.CounterViewApp.CounterState
        typealias CounterAction      = D.CounterViewApp.CounterAction
        typealias CounterEnvironment = D.CounterViewApp.CounterEnvironment
        
        final class CounterViewController: UIViewController {
            let viewStore: ViewStore<CounterState, CounterAction>
            var cancellables: Set<AnyCancellable> = []
            
            let countLabel = UILabel()

            init(store: Store<CounterState, CounterAction>) {
                self.viewStore = ViewStore(store)
                super.init(nibName: nil, bundle: nil)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func viewDidLoad() {
                super.viewDidLoad()
                setupLayout()
                self.viewStore.publisher
                    .map { "\($0.count)" }
                    .assign(to: \.text, on: countLabel)
                    .store(in: &self.cancellables)
            }
            
            @objc func decrementButtonTapped() {
                self.viewStore.send(.decrementButtonTapped)
            }
            
            @objc func incrementButtonTapped() {
                self.viewStore.send(.incrementButtonTapped)
            }
            
            private func setupLayout() {
                self.view.backgroundColor = .white
                let decrementButton = UIButton(type: .system)
                decrementButton.addTarget(self, action: #selector(decrementButtonTapped), for: .touchUpInside)
                decrementButton.setTitle("−", for: .normal)
                countLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
                let incrementButton = UIButton(type: .system)
                incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
                incrementButton.setTitle("+", for: .normal)
                let rootStackView = UIStackView(arrangedSubviews: [
                    decrementButton,
                    countLabel,
                    incrementButton,
                ])
                rootStackView.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(rootStackView)
                NSLayoutConstraint.activate([
                    rootStackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                    rootStackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
                ])
            }

        }
    }
    
}

