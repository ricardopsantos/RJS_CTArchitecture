//
//  Created by Ricardo Santos on 13/03/2021.
//

import Foundation
import Combine
import UIKit
import ComposableArchitecture
import SwiftUI

public extension Int {
    var isPrime: Bool {
        guard self >= 2     else { return false }
        guard self != 2     else { return true  }
        guard self % 2 != 0 else { return false }
        return !stride(from: 3, through: Int(sqrt(Double(self))), by: 2).contains { self % $0 == 0 }
    }
}

public extension Color {
    static var random: Color {
        Color(UIColor.random)
    }
}

fileprivate extension UIColor {
    static var random: UIColor {
        func random() -> CGFloat {
            return CGFloat(arc4random()) / CGFloat(UInt32.max)
        }
        return UIColor(red: random(), green: random(), blue: random(), alpha: 1.0)
    }
}

public extension Array {
    private func safeItem(at index: Int) -> Element? {
        guard index >= 0 else { return nil }
        return Int(index) < count ? self[Int(index)] : nil
    }

    func element(at index: Int) -> Element? {
        safeItem(at: index)
    }
}

extension Scheduler {
    public static var testScheduler: AnySchedulerOf<DispatchQueue> {
        DispatchQueue.testScheduler.eraseToAnyScheduler()
    }
    public static var appScheduler: AnySchedulerOf<DispatchQueue> {
        DispatchQueue.main.eraseToAnyScheduler()
    }
}
