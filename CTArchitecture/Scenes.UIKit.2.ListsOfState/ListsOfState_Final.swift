import Combine
import ComposableArchitecture
import SwiftUI
import UIKit

//
// Note: ListOfStateApp dependes on CounterViewApp, that why the alias
//

typealias CounterViewController = V.CounterViewApp.CounterViewController
typealias CounterState          = D.CounterViewApp.CounterState
typealias CounterAction         = D.CounterViewApp.CounterAction
typealias CounterEnvironment    = D.CounterViewApp.CounterEnvironment
let counterReducer              = AppReducers.CounterViewApp.counterReducer

//
// MARK:- PreviewProvider
//

struct CountersTableViewController_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStores.ListOfStateApp().store
        let vc    = UINavigationController(rootViewController: V.ListOfStateApp.CountersTableViewController(store: store))
        return UIViewRepresented(makeUIView: { _ in vc.view })
    }
}

//
// MARK:- Store
//

extension AppStores {
    struct ListOfStateApp {
        
        typealias CounterListState       = D.ListOfStateApp.CounterListState
        typealias CounterListAction      = D.ListOfStateApp.CounterListAction
        typealias CounterListEnvironment = D.ListOfStateApp.CounterListEnvironment
        
        var initialState : CounterListState { CounterListState(counters: [CounterState(), CounterState(), CounterState()]) }
        var reducer      : Reducer<CounterListState, CounterListAction, CounterListEnvironment> { AppReducers.ListOfStateApp().counterListReducer }
        var environment  : CounterListEnvironment { CounterListEnvironment() }
        
        var store : Store<CounterListState, CounterListAction> { Store(initialState: initialState, reducer: reducer, environment: environment) }
    }
}

//
// MARK:- Domain
//

extension D {
    struct ListOfStateApp {
        
        //
        // MARK:- View Domain (CounterList)
        //
        
        struct CounterListState: Equatable {
            var counters: [CounterState] = []
        }
        
        enum CounterListAction: Equatable {
            case counter(index: Int, action: CounterAction)
        }
        
        struct CounterListEnvironment { }
        
        //
        // MARK:- App Domain
        //
        
        enum AppAction: Equatable { }
        struct AppEnvironment { }
        struct AppState: Equatable { }
    }
}

//
// MARK:- Reducer
//

extension AppReducers {
    struct ListOfStateApp {
        
        typealias CounterListState       = D.ListOfStateApp.CounterListState
        typealias CounterListAction      = D.ListOfStateApp.CounterListAction
        typealias CounterListEnvironment = D.ListOfStateApp.CounterListEnvironment
        
        let counterListReducer: Reducer<CounterListState, CounterListAction, CounterListEnvironment> =
            counterReducer.forEach(
                state: \CounterListState.counters,
                action: /CounterListAction.counter(index:action:),
                environment: { _ in CounterEnvironment() }
            )
    }
}

//
// MARK:- Views
//

extension V {
    struct ListOfStateApp {
        
        typealias CounterListState       = D.ListOfStateApp.CounterListState
        typealias CounterListAction      = D.ListOfStateApp.CounterListAction
        typealias CounterListEnvironment = D.ListOfStateApp.CounterListEnvironment
        
        final class CountersTableViewController: UITableViewController {
            let store: Store<CounterListState, CounterListAction>
            let viewStore: ViewStore<CounterListState, CounterListAction>
            var cancellables: Set<AnyCancellable> = []
            
            init(store: Store<CounterListState, CounterListAction>) {
                self.store = store
                self.viewStore = ViewStore(store)
                super.init(nibName: nil, bundle: nil)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func viewDidLoad() {
                super.viewDidLoad()
                self.title = "Lists"
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
                self.viewStore.publisher.counters
                    .sink(receiveValue: { [weak self] _ in self?.tableView.reloadData() })
                    .store(in: &self.cancellables)
            }
            
            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                self.viewStore.counters.count
            }
            
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "\(self.viewStore.counters[indexPath.row].count)"
                return cell
            }
            
            override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let store = self.store.scope(
                    state: { $0.counters[indexPath.row] },
                    action: { .counter(index: indexPath.row, action: $0) }
                )
                let vc = CounterViewController(store:store )
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
