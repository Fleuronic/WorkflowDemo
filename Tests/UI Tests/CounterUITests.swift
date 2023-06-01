// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

final class CounterUITests: XCTestCase {
	func testSwiftUIDemo() {
		let app = XCUIApplication()
		app.launchEnvironment = ["demo": "swiftUI"]
		app.launch()
		
		demo(in: app)
	}
	
	func testUIKit() {
		let app = XCUIApplication()
		app.launchEnvironment = ["demo": "uiKit"]
		app.launch()
		
		demo(in: app)
	}
	
	func testDeclarativeUIKitDemo() {
		let app = XCUIApplication()
		app.launchEnvironment = ["demo": "declarativeUIKit"]
		app.launch()
		
		demo(in: app)
	}
}

// MARK: -
private extension CounterUITests {
	func demo(in app: XCUIApplication) {
		let valueZero = app.staticTexts["The value is 0"]
		XCTAssert(valueZero.exists)

		let incrementButton = app.buttons["+"]
		incrementButton.tap()

		let valueOne = app.staticTexts["The value is 1"]
		XCTAssert(valueOne.exists)

		let resetButton = app.buttons["Reset"]
		resetButton.tap()
		XCTAssert(valueZero.exists)

		let decrementButton = app.buttons["-"]
		decrementButton.tap()

		let valueNegativeOne = app.staticTexts["The value is -1"]
		XCTAssert(valueNegativeOne.exists)
	}
}
