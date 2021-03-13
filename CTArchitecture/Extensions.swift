//
//  Created by Ricardo Santos on 13/03/2021.
//

import Foundation
import Combine
import ComposableArchitecture

extension Scheduler {
    public static var testScheduler: AnySchedulerOf<DispatchQueue>  {
        DispatchQueue.testScheduler.eraseToAnyScheduler()
    }
    public static var appScheduler: AnySchedulerOf<DispatchQueue>  {
        DispatchQueue.main.eraseToAnyScheduler()
    }
}
