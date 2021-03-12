//
//  Created by Ricardo Santos on 22/01/2021.
//

import Foundation
import UIKit
//
import RJSLibUFBase

public struct DevTools {
    public static var onSimulador: Bool { RJS_Utils.onSimulator }
    public static var onDebug: Bool { RJS_Utils.onDebug }
    public static var onRelease: Bool { RJS_Utils.onRelease }

    public struct Log {

        private static let prefixMax = 1000

        public static func debug(_ some: String, function: String = #function, file: String = #file, line: Int = #line) {
            RJS_Logs.debug(some.prefix(prefixMax), tag: .client, function: function, file: file, line: line)
        }

        public static func info(_ some: String, function: String = #function, file: String = #file, line: Int = #line) {
            RJS_Logs.info(some.prefix(prefixMax), function: function, file: file, line: line)
        }

        public static func warning(_ some: String, function: String = #function, file: String = #file, line: Int = #line) {
            RJS_Logs.warning(some.prefix(prefixMax), function: function, file: file, line: line)
        }

        public static func error(_ some: String, function: String = #function, file: String = #file, line: Int = #line) {
            RJS_Logs.error(some.prefix(prefixMax), function: function, file: file, line: line)
        }
    }

    // Displays a message for developers (only if is simulador or debug mode)
    public static func makeToastForDevTeam(_ debugMessage: String) {
        guard onDebug || onSimulador else { return }
    }
}
