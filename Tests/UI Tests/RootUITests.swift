// Copyright © Fleuronic LLC. All rights reserved.

import XCTest

final class RootUITests: XCTestCase {
	func testDemos() {
		let app = XCUIApplication()
		app.launch()
		
		let swiftUI = app.staticTexts["SwiftUI"]
		swiftUI.tap()
		
		let swiftUITitle = app.staticTexts["SwiftUI Counter Demo"]
		XCTAssert(swiftUITitle.exists)
		returnToDemoList(in: app)

		let uiKit = app.staticTexts["UIKit"]
		uiKit.tap()
		
		let uiKitTitle = app.staticTexts["UIKit Counter Demo"]
		XCTAssert(uiKitTitle.exists)
		returnToDemoList(in: app)

		let declarativeUIKit = app.staticTexts["Declarative UIKit"]
		declarativeUIKit.tap()
		
		let declarativeUIKitTitle = app.staticTexts["Declarative UIKit Counter Demo"]
		XCTAssert(declarativeUIKitTitle.exists)
		returnToDemoList(in: app)
	}
}

// MARK: -
private extension RootUITests {
	func returnToDemoList(in app: XCUIApplication) {
		let backButton = app.navigationBars.buttons.element(boundBy: 0)
		backButton.tap()
	}
}
