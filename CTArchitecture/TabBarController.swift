//
//  Created by Ricardo Santos on 14/02/2021.
//
import UIKit
import Foundation
import Combine
import SwiftUI
//
import RJSLibUFBase

#if canImport(SwiftUI) && DEBUG
struct TabBarController_ViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView { return TabBarController().view }
    func updateUIView(_ view: UIView, context: Context) { }
}
struct TabBarControllerPreview: PreviewProvider {
    static var previews: some View { TabBarController_ViewRepresentable().buildPreviews() }
}
#endif

public class IntroViewController: TabBarController {
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // let vc = CTA_V5.ContentView(store: CTA_V5.store).viewController
       // present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

public class TabBarController: UITabBarController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let prime_1 = createControllers(tabName: "P.V1",
                                        vc: PrimeV1.ContentView(state: PrimeV1.AppState()).viewController)
        let prime_2 = createControllers(tabName: "P.V2",
                                        vc: PrimeV2.ContentView(state: PrimeV2.AppState()).viewController)
        let prime_3 = createControllers(tabName: "P.V3",
                                        vc: PrimeV3.ContentView(store: PrimeV3.Store(initialValue: PrimeV3.AppState(), reducer: PrimeV3().appReducer)).viewController)

        let todo_1 = createControllers(tabName: "CTA.V1",
                                       vc: Todo_V1.ContentView(store: Todo_V1.store).viewController)
        
        let todo_2 = createControllers(tabName: "CTA.V2",
                                       vc: Todo_V2.ContentView(store: Todo_V2.store).viewController)
        
        let todo_3 = createControllers(tabName: "CTA.V3",
                                       vc: Todo_V3.ContentView(store: Todo_V3.store).viewController)
        
        let todo_4 = createControllers(tabName: "CTA.V4",
                                       vc: Todo_V4.ContentView(store: Todo_V4.store).viewController)
        
        let todo_5 = createControllers(tabName: "CTA.V5",
                                       vc: Todo_V5.ContentView(store: Todo_V5.store).viewController)
        
        let todo_6 = createControllers(tabName: "CTA.V6",
                                       vc: Todo_V6.ContentView(store: Todo_V6.store).viewController)
        
        let todo_7 = createControllers(tabName: "CTA.V7",
                                       vc: Todo_V7.ContentView(store: Todo_V7.store).viewController)
        
        let todo_8 = createControllers(tabName: "CTA.V8",
                                       vc: Todo_V8.ContentView(store: Todo_V8.store).viewController)
        
        viewControllers = [todo_8, prime_3]
    }

    private func createControllers(tabName: String, vc: UIViewController) -> UINavigationController {
        let tabVC = UINavigationController(rootViewController: vc)
        tabVC.setNavigationBarHidden(true, animated: false)
        tabVC.tabBarItem.image = UIImage(systemName: "heart")
        tabVC.tabBarItem.title = tabName
        return tabVC
    }
}
