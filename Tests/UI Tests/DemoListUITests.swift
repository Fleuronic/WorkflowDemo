// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

final class DemoListUITests: XCTestCase {
	func testContent() {
		let app = XCUIApplication()
		app.launch()

		let title = app.staticTexts["Workflow Demo"]
		let swiftUI = app.staticTexts["SwiftUI"]
		let uiKit = app.staticTexts["UIKit"]
		let declarativeUIKit = app.staticTexts["Declarative UIKit"]

		XCTAssert(title.exists)
		XCTAssert(swiftUI.exists)
		XCTAssert(uiKit.exists)
		XCTAssert(declarativeUIKit.exists)
	}

	func testUpdateDemosSuccess() {
		let app = XCUIApplication()
		app.launchEnvironment = ["updateDuration": "0.5"]
		app.launch()

		let updateButton = app.buttons["Update"]
		updateButton.tap()

		let swiftUI = app.staticTexts["SwiftUI"]
		let uiKit = app.staticTexts["UIKit"]
		let declarativeUIKit = app.staticTexts["Declarative UIKit"]

		XCTAssert(swiftUI.waitForExistence(timeout: 1))
		XCTAssert(uiKit.waitForExistence(timeout: 1))
		XCTAssert(declarativeUIKit.waitForExistence(timeout: 1))
	}

	func testUpdateDemosFailure() {
		let app = XCUIApplication()
		app.launchEnvironment = [
			"canUpdateDemos": "false",
			"updateDuration": "0.5"
		]
		app.launch()

		let updateButton = app.buttons["Update"]
		updateButton.tap()

		let alert = app.alerts.firstMatch
		let alertTitle = app.staticTexts["Update Error"]
		let dismissButton = app.buttons["Dismiss"]

		XCTAssert(alert.waitForExistence(timeout: 1))
		XCTAssert(alertTitle.waitForExistence(timeout: 1))

		dismissButton.tap()

		let swiftUI = app.staticTexts["SwiftUI"]
		let uiKit = app.staticTexts["UIKit"]
		let declarativeUIKit = app.staticTexts["Declarative UIKit"]

		XCTAssert(swiftUI.exists)
		XCTAssert(uiKit.exists)
		XCTAssert(declarativeUIKit.exists)
	}
}
