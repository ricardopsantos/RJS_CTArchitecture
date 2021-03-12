//
//  GoodToGoUITests.swift
//  GoodToGoUITests
//
//  Created by Ricardo Santos on 01/03/2021.
//

import XCTest

//
// https://www.avanderlee.com/optimization/launch-time-performance-optimization/
//

class GoodToGoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// Measure warm launch over 5 iterations (after one throw-away launch)
    func testLaunchPerformance1() throws {
        // This measures how long it takes to launch your application.
        if #available(iOS 14.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
                XCUIApplication().launch()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func testLaunchPerformance2() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
